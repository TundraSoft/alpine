#!/usr/bin/env python3
"""
Repository-agnostic script to generate DOCKER.md for Docker Hub using content from README.md.
Extracts sections between configurable markers and combines with dynamic tags.
"""

import sys
import json
import requests
import re
from typing import Dict, List, Set, Optional
from collections import defaultdict
from packaging import version

def parse_version(ver: str) -> tuple:
    """Parse version string into comparable tuple."""
    try:
        return version.parse(ver)
    except (ValueError, TypeError):
        return version.parse("0.0.0")

def extract_section_from_readme(readme_content: str, start_marker: str, end_marker: str) -> Optional[str]:
    """Extract content between start and end markers from README."""
    start_idx = readme_content.find(start_marker)
    end_idx = readme_content.find(end_marker)
    
    if start_idx == -1 or end_idx == -1:
        return None
    
    # Extract content between markers (excluding the markers themselves)
    content = readme_content[start_idx + len(start_marker):end_idx].strip()
    return content

def get_alpine_versions(branches: List[str]) -> Dict[str, str]:
    """Get Alpine versions for given branches."""
    versions = {}
    
    for branch in branches:
        if branch == "edge":
            versions[branch] = "edge"
        else:
            try:
                url = f"https://cz.alpinelinux.org/alpine/{branch}/releases/x86_64/latest-releases.yaml"
                response = requests.get(url, timeout=10)
                if response.status_code == 200:
                    for line in response.text.split('\n'):
                        if line.strip().startswith('version:'):
                            ver = line.split(':')[1].strip()
                            versions[branch] = ver
                            break
            except Exception as e:
                print(f"Warning: Could not get version for branch {branch}: {e}")
                continue
    
    return versions

def generate_tags_section(versions: Dict[str, str], repo_name: str) -> str:
    """Generate the available tags section."""
    tags_lines = ["## 🏷️ Available Tags", ""]
    
    # Ensure repo_name is lowercase for Docker Hub URLs
    repo_name_lower = repo_name.lower()
    
    # Sort versions for display
    version_branches = []
    edge_branch = None
    
    for branch, ver in versions.items():
        if branch == "edge":
            edge_branch = (branch, ver)
        else:
            version_branches.append((branch, ver))
    
    # Sort version branches by version (newest first)
    version_branches.sort(key=lambda x: parse_version(x[1]), reverse=True)
    
    # Add latest tag (first stable version)
    if version_branches:
        latest_version = version_branches[0][1]
        tags_lines.extend([
            f"- [`latest`](https://hub.docker.com/r/{repo_name_lower}/tags?name=latest) - Latest stable release ({latest_version})",
            ""
        ])
    
    # Add version tags
    tags_lines.append("### Stable Versions")
    tags_lines.append("")
    
    for branch, ver in version_branches:
        major_minor = '.'.join(ver.split('.')[:2])
        tags_lines.extend([
            f"- [`{ver}`](https://hub.docker.com/r/{repo_name_lower}/tags?name={ver}) - Alpine {ver}",
            f"- [`{major_minor}`](https://hub.docker.com/r/{repo_name_lower}/tags?name={major_minor}) - Latest Alpine {major_minor}.x"
        ])
    
    # Add edge if available
    if edge_branch:
        tags_lines.extend([
            "",
            "### Development Versions",
            "",
            f"- [`edge`](https://hub.docker.com/r/{repo_name_lower}/tags?name=edge) - Alpine edge (development branch)"
        ])
    
    return "\n".join(tags_lines)

def generate_docker_readme(
    readme_path: str,
    versions: Dict[str, str], 
    repo_name: str, 
    s6_version: str,
    github_repo: str,
    sections_config: Dict[str, Dict[str, str]]
) -> str:
    """Generate the complete DOCKER.md content using extracted sections from README.md."""
    
    # Read the main README.md
    try:
        with open(readme_path, 'r', encoding='utf-8') as f:
            readme_content = f.read()
    except Exception as e:
        print(f"Warning: Could not read {readme_path}: {e}")
        readme_content = ""
    
    # Extract sections from README
    extracted_sections = {}
    for section_name, markers in sections_config.items():
        start_marker = markers['start']
        end_marker = markers['end']
        content = extract_section_from_readme(readme_content, start_marker, end_marker)
        if content:
            extracted_sections[section_name] = content
        else:
            print(f"Warning: Could not extract section '{section_name}' from README.md")
    
    # Generate tags section
    tags_section = generate_tags_section(versions, repo_name)
    
    # Get description or use default
    description = extracted_sections.get('description', 
        "A lightweight, secure base image with advanced features and developer-friendly utilities.")
    
    # Get environment variables or use default
    env_vars_content = extracted_sections.get('env-vars', """| Variable | Description | Default |
|----------|-------------|---------|
| `TZ` | Set container timezone | `UTC` |""")
    
    # Get build arguments or use default
    build_args_content = extracted_sections.get('build-args', """| Argument | Description | Example |
|----------|-------------|---------|
| `VERSION` | Application version | `latest` |""")
    
    # Generate the complete DOCKER.md content
    content = f"""# {github_repo.split('/')[-1].title()} Docker Image

{description}

[![Docker Pulls](https://img.shields.io/docker/pulls/{repo_name.lower()}.svg?logo=docker)](https://hub.docker.com/r/{repo_name.lower()})
[![GitHub](https://img.shields.io/github/license/{github_repo}.svg)](https://github.com/{github_repo})

## 📋 Quick Links

- � [Documentation](https://github.com/{github_repo})
- � [Issues](https://github.com/{github_repo}/issues)
- � [Security](https://github.com/{github_repo}/security)

## � Quick Start

```bash
# Pull and run
docker pull {repo_name}:latest
docker run -d --name my-app {repo_name}:latest
```

{tags_section}

## 📖 Usage

### Environment Variables

{env_vars_content}

### Build Arguments

{build_args_content}

## 🔧 Building Custom Images

```dockerfile
FROM {repo_name}:latest

# Install additional packages
RUN apk add --no-cache your-package

# Copy your application
COPY app/ /app/

# Set working directory
WORKDIR /app

# Your application startup
CMD ["/app/start.sh"]
```

## 🤝 Support & Contributing

- 📖 **Documentation**: [GitHub Repository](https://github.com/{github_repo})
- 🐛 **Bug Reports**: [GitHub Issues](https://github.com/{github_repo}/issues)
- 🔒 **Security Issues**: [Private Vulnerability Reporting](https://github.com/{github_repo}/security)
- 💡 **Feature Requests**: [GitHub Discussions](https://github.com/{github_repo}/discussions)

---

<div align="center">

**Built with ❤️ by [{github_repo.split('/')[0]}](https://github.com/{github_repo.split('/')[0]})**

[View on GitHub](https://github.com/{github_repo}) • [Docker Hub](https://hub.docker.com/r/{repo_name.lower()}) • [Report Issue](https://github.com/{github_repo}/issues)

</div>
"""
    
    return content

def main():
    """Main function."""
    if len(sys.argv) < 6:
        print("Usage: python generate_docker_readme.py <readme_path> <output_path> <alpine_branches_json> <repo_name> <github_repo> <s6_version> [sections_config]")
        print("Example: python generate_docker_readme.py README.md DOCKER.md '[\"v3.21\",\"v3.20\"]' tundrasoft/alpine TundraSoft/alpine 3.2.0.0 'description:DESCRIPTION-START,DESCRIPTION-END;env-vars:ENV-VARS-START,ENV-VARS-END'")
        sys.exit(1)
    
    readme_path = sys.argv[1]
    output_path = sys.argv[2]
    alpine_branches_json = sys.argv[3]
    repo_name = sys.argv[4]
    github_repo = sys.argv[5]
    s6_version = sys.argv[6] if len(sys.argv) > 6 else "latest"
    sections_config_str = sys.argv[7] if len(sys.argv) > 7 else ""
    
    try:
        # Parse Alpine branches
        alpine_branches = json.loads(alpine_branches_json)
        
        # Parse sections configuration
        sections_config = {}
        if sections_config_str:
            # Format: "section1:START1,END1;section2:START2,END2"
            for section_def in sections_config_str.split(';'):
                if ':' in section_def:
                    section_name, markers = section_def.split(':', 1)
                    if ',' in markers:
                        start_marker, end_marker = markers.split(',', 1)
                        sections_config[section_name] = {
                            'start': f'<!-- {start_marker} -->',
                            'end': f'<!-- {end_marker} -->'
                        }
        
        # Default sections if none provided
        if not sections_config:
            sections_config = {
                'description': {'start': '<!-- DESCRIPTION-START -->', 'end': '<!-- DESCRIPTION-END -->'},
                'env-vars': {'start': '<!-- ENV-VARS-START -->', 'end': '<!-- ENV-VARS-END -->'},
                'build-args': {'start': '<!-- BUILD-ARGS-START -->', 'end': '<!-- BUILD-ARGS-END -->'}
            }
        
        # Get Alpine versions for branches
        print(f"Getting Alpine versions for branches: {alpine_branches}")
        versions = get_alpine_versions(alpine_branches)
        
        if not versions:
            print("Warning: No versions found, generating basic template")
            versions = {"latest": "latest"}
        
        # Generate Docker README content
        content = generate_docker_readme(
            readme_path, versions, repo_name, s6_version, github_repo, sections_config
        )
        
        # Write to file
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print(f"✅ Generated {output_path} successfully!")
        print(f"📦 Included {len(versions)} Alpine versions")
        print(f"📋 Extracted {len(sections_config)} sections from README.md")
        
    except Exception as e:
        print(f"Error generating Docker README: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()

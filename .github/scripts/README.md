# GitHub Scripts

This directory contains automation scripts for the Alpine Docker image project.

## update_readme_tags.py

Automatically updates the README.md file with new Docker image version tags.

### Usage

```bash
python .github/scripts/update_readme_tags.py <readme_path> <new_version> <repo_name>
```

### Parameters

- `readme_path`: Path to the README.md file
- `new_version`: New Alpine version to add (e.g., "3.19.1")
- `repo_name`: Docker repository name (e.g., "tundrasoft/alpine")

### Example

```bash
python .github/scripts/update_readme_tags.py README.md "3.19.1" "tundrasoft/alpine"
```

### Features

- **Automatic sorting**: Versions are sorted in descending order (newest first)
- **Duplicate prevention**: Won't add the same version twice
- **Proper grouping**: Groups patch versions under their major.minor version
- **Linked tags**: All tags link to their respective DockerHub pages
- **Preserves existing data**: Maintains all existing version information

### Requirements

- Python 3.6+
- packaging library (`pip install packaging`)

### How it works

1. Parses the existing README.md between `<!-- TAGS-START -->` and `<!-- TAGS-END -->` markers
2. Extracts existing version information
3. Adds the new version to the appropriate major.minor group
4. Regenerates the entire tags table with proper sorting
5. Updates the README.md file

### Integration

This script is automatically run by the GitHub Actions workflow after successful Docker image builds on the main branch.

### File Structure

- **Location**: `.github/scripts/` (GitHub-specific automation scripts)
- **Docker builds**: Scripts are excluded via `.dockerignore` (`.github` folder is ignored)
- **Git tracking**: Scripts are tracked in Git (`.gitignore` doesn't exclude `.github` folder)

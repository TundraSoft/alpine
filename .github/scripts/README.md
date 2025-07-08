# GitHub Scripts

This directory contains automation scripts for the Alpine Docker image project.

## generate_docker_readme.py

**Repository-agnostic script** to automatically generate a Docker Hub-optimized README from your main README.md file.

### Features

- 🔄 **Repository Agnostic**: Works with any GitHub repository
- 📝 **Configurable Sections**: Extract specific sections from your README.md using markers
- 🏷️ **Dynamic Tags**: Automatically generates tag listings from Alpine versions (customizable)
- 🎯 **Docker Hub Optimized**: Generates content specifically for Docker Hub's format

### Setup for Any Repository

#### 1. Add Markers to Your README.md

```markdown
# My Project

<!-- DESCRIPTION-START -->
A brief description of your project that will appear in the Docker Hub README.
<!-- DESCRIPTION-END -->

## Usage

### Environment Variables

<!-- ENV-VARS-START -->
| Variable | Description | Default |
|----------|-------------|---------|
| `MY_VAR` | Description of variable | `default_value` |
<!-- ENV-VARS-END -->

### Build Arguments

<!-- BUILD-ARGS-START -->
| Argument | Description | Example |
|----------|-------------|---------|
| `BUILD_ARG` | Description of build arg | `example_value` |
<!-- BUILD-ARGS-END -->
```

#### 2. Usage

```bash
python generate_docker_readme.py <readme_path> <output_path> <alpine_branches_json> <repo_name> <github_repo> <s6_version> [sections_config]
```

#### 3. Example in Workflow

```yaml
- name: Generate Docker Hub README
  run: |
    python .github/scripts/generate_docker_readme.py \
      README.md \
      DOCKER.md \
      '${{ needs.setup.outputs.versions }}' \
      '${{ github.repository }}' \
      '${{ github.repository }}' \
      '${{ needs.setup.outputs.app-version }}' \
      'description:DESCRIPTION-START,DESCRIPTION-END;env-vars:ENV-VARS-START,ENV-VARS-END'
```

### Sections Configuration Format

```
'section1:START_MARKER,END_MARKER;section2:START_MARKER,END_MARKER'
```

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

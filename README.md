# LLM Index Repository

This repository serves as a centralized index for tracking multiple LLM-related repositories as submodules.

## Structure

- `repositories/` - Main directory containing all tracked repositories as submodules
- `scripts/` - Directory for update and maintenance scripts
- `.github/workflows/` - GitHub Actions workflows for automation

## Getting Started

1. Clone this repository with submodules:
   ```bash
   git clone --recursive <repository-url>
   ```

2. To update all submodules:
   ```bash
   git submodule update --remote --merge
   ```

## Adding New Repositories

To add a new repository as a submodule:
```bash
git submodule add <repository-url> repositories/<repository-name>
```

## Updating Submodules

To update all submodules to their latest commits:
```bash
git submodule foreach git pull origin main
```

## Repository List

The list of tracked repositories is maintained based on the [After-Thought/MonoRepo](https://github.com/After-Thought/MonoRepo) project.

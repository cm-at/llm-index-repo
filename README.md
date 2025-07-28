# LLM Index Repository

## Purpose

This repository serves as a **read-only** centralized index for tracking multiple LLM-related repositories as submodules. It is designed specifically for LLM indexing and analysis purposes, providing a structured way to aggregate and monitor multiple repositories without modifying their contents.

**IMPORTANT:** This index repository is strictly read-only. It should NEVER write to or modify the tracked repositories in any way.

## Structure

- `repositories/` - Main directory containing all tracked repositories as submodules (READ-ONLY)
- `scripts/` - Directory for update and maintenance scripts
- `.github/workflows/` - GitHub Actions workflows for automation

## Cloning with Submodules

To clone this repository along with all its submodules, use:

```bash
git clone --recurse-submodules <repository-url>
```

If you've already cloned the repository without submodules, initialize them with:

```bash
git submodule init
git submodule update
```

## Manually Updating Submodules

To manually update all submodules to their latest commits from their respective remote repositories:

```bash
# Update all submodules to latest remote commits
git submodule update --remote --merge

# Or update a specific submodule
git submodule update --remote --merge repositories/<submodule-name>
```

**Note:** These commands only update the references in your local index repository. They do NOT modify the tracked repositories themselves.

## Automated Update Process

This repository includes automated update mechanisms:

### Update Script
The `scripts/update-submodules.sh` script automates the process of updating all submodules:

```bash
./scripts/update-submodules.sh
```

This script:
- Fetches the latest changes from all submodule remotes
- Updates each submodule to its latest commit
- Maintains the read-only nature of tracked repositories

### GitHub Actions
The repository uses GitHub Actions workflows to automatically:
- Update submodules on a scheduled basis
- Ensure all submodules remain synchronized with their upstream repositories
- Generate reports on submodule status

## Adding New Submodules

To add a new repository as a submodule:

1. Add the submodule:
   ```bash
   git submodule add <repository-url> repositories/<repository-name>
   ```

2. Configure the submodule for read-only access:
   ```bash
   # Ensure the submodule is set to track the main/master branch
   git config -f .gitmodules submodule.repositories/<repository-name>.branch main
   ```

3. Commit the changes:
   ```bash
   git add .gitmodules repositories/<repository-name>
   git commit -m "Add <repository-name> as submodule"
   ```

4. Push to the remote repository:
   ```bash
   git push origin main
   ```

**Important:** Never make changes directly within the submodule directories. All tracked repositories should remain read-only.

## Best Practices for LLM Indexing Usage

### 1. Read-Only Access
- **NEVER** write to or modify files within the tracked repositories
- All submodules should be treated as immutable references
- Use separate development repositories for any modifications

### 2. Indexing Optimization
- Keep the index updated regularly to ensure LLMs have access to the latest code
- Use the automated update process to maintain synchronization
- Structure queries to reference specific repositories when needed

### 3. Repository Organization
- Maintain a clear naming convention for submodules in the `repositories/` directory
- Document the purpose of each tracked repository
- Group related repositories logically if managing large numbers of submodules

### 4. LLM Context Management
- When using this index with LLMs, specify which repositories are relevant to your query
- Reference specific files or directories within submodules using relative paths
- Be aware that LLMs can read but should never be instructed to write to these repositories

### 5. Security Considerations
- Ensure all submodules use HTTPS URLs for read-only access
- Regularly audit the list of tracked repositories
- Remove any submodules that are no longer needed or have become private

### 6. Performance Tips
- Use sparse-checkout for large repositories if only specific directories are needed
- Consider shallow clones for repositories with extensive history
- Regularly clean up old submodule data with `git gc`

## Repository List

The list of tracked repositories is maintained based on the [After-Thought/MonoRepo](https://github.com/After-Thought/MonoRepo) project.

## Contributing

When contributing to this index repository:
1. Only modify index configuration and documentation
2. Never commit changes within submodule directories
3. Test all scripts locally before submitting pull requests
4. Ensure new submodules follow the established naming conventions

# GitHub Actions Workflows for KaraDAV

This directory contains automated workflows for building and publishing Docker images of KaraDAV.

## Workflow Overview

### docker-build.yml - GitHub Container Registry (GHCR)

**Purpose:** Automatically builds and publishes Docker images to GitHub Container Registry (ghcr.io).

**Triggers:**
- Push to `main` or `master` branches
- Push of version tags (pattern `v*`, e.g., `v1.0.0`, `v2.1.3`)
- Pull requests to `main` or `master` branches (build only, no push)
- Manual workflow dispatch via GitHub Actions UI

**Features:**
- ✅ Multi-platform builds (linux/amd64, linux/arm64)
- ✅ Automatic tagging (latest, version tags, branch names, commit SHAs)
- ✅ GitHub Actions cache for faster subsequent builds
- ✅ Build provenance attestations for supply chain security
- ✅ Automatic login using `GITHUB_TOKEN` (no manual setup required)

**Image Tags Generated:**
- `latest` - Latest build from default branch (main/master)
- `v1.0.0`, `v1.0`, `v1` - Semantic version tags from git tags
- `main` - Latest commit on main branch
- `sha-abc123` - Specific commit SHA
- `pr-123` - Pull request builds (not pushed to registry)

**Accessing Images:**
```bash
# Pull latest version
docker pull ghcr.io/theitsnameless/karadav:latest

# Pull specific version
docker pull ghcr.io/theitsnameless/karadav:v1.0.0

# Pull specific branch
docker pull ghcr.io/theitsnameless/karadav:main
```

## Using the Published Images

### From GitHub Container Registry

Images are automatically published to GHCR on every push to main:

```bash
# Pull the latest image
docker pull ghcr.io/theitsnameless/karadav:latest

# Run the container
docker run -d -p 8080:80 -v ./data:/var/www/html/data ghcr.io/theitsnameless/karadav:latest
```

With Docker Compose:
```yaml
services:
  karadav:
    image: ghcr.io/theitsnameless/karadav:latest
    ports:
      - "8080:80"
    volumes:
      - ./data:/var/www/html/data
```

## Manually Triggering Workflows

You can manually trigger any workflow that has `workflow_dispatch` enabled:

1. Go to the "Actions" tab in your GitHub repository
2. Select the workflow you want to run (e.g., "Build and Push Docker Image to GHCR")
3. Click "Run workflow" button
4. Select the branch
5. Click "Run workflow"

This is useful for:
- Testing the workflow
- Rebuilding images without making code changes

## Creating Releases with Automatic Docker Builds

To create a new release and automatically build Docker images:

### Using Git Tags (Recommended)

```bash
# Create and push a version tag
git tag v1.0.0
git push origin v1.0.0
```

This will trigger the GHCR workflow to build and publish images with tags `v1.0.0`, `v1.0`, `v1`, and `latest`

### Using GitHub Releases UI

1. Go to your repository on GitHub
2. Click "Releases" → "Draft a new release"
3. Click "Choose a tag" and create a new tag (e.g., `v1.0.0`)
4. Fill in release title and description
5. Click "Publish release"

The workflows will automatically trigger and build the images.

## Workflow Features

### Multi-Platform Support

The workflow builds images for:
- `linux/amd64` - Intel/AMD 64-bit processors
- `linux/arm64` - ARM 64-bit processors (Raspberry Pi 4+, Apple Silicon, AWS Graviton)

This ensures the images work on a wide variety of hardware.

### Build Caching

The workflow uses GitHub Actions cache to speed up builds:
- Cache persists between workflow runs
- Significantly reduces build time (from ~10 minutes to ~2 minutes)
- Automatic cleanup of old cache entries

### Security Features

The workflow includes:
- **Build Provenance Attestations:** Cryptographically signed metadata about how the image was built
- **Automatic GITHUB_TOKEN:** No need to create or manage additional tokens
- **Read-only source code access:** Workflow only has permissions it needs

### Semantic Versioning

The workflow automatically parses version tags and creates multiple tags:
- `v1.2.3` → Creates tags: `v1.2.3`, `v1.2`, `v1`, `latest`
- `v2.0.0` → Creates tags: `v2.0.0`, `v2.0`, `v2`, `latest`

This allows users to pin to:
- Exact version: `v1.2.3`
- Minor version: `v1.2` (gets patch updates)
- Major version: `v1` (gets minor and patch updates)
- Latest: `latest` (always gets the newest version)

## Troubleshooting

### Workflow Fails with "unauthorized" Error

- This should not happen as `GITHUB_TOKEN` is automatically provided
- Check that the repository has package write permissions enabled

### Multi-Platform Build Takes Too Long

Multi-platform builds can take 10-20 minutes. This is normal because:
- ARM images are built via emulation (QEMU)
- Two complete builds are performed (amd64 + arm64)
- Cache helps on subsequent builds

To speed up:
- The cache is automatically used after the first build
- Consider building only `linux/amd64` if ARM support isn't needed

### Build Fails During Image Push

Check:
- Repository permissions and package settings
- Network connectivity issues (rare, but can happen)

### Tag Not Triggering Workflow

Make sure:
- Tag follows pattern `v*` (e.g., `v1.0.0`, not `1.0.0`)
- Tag is pushed to GitHub: `git push origin v1.0.0`
- Workflows are enabled in repository settings

## Monitoring Workflow Runs

View workflow status and logs:
1. Go to repository's "Actions" tab
2. Select a workflow run to see detailed logs
3. Each step shows its output and any errors
4. Download artifacts if the workflow produces any

## Best Practices

### Versioning

- Use semantic versioning: `vMAJOR.MINOR.PATCH`
- Create release tags for stable versions
- Test development changes on branches before tagging

### Security

- Regularly update workflow actions to latest versions
- Use Docker image scanning tools to check for vulnerabilities
- Keep base images updated (PHP 8.3)

### Performance

- Let cache warm up (first build is slower)
- Don't rebuild unnecessarily (workflows trigger automatically)
- Monitor build times and optimize Dockerfile if needed

## Contributing

When modifying workflows:
- Test changes in a fork first
- Document any new secrets or configuration needed
- Update this README with any changes
- Consider backward compatibility

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Build Push Action](https://github.com/docker/build-push-action)
- [Docker Metadata Action](https://github.com/docker/metadata-action)
- [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)

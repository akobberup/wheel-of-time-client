# Android Release Guide

## Quick Start

```bash
# Minor release (new features: 1.0.0 → 1.1.0)
./minor-release-android.sh
git push origin main && git push origin v1.1.0

# Major release (breaking changes: 1.0.0 → 2.0.0)
./major-release-android.sh
git push origin main && git push origin v2.0.0
```

## How It Works

### Release Scripts

- **minor-release-android.sh**: Bumps minor version (1.0.0 → 1.1.0)
- **major-release-android.sh**: Bumps major version (1.0.0 → 2.0.0)

Both scripts automatically:
1. Increment version in `pubspec.yaml`
2. Increment build number
3. Commit changes
4. Create git tag

### Automated Build

When you push a version tag (e.g., `v1.1.0`):
1. GitHub Actions triggers automatically
2. Builds release APK and App Bundle (AAB)
3. Runs tests
4. Creates GitHub Release with artifacts

### Distribution

**Users download APK from GitHub Releases:**
- Go to: `https://github.com/your-repo/releases`
- Download `app-release.apk`
- Install on Android device

**For Google Play Store:**
- Upload `app-release.aab` from GitHub Release

## Version Format

Format: `MAJOR.MINOR.PATCH+BUILD_NUMBER`

Example: `1.2.0+5`
- Version: 1.2.0
- Build: 5

## Web vs Android

- **Web**: Auto-deploys to server on every push to `main`
- **Android**: Builds only on version tags (manual release process)

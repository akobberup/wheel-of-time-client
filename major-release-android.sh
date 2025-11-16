#!/bin/bash

set -e

echo "🚀 Creating major Android release..."

# Get current version from pubspec.yaml
CURRENT_VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: //' | cut -d'+' -f1)
BUILD_NUMBER=$(grep "^version:" pubspec.yaml | sed 's/version: //' | cut -d'+' -f2)

# Parse version components
MAJOR=$(echo $CURRENT_VERSION | cut -d'.' -f1)
MINOR=$(echo $CURRENT_VERSION | cut -d'.' -f2)
PATCH=$(echo $CURRENT_VERSION | cut -d'.' -f3)

# Increment major version, reset minor and patch
NEW_MAJOR=$((MAJOR + 1))
NEW_VERSION="${NEW_MAJOR}.0.0"
NEW_BUILD_NUMBER=$((BUILD_NUMBER + 1))
FULL_VERSION="${NEW_VERSION}+${NEW_BUILD_NUMBER}"

echo "Current version: ${CURRENT_VERSION}+${BUILD_NUMBER}"
echo "New version: ${FULL_VERSION}"

# Update pubspec.yaml
sed -i "s/^version: .*/version: ${FULL_VERSION}/" pubspec.yaml

# Commit and tag
git add pubspec.yaml
git commit -m "Bump version til ${NEW_VERSION} (major release)"
git tag "v${NEW_VERSION}"

echo "✅ Version opdateret til ${FULL_VERSION}"
echo "📦 Tag v${NEW_VERSION} oprettet"
echo ""
echo "Kør følgende for at pushe:"
echo "  git push origin main"
echo "  git push origin v${NEW_VERSION}"

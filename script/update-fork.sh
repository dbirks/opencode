#!/bin/bash

# OpenCode Fork Update Script
# Automates the process of updating the fork from upstream and creating a new -fork release

set -e  # Exit on any error

echo "🔄 OpenCode Fork Update Script"
echo "=============================="

# Check if we're in the right directory
if [ ! -f "packages/opencode/package.json" ]; then
    echo "❌ Error: Please run this script from the root of the opencode repository"
    exit 1
fi

# Check if upstream remote exists
if ! git remote | grep -q "upstream"; then
    echo "❌ Error: No 'upstream' remote found. Please add it first:"
    echo "   git remote add upstream https://github.com/sst/opencode.git"
    exit 1
fi

# Check if we're on dev branch
current_branch=$(git branch --show-current)
if [ "$current_branch" != "dev" ]; then
    echo "❌ Error: Please switch to the 'dev' branch first"
    echo "   git checkout dev"
    exit 1
fi

# Check for uncommitted changes
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "❌ Error: You have uncommitted changes. Please commit or stash them first."
    exit 1
fi

echo "✅ Pre-flight checks passed"
echo

# Step 1: Fetch upstream changes
echo "📡 Step 1: Fetching upstream changes..."
git fetch upstream
echo "✅ Upstream fetched"

# Step 2: Get the latest upstream version
echo "🔍 Step 2: Checking latest upstream version..."
latest_upstream_tag=$(git tag --list --sort=-version:refname | grep -E "^v[0-9]" | head -1)
latest_upstream_version=${latest_upstream_tag#v}  # Remove 'v' prefix
echo "📍 Latest upstream version: $latest_upstream_version"

# Step 3: Merge upstream changes
echo "🔀 Step 3: Merging upstream/dev..."
if ! git merge upstream/dev; then
    echo "❌ Merge conflicts detected! Please resolve them manually and run:"
    echo "   git add ."
    echo "   git commit -m 'Merge upstream/dev'"
    echo "   Then re-run this script"
    exit 1
fi
echo "✅ Merged upstream changes"

# Step 4: Create fork version
fork_version="$latest_upstream_version-fork"
echo "🏷️  Step 4: Creating fork version: $fork_version"

# Step 5: Push changes
echo "📤 Step 5: Pushing changes to origin..."
git push origin dev
echo "✅ Changes pushed"

# Step 6: Trigger GitHub Actions release
echo "🚀 Step 6: Triggering GitHub Actions release for v$fork_version..."
gh workflow run publish.yml --repo dbirks/opencode --field version="$fork_version"
echo "✅ Release workflow triggered"

# Step 7: Monitor workflow (optional)
echo "👁️  Step 7: Monitoring workflow..."
echo "   You can monitor the release at:"
echo "   https://github.com/dbirks/opencode/actions"
echo
echo "   Or run this command to watch progress:"
echo "   gh run list --repo dbirks/opencode --limit 1"

echo
echo "🎉 Fork update process completed!"
echo "   Fork version: $fork_version"
echo "   The GitHub Actions workflow is now building your release."
echo
echo "📝 What was done:"
echo "   ✅ Fetched latest upstream changes"
echo "   ✅ Merged upstream/dev into your fork"
echo "   ✅ Pushed changes to your fork"
echo "   ✅ Triggered release workflow for v$fork_version"
echo
echo "🔮 Next steps:"
echo "   • Wait for the GitHub Actions workflow to complete"
echo "   • Your fork-specific features are preserved"
echo "   • New release will be available with latest upstream features"
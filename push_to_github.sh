#!/bin/bash

# Script to initialize git and push to GitHub
set -e

echo "🚀 Preparing to push NextGenSearch OpenSearch MCP Demo to GitHub..."

# Check if git is available
if ! command -v git &> /dev/null; then
    echo "❌ Git is not available. Please install Xcode command line tools first:"
    echo "   xcode-select --install"
    exit 1
fi

echo "✅ Git is available"

# Initialize git repository if not already initialized
if [ ! -d ".git" ]; then
    echo "📁 Initializing git repository..."
    git init
else
    echo "📁 Git repository already initialized"
fi

# Configure git user if not set (optional)
if ! git config user.name &> /dev/null; then
    echo "⚙️  Git user not configured. You may want to set:"
    echo "   git config --global user.name 'Your Name'"
    echo "   git config --global user.email 'your.email@example.com'"
fi

# Add all files
echo "📦 Adding all files to git..."
git add .

# Check if there are changes to commit
if git diff --staged --quiet; then
    echo "ℹ️  No changes to commit"
else
    # Commit changes
    echo "💾 Committing changes..."
    git commit -m "Initial commit: NextGenSearch OpenSearch MCP Demo

- Complete OpenSearch MCP integration demo
- Automated setup with Docker
- Sample data and configurations
- Support for Claude Desktop and Amazon Q
- Comprehensive documentation and examples"
fi

# Add remote if not exists
if ! git remote get-url origin &> /dev/null; then
    echo "🔗 Adding GitHub remote..."
    git remote add origin https://github.com/daggumalli/NextGenSearch-OpenSearch-MCP.git
else
    echo "🔗 GitHub remote already configured"
fi

# Push to GitHub
echo "🚀 Pushing to GitHub..."
echo ""
echo "⚠️  Make sure you have:"
echo "1. Created the repository 'NextGenSearch-OpenSearch-MCP' on GitHub"
echo "2. Have proper authentication set up (GitHub CLI, SSH keys, or personal access token)"
echo ""
read -p "Press Enter to continue with push, or Ctrl+C to cancel..."

# Try to push
if git push -u origin main; then
    echo ""
    echo "🎉 Successfully pushed to GitHub!"
    echo "🔗 Repository URL: https://github.com/daggumalli/NextGenSearch-OpenSearch-MCP"
    echo ""
    echo "📋 Next steps:"
    echo "1. Visit your repository on GitHub"
    echo "2. Add a description and topics"
    echo "3. Consider adding a GitHub Actions workflow for CI/CD"
else
    echo ""
    echo "❌ Push failed. Common issues:"
    echo "1. Repository doesn't exist on GitHub"
    echo "2. Authentication not set up"
    echo "3. Branch name mismatch (try 'git push -u origin master' if main doesn't work)"
    echo ""
    echo "🔧 To fix authentication:"
    echo "• Install GitHub CLI: brew install gh && gh auth login"
    echo "• Or set up SSH keys: https://docs.github.com/en/authentication/connecting-to-github-with-ssh"
fi
#!/bin/bash

# Install all prerequisites for NextGenSearch OpenSearch MCP Demo
set -e

echo "🛠️  Installing all prerequisites for NextGenSearch OpenSearch MCP Demo..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

echo ""
echo "📋 Step 1: Installing Xcode Command Line Tools..."

# Check if Xcode command line tools are installed
if xcode-select -p &> /dev/null; then
    print_status "Xcode command line tools already installed"
else
    print_info "Installing Xcode command line tools..."
    print_warning "A dialog will appear - click 'Install' and wait for completion"
    xcode-select --install
    
    echo ""
    print_warning "Please complete the Xcode installation dialog, then press Enter to continue..."
    read -p ""
    
    # Wait for installation to complete
    while ! xcode-select -p &> /dev/null; do
        echo "⏳ Waiting for Xcode command line tools installation..."
        sleep 5
    done
    
    print_status "Xcode command line tools installed successfully"
fi

echo ""
echo "📋 Step 2: Checking/Installing Homebrew..."

# Check if Homebrew is installed
if command -v brew &> /dev/null; then
    print_status "Homebrew already installed"
else
    print_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    
    print_status "Homebrew installed successfully"
fi

echo ""
echo "📋 Step 3: Installing Docker Desktop..."

# Check if Docker is installed
if command -v docker &> /dev/null; then
    print_status "Docker already installed"
    
    # Check if Docker is running
    if docker ps &> /dev/null; then
        print_status "Docker is running"
    else
        print_warning "Docker is installed but not running. Please start Docker Desktop"
    fi
else
    print_info "Installing Docker Desktop..."
    brew install --cask docker
    
    print_warning "Please start Docker Desktop from Applications folder"
    print_info "You may need to complete Docker Desktop setup and sign in"
    
    echo ""
    print_warning "After Docker Desktop is running, press Enter to continue..."
    read -p ""
fi

echo ""
echo "📋 Step 4: Installing Python and pipx..."

# Check Python 3
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2)
    print_status "Python 3 already installed (version $PYTHON_VERSION)"
else
    print_info "Installing Python 3..."
    brew install python
    print_status "Python 3 installed"
fi

# Check pipx
if command -v pipx &> /dev/null; then
    print_status "pipx already installed"
else
    print_info "Installing pipx..."
    python3 -m pip install --user pipx
    python3 -m pipx ensurepath
    
    # Add pipx to PATH
    export PATH="$HOME/.local/bin:$PATH"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zprofile
    
    print_status "pipx installed"
fi

echo ""
echo "📋 Step 5: Installing OpenSearch MCP Server..."

# Install OpenSearch MCP Server
if command -v opensearch-mcp-server &> /dev/null; then
    print_status "OpenSearch MCP Server already installed"
else
    print_info "Installing OpenSearch MCP Server..."
    pipx install opensearch-mcp-server
    print_status "OpenSearch MCP Server installed"
fi

echo ""
echo "📋 Step 6: Installing GitHub CLI (optional but recommended)..."

# Check GitHub CLI
if command -v gh &> /dev/null; then
    print_status "GitHub CLI already installed"
else
    print_info "Installing GitHub CLI..."
    brew install gh
    print_status "GitHub CLI installed"
    
    print_info "To authenticate with GitHub, run: gh auth login"
fi

echo ""
echo "📋 Step 7: Verifying Git..."

# Check git
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version 2>&1)
    print_status "Git is working: $GIT_VERSION"
else
    print_error "Git is still not available after Xcode installation"
    exit 1
fi

echo ""
echo "🎉 All prerequisites installed successfully!"
echo ""
echo "📋 Summary of installed tools:"
echo "• Xcode Command Line Tools"
echo "• Homebrew"
echo "• Docker Desktop"
echo "• Python 3 and pipx"
echo "• OpenSearch MCP Server"
echo "• GitHub CLI"
echo "• Git"

echo ""
echo "🚀 Next steps:"
echo "1. Make sure Docker Desktop is running"
echo "2. Authenticate with GitHub: gh auth login"
echo "3. Run the setup: ./setup.sh"
echo "4. Push to GitHub: ./push_to_github.sh"

echo ""
print_warning "Please restart your terminal or run 'source ~/.zprofile' to ensure all PATH changes take effect"
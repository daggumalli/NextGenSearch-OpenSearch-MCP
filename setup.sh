#!/bin/bash

# NextGenSearch OpenSearch MCP Demo Setup Script
set -e

echo "🚀 Setting up NextGenSearch OpenSearch MCP Demo..."

# Check prerequisites
echo "📋 Checking prerequisites..."

if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed. Please install Python 3 first."
    exit 1
fi

if ! command -v pipx &> /dev/null; then
    echo "⚠️  pipx is not installed. Installing pipx..."
    python3 -m pip install --user pipx
    python3 -m pipx ensurepath
    export PATH="$HOME/.local/bin:$PATH"
fi

echo "✅ Prerequisites check completed"

# Install uv (Python package manager)
echo "📦 Installing uv (Python package manager)..."
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"

echo "✅ uv installed successfully"
echo "ℹ️  OpenSearch MCP Server will be automatically downloaded when first used via uvx"

# Generate SSL certificates for OpenSearch
echo "🔐 Generating SSL certificates..."
mkdir -p docker/certs
cd docker/certs

# Generate root CA
openssl genrsa -out root-ca-key.pem 2048
openssl req -new -x509 -sha256 -key root-ca-key.pem -out root-ca.pem -days 730 -subj "/C=US/ST=CA/L=San Francisco/O=OpenSearch/OU=Demo/CN=root"

# Generate node certificate
openssl genrsa -out node-key.pem 2048
openssl req -new -key node-key.pem -out node.csr -subj "/C=US/ST=CA/L=San Francisco/O=OpenSearch/OU=Demo/CN=localhost"
openssl x509 -req -in node.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -sha256 -out node.pem -days 730

cd ../..

# Start OpenSearch
echo "🐳 Starting OpenSearch containers..."
cd docker
docker-compose up -d

echo "⏳ Waiting for OpenSearch to be ready..."
sleep 30

# Wait for OpenSearch to be healthy
max_attempts=30
attempt=1
while [ $attempt -le $max_attempts ]; do
    if curl -k -u admin:yourStrongPassword123! https://localhost:9200 &> /dev/null; then
        echo "✅ OpenSearch is ready!"
        break
    fi
    echo "⏳ Attempt $attempt/$max_attempts - waiting for OpenSearch..."
    sleep 10
    ((attempt++))
done

if [ $attempt -gt $max_attempts ]; then
    echo "❌ OpenSearch failed to start properly"
    exit 1
fi

cd ..

# Load sample data
echo "📊 Loading sample data..."
./scripts/load_sample_data.sh

# Setup MCP configurations
echo "⚙️  Setting up MCP configurations..."
./scripts/setup_mcp_configs.sh

echo ""
echo "🎉 Setup completed successfully!"
echo ""
echo "📍 Next steps:"
echo "1. OpenSearch is running at: https://localhost:9200"
echo "2. OpenSearch Dashboards: https://localhost:5601"
echo "3. Default credentials: admin / yourStrongPassword123!"
echo ""
echo "🔧 Configure your LLM:"
echo "• For Claude Desktop: Copy configs/claude_desktop_config.json to ~/Library/Application Support/Claude/"
echo "• For Amazon Q: Copy configs/amazon_q_mcp.json to ~/.aws/amazonq/"
echo ""
echo "📚 Try these example queries in your LLM:"
echo "• 'Create a new index called books with title and author fields'"
echo "• 'Search for documents in the sample_books index'"
echo "• 'Show me the mapping of the sample_books index'"
echo ""
echo "🛑 To stop: docker-compose -f docker/docker-compose.yml down"
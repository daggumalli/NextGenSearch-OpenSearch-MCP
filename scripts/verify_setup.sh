#!/bin/bash

# Verify OpenSearch MCP Demo Setup
set -e

echo "🔍 Verifying NextGenSearch OpenSearch MCP Demo Setup..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
    fi
}

# Function to print warning
print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

echo ""
echo "📋 Checking Prerequisites..."

# Check Docker
if command -v docker &> /dev/null; then
    print_status 0 "Docker is installed"
    if docker ps &> /dev/null; then
        print_status 0 "Docker is running"
    else
        print_status 1 "Docker is not running"
    fi
else
    print_status 1 "Docker is not installed"
fi

# Check Docker Compose
if command -v docker-compose &> /dev/null || docker compose version &> /dev/null; then
    print_status 0 "Docker Compose is available"
else
    print_status 1 "Docker Compose is not available"
fi

# Check Python
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2)
    print_status 0 "Python 3 is installed (version $PYTHON_VERSION)"
else
    print_status 1 "Python 3 is not installed"
fi

# Check pipx
if command -v pipx &> /dev/null; then
    print_status 0 "pipx is installed"
else
    print_status 1 "pipx is not installed"
fi

echo ""
echo "🐳 Checking OpenSearch Services..."

# Check if OpenSearch container is running
if docker ps | grep -q opensearch; then
    print_status 0 "OpenSearch container is running"
    
    # Test OpenSearch API
    if curl -k -u admin:yourStrongPassword123! https://localhost:9200 &> /dev/null; then
        print_status 0 "OpenSearch API is accessible"
        
        # Get cluster health
        HEALTH=$(curl -k -s -u admin:yourStrongPassword123! https://localhost:9200/_cluster/health | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
        if [ "$HEALTH" = "green" ] || [ "$HEALTH" = "yellow" ]; then
            print_status 0 "OpenSearch cluster health: $HEALTH"
        else
            print_status 1 "OpenSearch cluster health: $HEALTH"
        fi
    else
        print_status 1 "OpenSearch API is not accessible"
    fi
else
    print_status 1 "OpenSearch container is not running"
fi

# Check if OpenSearch Dashboards container is running
if docker ps | grep -q opensearch-dashboards; then
    print_status 0 "OpenSearch Dashboards container is running"
    
    # Test Dashboards accessibility (just check if port is open)
    if nc -z localhost 5601 2>/dev/null; then
        print_status 0 "OpenSearch Dashboards is accessible on port 5601"
    else
        print_status 1 "OpenSearch Dashboards is not accessible on port 5601"
    fi
else
    print_status 1 "OpenSearch Dashboards container is not running"
fi

echo ""
echo "📦 Checking MCP Server Installation..."

# Check if opensearch-mcp-server is installed
if command -v opensearch-mcp-server &> /dev/null; then
    MCP_PATH=$(which opensearch-mcp-server)
    print_status 0 "OpenSearch MCP Server is installed at: $MCP_PATH"
else
    print_status 1 "OpenSearch MCP Server is not installed"
fi

echo ""
echo "⚙️  Checking MCP Configurations..."

# Check Claude Desktop config
CLAUDE_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
if [ -f "$CLAUDE_CONFIG" ]; then
    print_status 0 "Claude Desktop configuration exists"
    if grep -q "opensearch-mcp-server" "$CLAUDE_CONFIG"; then
        print_status 0 "Claude Desktop configuration includes OpenSearch MCP server"
    else
        print_status 1 "Claude Desktop configuration missing OpenSearch MCP server"
    fi
else
    print_warning "Claude Desktop configuration not found (only needed if using Claude)"
fi

# Check Amazon Q config
AMAZON_Q_CONFIG="$HOME/.aws/amazonq/mcp.json"
if [ -f "$AMAZON_Q_CONFIG" ]; then
    print_status 0 "Amazon Q configuration exists"
    if grep -q "opensearch-mcp-server" "$AMAZON_Q_CONFIG"; then
        print_status 0 "Amazon Q configuration includes OpenSearch MCP server"
    else
        print_status 1 "Amazon Q configuration missing OpenSearch MCP server"
    fi
else
    print_warning "Amazon Q configuration not found (only needed if using Amazon Q)"
fi

echo ""
echo "📊 Checking Sample Data..."

if curl -k -u admin:yourStrongPassword123! https://localhost:9200 &> /dev/null; then
    # Check for sample indices
    INDICES=$(curl -k -s -u admin:yourStrongPassword123! https://localhost:9200/_cat/indices?h=index | grep -E "sample_")
    
    if echo "$INDICES" | grep -q "sample_books"; then
        BOOK_COUNT=$(curl -k -s -u admin:yourStrongPassword123! https://localhost:9200/sample_books/_count | grep -o '"count":[0-9]*' | cut -d':' -f2)
        print_status 0 "sample_books index exists with $BOOK_COUNT documents"
    else
        print_status 1 "sample_books index not found"
    fi
    
    if echo "$INDICES" | grep -q "sample_products"; then
        PRODUCT_COUNT=$(curl -k -s -u admin:yourStrongPassword123! https://localhost:9200/sample_products/_count | grep -o '"count":[0-9]*' | cut -d':' -f2)
        print_status 0 "sample_products index exists with $PRODUCT_COUNT documents"
    else
        print_status 1 "sample_products index not found"
    fi
else
    print_status 1 "Cannot check sample data - OpenSearch not accessible"
fi

echo ""
echo "🔐 Checking SSL Certificates..."

if [ -d "docker/certs" ]; then
    if [ -f "docker/certs/root-ca.pem" ] && [ -f "docker/certs/node.pem" ] && [ -f "docker/certs/node-key.pem" ]; then
        print_status 0 "SSL certificates are present"
        
        # Check certificate validity
        if openssl x509 -in docker/certs/node.pem -noout -checkend 86400 &> /dev/null; then
            print_status 0 "SSL certificates are valid"
        else
            print_status 1 "SSL certificates are expired or invalid"
        fi
    else
        print_status 1 "SSL certificates are missing"
    fi
else
    print_status 1 "SSL certificates directory not found"
fi

echo ""
echo "📝 Setup Summary:"
echo "=================="

# Overall status
OPENSEARCH_RUNNING=$(docker ps | grep -q opensearch && echo "true" || echo "false")
MCP_INSTALLED=$(command -v opensearch-mcp-server &> /dev/null && echo "true" || echo "false")
CONFIG_EXISTS=$([ -f "$CLAUDE_CONFIG" ] || [ -f "$AMAZON_Q_CONFIG" ] && echo "true" || echo "false")

if [ "$OPENSEARCH_RUNNING" = "true" ] && [ "$MCP_INSTALLED" = "true" ] && [ "$CONFIG_EXISTS" = "true" ]; then
    echo -e "${GREEN}🎉 Setup appears to be complete and working!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Restart your LLM application (Claude Desktop or Amazon Q)"
    echo "2. Try a test query: 'Show me all available indices in OpenSearch'"
    echo "3. Explore the examples in examples/natural_language_queries.md"
else
    echo -e "${YELLOW}⚠️  Setup is incomplete. Please address the issues above.${NC}"
    echo ""
    echo "Common fixes:"
    echo "• Run './setup.sh' to complete the setup"
    echo "• Install missing prerequisites"
    echo "• Check Docker service status"
fi

echo ""
echo "🔗 Useful URLs:"
echo "• OpenSearch API: https://localhost:9200"
echo "• OpenSearch Dashboards: https://localhost:5601"
echo "• Default credentials: admin / yourStrongPassword123!"

echo ""
echo "📚 Documentation:"
echo "• Setup Guide: docs/SETUP_GUIDE.md"
echo "• Query Examples: examples/natural_language_queries.md"
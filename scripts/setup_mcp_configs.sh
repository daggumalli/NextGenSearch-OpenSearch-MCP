#!/bin/bash

# Setup MCP configurations for different LLMs
set -e

echo "⚙️  Setting up MCP configurations..."

# Get the current user's home directory
USER_HOME=$(eval echo ~$USER)

echo "🔍 Using uvx to run opensearch-mcp-server-py"

# Update Claude Desktop config
echo "🤖 Updating Claude Desktop configuration..."
CLAUDE_CONFIG_DIR="$USER_HOME/Library/Application Support/Claude"
mkdir -p "$CLAUDE_CONFIG_DIR"

# Auto-detect uvx path for cross-platform compatibility
echo "🔍 Auto-detecting uvx path..."

# Try multiple common locations for uvx
UVX_PATH=""
POSSIBLE_PATHS=(
    "$(which uvx 2>/dev/null)"
    "$USER_HOME/.local/bin/uvx"
    "/usr/local/bin/uvx"
    "/opt/homebrew/bin/uvx"
)

for path in "${POSSIBLE_PATHS[@]}"; do
    if [ -n "$path" ] && [ -f "$path" ]; then
        UVX_PATH="$path"
        break
    fi
done

# Fallback to default if not found
if [ -z "$UVX_PATH" ]; then
    UVX_PATH="$USER_HOME/.local/bin/uvx"
    echo "⚠️  uvx not found in common locations, using default: $UVX_PATH"
    echo "   If MCP server fails to start, ensure uv/uvx is properly installed"
else
    echo "✅ Found uvx at: $UVX_PATH"
fi

# Create Claude config with uvx
cat > "$CLAUDE_CONFIG_DIR/claude_desktop_config.json" << EOF
{
  "mcpServers": {
    "opensearch-mcp-server": {
      "command": "$UVX_PATH",
      "args": ["opensearch-mcp-server-py"],
      "env": {
        "OPENSEARCH_URL": "https://localhost:9200",
        "OPENSEARCH_USERNAME": "admin",
        "OPENSEARCH_PASSWORD": "yourStrongPassword123!",
        "OPENSEARCH_VERIFY_CERTS": "false",
        "OPENSEARCH_SSL_VERIFY": "false",
        "OPENSEARCH_USE_SSL": "true"
      }
    }
  }
}
EOF

echo "✅ Claude Desktop configuration updated at: $CLAUDE_CONFIG_DIR/claude_desktop_config.json"

# Update Amazon Q config
echo "🔶 Updating Amazon Q configuration..."
AMAZON_Q_CONFIG_DIR="$USER_HOME/.aws/amazonq"
mkdir -p "$AMAZON_Q_CONFIG_DIR"

# Create Amazon Q config with uvx
cat > "$AMAZON_Q_CONFIG_DIR/mcp.json" << EOF
{
  "mcpServers": {
    "opensearch-mcp-server": {
      "command": "$UVX_PATH",
      "args": ["opensearch-mcp-server-py"],
      "env": {
        "OPENSEARCH_URL": "https://localhost:9200",
        "OPENSEARCH_USERNAME": "admin",
        "OPENSEARCH_PASSWORD": "yourStrongPassword123!",
        "OPENSEARCH_VERIFY_CERTS": "false",
        "OPENSEARCH_SSL_VERIFY": "false",
        "OPENSEARCH_USE_SSL": "true"
      }
    }
  }
}
EOF

echo "✅ Amazon Q configuration updated at: $AMAZON_Q_CONFIG_DIR/mcp.json"

# Update local config files with correct paths
echo "📝 Updating local configuration templates..."

# Update Claude config template
cat > "configs/claude_desktop_config.json" << EOF
{
  "mcpServers": {
    "opensearch-mcp-server": {
      "command": "$UVX_PATH",
      "args": ["opensearch-mcp-server-py"],
      "env": {
        "OPENSEARCH_URL": "https://localhost:9200",
        "OPENSEARCH_USERNAME": "admin",
        "OPENSEARCH_PASSWORD": "yourStrongPassword123!",
        "OPENSEARCH_VERIFY_CERTS": "false",
        "OPENSEARCH_SSL_VERIFY": "false",
        "OPENSEARCH_USE_SSL": "true"
      }
    }
  }
}
EOF

# Update Amazon Q config template
cat > "configs/amazon_q_mcp.json" << EOF
{
  "mcpServers": {
    "opensearch-mcp-server": {
      "command": "$UVX_PATH",
      "args": ["opensearch-mcp-server-py"],
      "env": {
        "OPENSEARCH_URL": "https://localhost:9200",
        "OPENSEARCH_USERNAME": "admin",
        "OPENSEARCH_PASSWORD": "yourStrongPassword123!",
        "OPENSEARCH_VERIFY_CERTS": "false",
        "OPENSEARCH_SSL_VERIFY": "false",
        "OPENSEARCH_USE_SSL": "true"
      }
    }
  }
}
EOF

echo "✅ Local configuration templates updated"

echo ""
echo "🎯 MCP Configuration Summary:"
echo "• Claude Desktop: $CLAUDE_CONFIG_DIR/claude_desktop_config.json"
echo "• Amazon Q: $AMAZON_Q_CONFIG_DIR/mcp.json"
echo "• MCP Server Path: $UVX_PATH"
echo "• MCP Server Command: uvx opensearch-mcp-server-py"
echo ""
echo "🔄 Please restart your LLM applications to load the new configurations"
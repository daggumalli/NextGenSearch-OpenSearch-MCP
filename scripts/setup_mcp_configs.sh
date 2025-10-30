#!/bin/bash

# Setup MCP configurations for different LLMs
set -e

echo "⚙️  Setting up MCP configurations..."

# Get the current user's home directory
USER_HOME=$(eval echo ~$USER)

# Get the opensearch-mcp-server path
MCP_SERVER_PATH=$(which opensearch-mcp-server 2>/dev/null || echo "$USER_HOME/.local/bin/opensearch-mcp-server")

echo "🔍 Detected MCP server path: $MCP_SERVER_PATH"

# Update Claude Desktop config
echo "🤖 Updating Claude Desktop configuration..."
CLAUDE_CONFIG_DIR="$USER_HOME/Library/Application Support/Claude"
mkdir -p "$CLAUDE_CONFIG_DIR"

# Create Claude config with correct path
cat > "$CLAUDE_CONFIG_DIR/claude_desktop_config.json" << EOF
{
  "mcpServers": {
    "opensearch-mcp-server": {
      "command": "$MCP_SERVER_PATH",
      "args": [],
      "env": {
        "OPENSEARCH_URL": "https://localhost:9200",
        "OPENSEARCH_SSL_VERIFY": "none",
        "OPENSEARCH_USERNAME": "admin",
        "OPENSEARCH_PASSWORD": "yourStrongPassword123!"
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

# Create Amazon Q config with correct path
cat > "$AMAZON_Q_CONFIG_DIR/mcp.json" << EOF
{
  "mcpServers": {
    "opensearch-mcp-server": {
      "command": "$MCP_SERVER_PATH",
      "args": [],
      "env": {
        "OPENSEARCH_URL": "https://localhost:9200",
        "OPENSEARCH_SSL_VERIFY": "none",
        "OPENSEARCH_USERNAME": "admin",
        "OPENSEARCH_PASSWORD": "yourStrongPassword123!"
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
      "command": "$MCP_SERVER_PATH",
      "args": [],
      "env": {
        "OPENSEARCH_URL": "https://localhost:9200",
        "OPENSEARCH_SSL_VERIFY": "none",
        "OPENSEARCH_USERNAME": "admin",
        "OPENSEARCH_PASSWORD": "yourStrongPassword123!"
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
      "command": "$MCP_SERVER_PATH",
      "args": [],
      "env": {
        "OPENSEARCH_URL": "https://localhost:9200",
        "OPENSEARCH_SSL_VERIFY": "none",
        "OPENSEARCH_USERNAME": "admin",
        "OPENSEARCH_PASSWORD": "yourStrongPassword123!"
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
echo "• MCP Server Path: $MCP_SERVER_PATH"
echo ""
echo "🔄 Please restart your LLM applications to load the new configurations"
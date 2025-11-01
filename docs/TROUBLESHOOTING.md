# Troubleshooting Guide

This guide helps you resolve common issues when setting up and using the NextGenSearch OpenSearch MCP Demo.

## 🔄 How It Works

**Simple Flow**: User → Claude Desktop → MCP Server → OpenSearch → Results

1. **User Query**: "Search for books by Orwell" → Claude Desktop
2. **MCP Protocol**: Claude → OpenSearch MCP Server (via uvx)
3. **API Translation**: MCP Server converts to OpenSearch query
4. **HTTP Request**: MCP Server → OpenSearch Service (localhost:9200)
5. **Response Chain**: OpenSearch → MCP Server → Claude → User

---

## 🔧 Common Issues & Solutions

### 1. uvx Path Issues

**Problem**: `spawn uvx ENOENT` or `uvx command not found`

**Symptoms**:
```
[error] spawn uvx ENOENT
[error] Server disconnected
```

**Solutions**:

#### Check uvx Installation:
```bash
# macOS/Linux
which uvx
ls -la ~/.local/bin/uvx

# Windows
where uvx
dir %USERPROFILE%\.local\bin\uvx.exe
```

#### Fix PATH Issues:
```bash
# macOS/Linux - Add to ~/.zprofile or ~/.bashrc
export PATH="$HOME/.local/bin:$PATH"

# Windows - Add to system PATH
set PATH=%USERPROFILE%\.local\bin;%PATH%
```

#### Reinstall uv/uvx:
```bash
# macOS/Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# Windows (PowerShell)
irm https://astral.sh/uv/install.ps1 | iex
```

#### Manual Path Configuration:
Update your MCP config with the full path:
```json
{
  "mcpServers": {
    "opensearch-mcp-server": {
      "command": "/Users/YOUR_USERNAME/.local/bin/uvx",  // macOS/Linux
      "command": "C:\\Users\\YOUR_USERNAME\\.local\\bin\\uvx.exe",  // Windows
      "args": ["opensearch-mcp-server-py"]
    }
  }
}
```

---

### 2. Python Version Issues

**Problem**: `ERROR: Requires-Python >=3.10`

**Symptoms**:
```
ERROR: Could not find a version that satisfies the requirement opensearch-mcp-server>=2.0.0
ERROR: No matching distribution found for opensearch-mcp-server>=2.0.0
```

**Solutions**:

#### Check Python Version:
```bash
python3 --version
python --version
```

#### Update Python:
```bash
# macOS (Homebrew)
brew install python@3.11

# Windows
# Download from python.org or use Microsoft Store

# Linux (Ubuntu/Debian)
sudo apt update
sudo apt install python3.11
```

#### Use Specific Python Version:
```bash
# Force uvx to use specific Python
uvx --python python3.11 opensearch-mcp-server-py --help
```

---

### 3. MCP Server Installation Failures

**Problem**: MCP server fails to download or run

**Symptoms**:
```
[error] Server transport closed unexpectedly
[error] Server disconnected
```

**Solutions**:

#### Test MCP Server Manually:
```bash
# Test if uvx can download and run the server
uvx opensearch-mcp-server-py --help
```

#### Check Network Connectivity:
```bash
# Test PyPI access
curl -I https://pypi.org/simple/opensearch-mcp-server-py/
```

#### Clear uvx Cache:
```bash
# Clear uvx cache and retry
rm -rf ~/.cache/uv  # macOS/Linux
rmdir /s %LOCALAPPDATA%\uv\cache  # Windows
```

#### Use Alternative Installation:
```bash
# Install with pip instead of uvx
pip install opensearch-mcp-server-py

# Then update config to use direct path
"command": "opensearch-mcp-server-py"
```

---

### 4. SSL Certificate Issues

**Problem**: SSL verification errors

**Symptoms**:
```
SSL certificate verification failed
certificate verify failed: self signed certificate
```

**Solutions**:

#### Verify SSL Environment Variables:
```json
{
  "env": {
    "OPENSEARCH_URL": "https://localhost:9200",
    "OPENSEARCH_VERIFY_CERTS": "false",
    "OPENSEARCH_SSL_VERIFY": "false",
    "OPENSEARCH_USE_SSL": "true"
  }
}
```

#### Test OpenSearch Connection:
```bash
# Test with curl (should work)
curl -k -u admin:yourStrongPassword123! https://localhost:9200

# If this fails, OpenSearch isn't running properly
```

#### Regenerate Certificates:
```bash
# Remove old certificates
rm -rf docker/certs

# Run setup again to regenerate
./setup.sh  # macOS/Linux
setup.bat   # Windows
```

---

### 5. OpenSearch Service Issues

**Problem**: OpenSearch container fails to start

**Symptoms**:
```
Error response from daemon: port is already allocated
OpenSearch cluster health: red
```

**Solutions**:

#### Check Port Conflicts:
```bash
# Check what's using port 9200
lsof -i :9200  # macOS/Linux
netstat -ano | findstr :9200  # Windows
```

#### Stop Conflicting Services:
```bash
# Stop existing OpenSearch containers
docker stop $(docker ps -q --filter ancestor=opensearchproject/opensearch)
docker rm $(docker ps -aq --filter ancestor=opensearchproject/opensearch)
```

#### Check Docker Resources:
```bash
# Ensure Docker has enough memory (minimum 4GB recommended)
docker system info | grep Memory
```

#### View OpenSearch Logs:
```bash
docker-compose -f docker/docker-compose.yml logs opensearch
```

---

### 6. Configuration File Issues

**Problem**: MCP configuration not loading

**Symptoms**:
- No MCP tools available in Claude
- "Server not found" errors

**Solutions**:

#### Verify Config File Location:
```bash
# macOS
ls -la ~/Library/Application\ Support/Claude/claude_desktop_config.json

# Windows
dir "%APPDATA%\Claude\claude_desktop_config.json"

# Linux
ls -la ~/.config/Claude/claude_desktop_config.json
```

#### Validate JSON Syntax:
```bash
# Use online JSON validator or:
python -m json.tool claude_desktop_config.json
```

#### Check File Permissions:
```bash
# macOS/Linux
chmod 644 ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

#### Restart Claude Desktop:
- Completely quit Claude Desktop
- Wait 5 seconds
- Restart Claude Desktop
- Check for MCP tools in a new conversation

---

## 🔍 Diagnostic Commands

### System Check:
```bash
# Check all prerequisites
echo "=== System Information ==="
uname -a
echo "=== Docker ==="
docker --version && docker ps
echo "=== Python ==="
python3 --version
echo "=== uv/uvx ==="
uv --version && which uvx
echo "=== OpenSearch ==="
curl -k -u admin:yourStrongPassword123! https://localhost:9200
```

### MCP Server Test:
```bash
# Test MCP server directly
uvx opensearch-mcp-server-py --help

# Test with environment variables
OPENSEARCH_URL=https://localhost:9200 \
OPENSEARCH_USERNAME=admin \
OPENSEARCH_PASSWORD=yourStrongPassword123! \
OPENSEARCH_VERIFY_CERTS=false \
uvx opensearch-mcp-server-py
```

### Configuration Validation:
```bash
# Check if config files exist and are valid
echo "=== Claude Config ==="
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json | python -m json.tool

echo "=== Amazon Q Config ==="
cat ~/.aws/amazonq/mcp.json | python -m json.tool
```

---

## 📞 Getting Help

### Log Collection:
When reporting issues, please include:

1. **System Information**:
   ```bash
   uname -a  # macOS/Linux
   systeminfo  # Windows
   ```

2. **Docker Logs**:
   ```bash
   docker-compose -f docker/docker-compose.yml logs
   ```

3. **MCP Server Logs**:
   - Check Claude Desktop logs (usually in application data folder)
   - Run MCP server manually to see error output

4. **Configuration Files**:
   - Your `claude_desktop_config.json` (remove passwords)
   - Output of diagnostic commands above

### Common Log Locations:
- **macOS Claude**: `~/Library/Logs/Claude/`
- **Windows Claude**: `%APPDATA%\Claude\logs\`
- **Docker**: `docker-compose logs opensearch`

### Community Support:
- Create an issue in the GitHub repository
- Include all diagnostic information
- Describe exact steps that led to the problem
- Mention your operating system and versions

---

## 🚀 Performance Optimization

### Memory Settings:
```yaml
# In docker-compose.yml, adjust based on your system
environment:
  - "OPENSEARCH_JAVA_OPTS=-Xms1g -Xmx2g"  # For 8GB+ systems
```

### Network Optimization:
```bash
# Increase Docker network timeout if needed
export COMPOSE_HTTP_TIMEOUT=120
```

### Index Optimization:
```bash
# Optimize indices for better performance
curl -X PUT "https://localhost:9200/sample_books/_settings" \
  -u admin:yourStrongPassword123! \
  -H "Content-Type: application/json" \
  -d '{"index": {"refresh_interval": "30s"}}'
```
# OpenSearch MCP Integration Setup Guide

This guide provides detailed step-by-step instructions for integrating Amazon Q & Anthropic Claude Desktop with OpenSearch using MCP servers for natural language interactions.

## Prerequisites

- Docker and Docker Compose installed
- Python 3.x installed
- pipx installed (`pip install pipx`)
- Amazon Q CLI or Anthropic Claude Desktop
- Minimum 16GB RAM (32GB recommended for optimal performance)

## 1. Setting up Local OpenSearch Instance

### Option A: Automated Setup (Recommended)

1. Clone this repository:
```bash
git clone <your-repo-url>
cd NextGenSearch-OpenSearch-MCP
```

2. Run the automated setup:
```bash
./setup.sh
```

This will handle everything automatically including SSL certificates, OpenSearch startup, sample data loading, and MCP configuration.

### Option B: Manual Setup

1. Create a new directory for your project:
```bash
mkdir opensearch-mcp && cd opensearch-mcp
```

2. Create SSL certificates:
```bash
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
```

3. Create the `docker-compose.yml` file (use the one from this repository)

4. Start the containers:
```bash
cd docker
docker-compose up -d
```

## 2. Installing OpenSearch MCP Server

Install the OpenSearch MCP server using pipx:
```bash
pipx install opensearch-mcp-server
```

## 3. Configuring LLMs with MCP Server

### For Anthropic Claude Desktop

Create or update the configuration file at:
`~/Library/Application Support/Claude/claude_desktop_config.json`

```json
{
  "mcpServers": {
    "opensearch-mcp-server": {
      "command": "/Users/YOUR_USERNAME/.local/bin/opensearch-mcp-server",
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
```

### For Amazon Q

Create or update the configuration file at:
`~/.aws/amazonq/mcp.json`

```json
{
  "mcpServers": {
    "opensearch-mcp-server": {
      "command": "/Users/YOUR_USERNAME/.local/bin/opensearch-mcp-server",
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
```

**Important**: Replace `YOUR_USERNAME` with your actual system username.

## 4. Verifying the Setup

### Check OpenSearch Status
```bash
curl -k -u admin:yourStrongPassword123! https://localhost:9200
```

### Verify OpenSearch Dashboards
Open https://localhost:5601 in your browser and log in with:
- Username: `admin`
- Password: `yourStrongPassword123!`

### Check Available Indices
```bash
curl -k -u admin:yourStrongPassword123! https://localhost:9200/_cat/indices
```

### Test MCP Integration
1. Restart your LLM application (Claude Desktop or Amazon Q)
2. Try a simple query like: "Show me all available indices in OpenSearch"
3. If successful, you should see the MCP server responding with index information

## 5. Using Natural Language with OpenSearch

Here are some example commands you can try in your LLM:

### Basic Operations
- `Create a new index called "books" with title and author fields`
- `Add a document to the books index with title "The Great Gatsby" and author "F. Scott Fitzgerald"`
- `Search for books by F. Scott Fitzgerald`
- `Show me the mapping of the books index`

### Advanced Queries
- `Find all products in the Electronics category that cost less than $100`
- `Search for books published after 1950 with rating above 4.0`
- `Show me the average price of products by category`

See the [Natural Language Query Examples](../examples/natural_language_queries.md) for more detailed examples.

## 6. Troubleshooting

### MCP Server Issues

**Problem**: MCP server fails to initialize
**Solutions**:
- Check if OpenSearch is running: `docker ps`
- Verify credentials in configuration files
- Check OpenSearch logs: `docker-compose -f docker/docker-compose.yml logs opensearch`
- Ensure the MCP server path is correct in your configuration

**Problem**: Tools are not available in LLM
**Solutions**:
- Restart your LLM application
- Check MCP server logs
- Verify the configuration file syntax
- Ensure the opensearch-mcp-server is installed and accessible

### OpenSearch Issues

**Problem**: OpenSearch fails to start
**Solutions**:
- Check available memory (minimum 16GB recommended)
- Verify Docker has sufficient resources allocated
- Check for port conflicts (9200, 9600, 5601)
- Review Docker logs for specific error messages

**Problem**: SSL certificate errors
**Solutions**:
- Regenerate certificates using the provided script
- Ensure certificate files are in the correct location
- Check file permissions on certificate files

### Connection Issues

**Problem**: Cannot connect to OpenSearch
**Solutions**:
- Verify OpenSearch is running and healthy
- Check firewall settings
- Ensure correct URL and credentials
- Test connection manually with curl

## 7. Security Considerations

### Development Environment
- The default password `yourStrongPassword123!` is for demo purposes only
- SSL verification is disabled for local development
- Self-signed certificates are used

### Production Environment
- Use strong, unique passwords
- Enable proper SSL verification
- Use certificates from a trusted CA
- Implement proper network security
- Regularly rotate credentials
- Enable audit logging

## 8. Performance Optimization

### Memory Settings
- Adjust `OPENSEARCH_JAVA_OPTS` based on available system memory
- For systems with 32GB+ RAM, consider increasing to `-Xms1g -Xmx1g`

### Index Settings
- Configure appropriate number of shards and replicas
- Use proper field mappings for better performance
- Consider index templates for consistent settings

### Query Optimization
- Use filters instead of queries when possible
- Implement proper pagination for large result sets
- Consider using search templates for complex queries

## 9. Additional Resources

- [OpenSearch Documentation](https://opensearch.org/docs/latest/)
- [Amazon Q Documentation](https://docs.aws.amazon.com/amazonq/)
- [Anthropic Claude Documentation](https://docs.anthropic.com/)
- [MCP Protocol Documentation](https://modelcontextprotocol.io/introduction)
- [OpenSearch MCP Server GitHub](https://github.com/opensearch-project/opensearch-mcp-server)

## 10. Getting Help

If you encounter issues:

1. Check the troubleshooting section above
2. Review the logs from OpenSearch and your LLM
3. Verify your configuration files
4. Test components individually
5. Create an issue in this repository with detailed error information

## 11. Contributing

We welcome contributions! Please see our contributing guidelines for:
- Bug reports
- Feature requests
- Documentation improvements
- Code contributions
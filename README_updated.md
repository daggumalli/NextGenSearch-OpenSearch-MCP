# NextGenSearch OpenSearch MCP Demo

A complete demonstration project showcasing OpenSearch integration with Model Context Protocol (MCP) for natural language interactions with Amazon Q and Anthropic Claude Desktop.

## 🚀 Quick Start

Clone this repository and get up and running in minutes:

```bash
git clone https://github.com/daggumalli/NextGenSearch-OpenSearch-MCP.git
cd NextGenSearch-OpenSearch-MCP
./setup.sh
```

## 📋 Prerequisites

- Docker and Docker Compose installed
- Python 3.10+ installed
- uv installed (Python package manager) - automatically installed by setup script
- Amazon Q CLI or Anthropic Claude Desktop
- Minimum 16GB RAM (32GB recommended)

## 🏗️ What's Included

- **Local OpenSearch Instance**: Complete Docker setup with security enabled
- **Sample Data**: Pre-loaded datasets for immediate testing
- **MCP Server Configuration**: Ready-to-use configurations for both Amazon Q and Claude
- **Example Queries**: Natural language examples to get you started
- **Automated Setup**: One-command deployment

## 📁 Project Structure

```
├── docker/                 # Docker configurations
│   ├── docker-compose.yml  # OpenSearch and Dashboards setup
│   └── certs/              # SSL certificates (generated)
├── data/                   # Sample datasets
│   └── sample_datasets.json
├── configs/               # MCP configurations
│   ├── claude_desktop_config.json
│   └── amazon_q_mcp.json
├── scripts/               # Setup and utility scripts
│   ├── load_sample_data.sh
│   └── setup_mcp_configs.sh
├── examples/              # Example queries and use cases
│   └── natural_language_queries.md
├── docs/                  # Additional documentation
│   └── SETUP_GUIDE.md
└── setup.sh              # Main setup script
```

## 🚀 Quick Start

1. **Clone and Setup**:
```bash
git clone https://github.com/daggumalli/NextGenSearch-OpenSearch-MCP.git
cd NextGenSearch-OpenSearch-MCP
./setup.sh
```

2. **Access OpenSearch**:
   - OpenSearch API: https://localhost:9200
   - OpenSearch Dashboards: https://localhost:5601
   - Default credentials: `admin` / `yourStrongPassword123!`

3. **Configure Your LLM**:
   - The setup script automatically configures both Claude Desktop and Amazon Q
   - **Auto-detects the correct uvx path** for your system
   - Restart your LLM application to load the new configuration

4. **Try Natural Language Queries**:
   ```
   "Show me all available indices"
   "Search for books by George Orwell"
   "Create a new index called 'users' with name and email fields"
   ```

## 🔧 Manual Setup

If you prefer manual setup or need to customize the configuration, see our [detailed setup guide](docs/SETUP_GUIDE.md).

## 📊 Sample Data

The demo includes three pre-loaded indices with sample data:

- **sample_books**: Classic literature with metadata
- **sample_products**: E-commerce product catalog
- **sample_articles**: Technology articles and blog posts

## 💡 Example Use Cases

### E-commerce Search
```
"Find all electronics under $100 that are in stock"
"Show me the most expensive products by category"
"Search for wireless products with good ratings"
```

### Content Management
```
"Find articles about search technology published this year"
"Search for books by publication decade"
"Show me the most popular articles by views"
```

### Data Analysis
```
"What's the average rating of books by genre?"
"Count products by category and stock status"
"Show me price distribution across all products"
```

## 🛠️ Troubleshooting

### Common Issues

**MCP Server Not Found**:
- Ensure `uv` is installed: The setup script installs this automatically
- Check that `uvx` command is available in your PATH
- Restart your LLM application

**OpenSearch Connection Failed**:
- Verify OpenSearch is running: `docker ps`
- Check logs: `docker-compose -f docker/docker-compose.yml logs opensearch`
- Ensure ports 9200 and 5601 are available

**Python Version Issues**:
- OpenSearch MCP Server requires Python 3.10+
- Update Python if you have an older version
- The setup script will check and warn about version compatibility

**SSL Certificate Issues**:
- Regenerate certificates: `rm -rf docker/certs && ./setup.sh`
- Check certificate permissions

For detailed troubleshooting, see our [setup guide](docs/SETUP_GUIDE.md#troubleshooting).

## 🔒 Security Notes

This demo uses development-friendly settings:
- Self-signed SSL certificates
- Default passwords
- Disabled SSL verification

For production use:
- Use strong, unique passwords
- Implement proper SSL certificates
- Enable SSL verification
- Configure proper network security

## 🤝 Contributing

We welcome contributions! Please feel free to:
- Report bugs
- Suggest features
- Submit pull requests
- Improve documentation

## 📚 Additional Resources

- [OpenSearch Documentation](https://opensearch.org/docs/latest/)
- [MCP Protocol Documentation](https://modelcontextprotocol.io/introduction)
- [Natural Language Query Examples](examples/natural_language_queries.md)
- [Detailed Setup Guide](docs/SETUP_GUIDE.md)

## 🛑 Stopping the Demo

To stop all services:
```bash
docker-compose -f docker/docker-compose.yml down
```

To remove all data:
```bash
docker-compose -f docker/docker-compose.yml down -v
```

---

**Happy Searching!** 🔍✨
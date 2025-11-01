@echo off
REM NextGenSearch OpenSearch MCP Demo Setup Script for Windows
setlocal enabledelayedexpansion

echo 🚀 Setting up NextGenSearch OpenSearch MCP Demo...

REM Check prerequisites
echo 📋 Checking prerequisites...

where docker >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Docker is not installed. Please install Docker Desktop first.
    pause
    exit /b 1
)

where python >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Python is not installed. Please install Python 3.10+ first.
    pause
    exit /b 1
)

echo ✅ Prerequisites check completed

REM Install uv (Python package manager)
echo 📦 Installing uv (Python package manager)...
powershell -Command "irm https://astral.sh/uv/install.ps1 | iex"

REM Add uv to PATH for current session
set PATH=%USERPROFILE%\.local\bin;%PATH%

echo ✅ uv installed successfully
echo ℹ️  OpenSearch MCP Server will be automatically downloaded when first used via uvx

REM Generate SSL certificates for OpenSearch
echo 🔐 Generating SSL certificates...
if not exist "docker\certs" mkdir docker\certs
cd docker\certs

REM Generate root CA
openssl genrsa -out root-ca-key.pem 2048
openssl req -new -x509 -sha256 -key root-ca-key.pem -out root-ca.pem -days 730 -subj "/C=US/ST=CA/L=San Francisco/O=OpenSearch/OU=Demo/CN=root"

REM Generate node certificate
openssl genrsa -out node-key.pem 2048
openssl req -new -key node-key.pem -out node.csr -subj "/C=US/ST=CA/L=San Francisco/O=OpenSearch/OU=Demo/CN=localhost"
openssl x509 -req -in node.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -sha256 -out node.pem -days 730

cd ..\..

REM Start OpenSearch
echo 🐳 Starting OpenSearch containers...
docker-compose -f docker/docker-compose.yml up -d

echo ⏳ Waiting for OpenSearch to be ready...
timeout /t 30 /nobreak >nul

REM Wait for OpenSearch to be healthy
set /a attempt=1
:wait_loop
curl -k -u admin:yourStrongPassword123! https://localhost:9200 >nul 2>nul
if %errorlevel% equ 0 (
    echo ✅ OpenSearch is ready!
    goto :opensearch_ready
)
echo ⏳ Attempt %attempt%/30 - waiting for OpenSearch...
timeout /t 10 /nobreak >nul
set /a attempt+=1
if %attempt% leq 30 goto :wait_loop

echo ❌ OpenSearch failed to start properly
pause
exit /b 1

:opensearch_ready

REM Load sample data
echo 📊 Loading sample data...
call scripts\load_sample_data.bat

REM Setup MCP configurations
echo ⚙️  Setting up MCP configurations...
call scripts\setup_mcp_configs.bat

echo.
echo 🎉 Setup completed successfully!
echo.
echo 📍 Next steps:
echo 1. OpenSearch is running at: https://localhost:9200
echo 2. OpenSearch Dashboards: https://localhost:5601
echo 3. Default credentials: admin / yourStrongPassword123!
echo.
echo 🔧 Configure your LLM:
echo • For Claude Desktop: Configuration updated automatically
echo • For Amazon Q: Configuration updated automatically
echo.
echo 📚 Try these example queries in your LLM:
echo • 'Create a new index called books with title and author fields'
echo • 'Search for documents in the sample_books index'
echo • 'Show me the mapping of the sample_books index'
echo.
echo 🛑 To stop: docker-compose -f docker/docker-compose.yml down
pause
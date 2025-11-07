@echo off
REM NextGenSearch OpenSearch MCP Demo Setup Script for Windows
setlocal enabledelayedexpansion

echo Setting up NextGenSearch OpenSearch MCP Demo...

REM Check prerequisites
echo Checking prerequisites...

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

echo Prerequisites check completed

REM Install uv (Python package manager)
echo Installing uv (Python package manager)...
powershell -Command "irm https://astral.sh/uv/install.ps1 | iex"

REM Add uv to PATH for current session
set PATH=%USERPROFILE%\.local\bin;%PATH%

echo uv installed successfully
echo Note: OpenSearch MCP Server will be automatically downloaded when first used via uvx

REM Generate SSL certificates for OpenSearch
echo Generating SSL certificates...
if not exist "docker\certs" mkdir docker\certs

REM If openssl is available locally, use it; otherwise use Docker. Use goto labels to avoid parsing large parenthesized blocks.
where openssl >nul 2>nul
if %errorlevel% equ 0 (
    goto :GEN_NATIVE_CERTS
) else (
    goto :GEN_DOCKER_CERTS
)

:GEN_NATIVE_CERTS
echo Found OpenSSL locally — generating certs natively...
if not exist "docker\certs" mkdir docker\certs
pushd docker\certs
REM Generate root CA
openssl genrsa -out root-ca-key.pem 2048
openssl req -new -x509 -sha256 -key root-ca-key.pem -out root-ca.pem -days 730 -subj "/C=US/ST=CA/L=San Francisco/O=OpenSearch/OU=Demo/CN=root"
REM Generate node certificate
openssl genrsa -out node-key.pem 2048
openssl req -new -key node-key.pem -out node.csr -subj "/C=US/ST=CA/L=San Francisco/O=OpenSearch/OU=Demo/CN=localhost"
openssl x509 -req -in node.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -sha256 -out node.pem -days 730
popd
goto :AFTER_CERTS

:GEN_DOCKER_CERTS
echo OpenSSL not found locally. Generating certs using Docker (alpine + openssl)...
if not exist "docker\certs" mkdir docker\certs
set "CERTS_HOST_PATH=%CD%\docker\certs"
echo Running Docker to generate certs into %CERTS_HOST_PATH%
docker run --rm -v "%CERTS_HOST_PATH%:/certs" -w /certs alpine sh -c "apk add --no-cache openssl >/dev/null 2>&1 && openssl genrsa -out root-ca-key.pem 2048 && openssl req -new -x509 -sha256 -key root-ca-key.pem -out root-ca.pem -days 730 -subj '/C=US/ST=CA/L=San Francisco/O=OpenSearch/OU=Demo/CN=root' && openssl genrsa -out node-key.pem 2048 && openssl req -new -key node-key.pem -out node.csr -subj '/C=US/ST=CA/L=San Francisco/O=OpenSearch/OU=Demo/CN=localhost' && openssl x509 -req -in node.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -sha256 -out node.pem -days 730"
goto :AFTER_CERTS

:AFTER_CERTS
REM Ensure the cert files are readable by Docker by granting read permissions to Everyone (Windows ACL)
echo Setting Windows ACLs for docker\certs (granting read to Everyone)...
icacls "docker\certs" /grant Everyone:(R) /T >nul 2>nul || echo Warning: icacls failed or insufficient permissions to change ACLs


REM Show created certs
echo Certificates in docker\certs:
dir /b docker\certs

REM Windows Docker permission fix: Use named volume for certificates
REM Why: Docker Desktop on Windows has persistent issues with bind mount permissions for SSL certificates
REM The opensearch container cannot read certificate files mounted via bind mounts (./certs:/path)
REM Solution: Copy certs to a named volume with proper Linux permissions (644)
REM Note: This is a Windows-specific workaround - Linux/macOS use bind mounts directly
echo Setting up certificate volume for Docker (Windows compatibility fix)...
docker volume create opensearch-certs >nul 2>nul
docker run --rm -v opensearch-certs:/certs -v "%CD%\docker\certs":/host-certs alpine sh -c "cp -r /host-certs/* /certs/ && chmod -R 644 /certs/*.pem && chmod 644 /certs/*.csr" >nul 2>nul

REM Create docker-compose.override.yml for Windows compatibility
REM Why: Keeps main docker-compose.yml portable while applying Windows-specific volume config
REM This override file can be added to .gitignore for local development
echo Creating docker-compose.override.yml for Windows...
(
echo version: '3'
echo services:
echo   opensearch:
echo     volumes:
echo       - opensearch-certs:/usr/share/opensearch/config/certs:ro
echo.
echo   opensearch-dashboards:
echo     volumes:
echo       - opensearch-certs:/usr/share/opensearch-dashboards/config/certs:ro
echo.
echo volumes:
echo   opensearch-certs:
echo     external: true
) > docker\docker-compose.override.yml

REM Start OpenSearch (must run from docker directory for override to work)
echo Starting OpenSearch containers...
cd docker
docker-compose up -d
cd ..

echo Waiting for OpenSearch to be ready...
timeout /t 30 /nobreak >nul

REM Wait for OpenSearch to be healthy
REM Why PowerShell: curl exit codes are unreliable in batch files when piping output
REM Test-NetConnection is native, fast, and returns reliable exit codes
set /a attempt=1
:wait_loop
powershell -ExecutionPolicy Bypass -Command "if (Test-NetConnection -ComputerName localhost -Port 9200 -InformationLevel Quiet -WarningAction SilentlyContinue) { exit 0 } else { exit 1 }" >nul 2>nul
if %errorlevel% equ 0 (
    echo ✅ OpenSearch is ready!
    goto :opensearch_ready
)
echo Attempt %attempt%/30 - waiting for OpenSearch...
timeout /t 10 /nobreak >nul
set /a attempt+=1
if %attempt% leq 30 goto :wait_loop

echo OpenSearch failed to start properly
pause
exit /b 1

:opensearch_ready

REM Load sample data
REM Why PowerShell: curl.exe in batch files struggles with JSON data (curly braces treated as URL globs)
REM PowerShell Invoke-WebRequest handles JSON natively without complex escaping
echo Loading sample data...
powershell -ExecutionPolicy Bypass -File scripts\load_sample_data.ps1

REM Setup MCP configurations
echo Setting up MCP configurations...
call scripts\setup_mcp_configs.bat

echo.
echo Setup completed successfully!
echo.
echo Next steps:
echo 1. OpenSearch is running at: https://localhost:9200
echo 2. OpenSearch Dashboards: https://localhost:5601
echo 3. Default credentials: admin / yourStrongPassword123!
echo.
echo Configure your LLM:
echo - For Claude Desktop: Configuration updated automatically
echo - For Amazon Q: Configuration updated automatically
echo.
echo Try these example queries in your LLM:
echo - 'Create a new index called books with title and author fields'
echo - 'Search for documents in the sample_books index'
echo - 'Show me the mapping of the sample_books index'
echo.
echo To stop: cd docker ^&^& docker-compose down ^&^& cd ..
pause

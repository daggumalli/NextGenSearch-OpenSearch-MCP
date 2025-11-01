@echo off
REM Setup MCP configurations for different LLMs on Windows
setlocal enabledelayedexpansion

echo ⚙️  Setting up MCP configurations...

echo 🔍 Using uvx to run opensearch-mcp-server-py

REM Update Claude Desktop config
echo 🤖 Updating Claude Desktop configuration...
set CLAUDE_CONFIG_DIR=%APPDATA%\Claude
if not exist "%CLAUDE_CONFIG_DIR%" mkdir "%CLAUDE_CONFIG_DIR%"

REM Auto-detect uvx path for Windows
echo 🔍 Auto-detecting uvx path...

set UVX_PATH=
where uvx >nul 2>nul
if %errorlevel% equ 0 (
    for /f "tokens=*" %%i in ('where uvx') do set UVX_PATH=%%i
)

if "%UVX_PATH%"=="" (
    set UVX_PATH=%USERPROFILE%\.local\bin\uvx.exe
    echo ⚠️  uvx not found in PATH, using default: !UVX_PATH!
) else (
    echo ✅ Found uvx at: !UVX_PATH!
)

REM Create Claude config with uvx
(
echo {
echo   "mcpServers": {
echo     "opensearch-mcp-server": {
echo       "command": "!UVX_PATH!",
echo       "args": ["opensearch-mcp-server-py"],
echo       "env": {
echo         "OPENSEARCH_URL": "https://localhost:9200",
echo         "OPENSEARCH_USERNAME": "admin",
echo         "OPENSEARCH_PASSWORD": "yourStrongPassword123!",
echo         "OPENSEARCH_VERIFY_CERTS": "false",
echo         "OPENSEARCH_SSL_VERIFY": "false",
echo         "OPENSEARCH_USE_SSL": "true"
echo       }
echo     }
echo   }
echo }
) > "%CLAUDE_CONFIG_DIR%\claude_desktop_config.json"

echo ✅ Claude Desktop configuration updated at: %CLAUDE_CONFIG_DIR%\claude_desktop_config.json

REM Update Amazon Q config
echo 🔶 Updating Amazon Q configuration...
set AMAZON_Q_CONFIG_DIR=%USERPROFILE%\.aws\amazonq
if not exist "%AMAZON_Q_CONFIG_DIR%" mkdir "%AMAZON_Q_CONFIG_DIR%"

REM Create Amazon Q config with uvx
(
echo {
echo   "mcpServers": {
echo     "opensearch-mcp-server": {
echo       "command": "!UVX_PATH!",
echo       "args": ["opensearch-mcp-server-py"],
echo       "env": {
echo         "OPENSEARCH_URL": "https://localhost:9200",
echo         "OPENSEARCH_USERNAME": "admin",
echo         "OPENSEARCH_PASSWORD": "yourStrongPassword123!",
echo         "OPENSEARCH_VERIFY_CERTS": "false",
echo         "OPENSEARCH_SSL_VERIFY": "false",
echo         "OPENSEARCH_USE_SSL": "true"
echo       }
echo     }
echo   }
echo }
) > "%AMAZON_Q_CONFIG_DIR%\mcp.json"

echo ✅ Amazon Q configuration updated at: %AMAZON_Q_CONFIG_DIR%\mcp.json

echo.
echo 🎯 MCP Configuration Summary:
echo • Claude Desktop: %CLAUDE_CONFIG_DIR%\claude_desktop_config.json
echo • Amazon Q: %AMAZON_Q_CONFIG_DIR%\mcp.json
echo • MCP Server Path: !UVX_PATH!
echo • MCP Server Command: uvx opensearch-mcp-server-py
echo.
echo 🔄 Please restart your LLM applications to load the new configurations
# Use Python 3.11 slim image as base
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PIP_NO_CACHE_DIR=1
ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PYTHONPATH=/app

# Install system dependencies including curl for healthcheck
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y curl \
    && rm -rf /var/lib/apt/lists/*

# Copy application code
COPY . .

# Install Python dependencies (API + MCP server)
RUN pip install --no-cache-dir -e .[api,mcp]

# Expose port
EXPOSE 8000

# Create non-root user
RUN useradd --create-home --shell /bin/bash app \
    && chown -R app:app /app
USER app

# Default: run Streamable HTTP MCP server
# Override CMD to run other modes, e.g.:
#   uvicorn ddgs.api_server:fastapi_app --host 0.0.0.0 --port 8000   (REST API)
#   ddgs mcp                                                         (stdio MCP)
CMD ["ddgs", "mcp-http", "--host", "0.0.0.0", "--port", "8000"]

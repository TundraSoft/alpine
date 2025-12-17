#!/bin/sh
# Health check script for HTTP server
# Validates that the HTTP server is responding on port 8080

curl -s http://localhost:8080/ > /dev/null || exit 1

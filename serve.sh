#!/bin/bash

# Simple script to serve the Bullet Journal app locally

echo "Starting local server for Bullet Journal app..."
echo "Make sure you have Python installed."
echo ""

# Get the IP address of the machine (for accessing from iPad)
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo "localhost")
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    IP=$(hostname -I | awk '{print $1}' || echo "localhost")
else
    # Windows or other
    IP="localhost"
fi

# Choose a port
PORT=8000

echo "Starting server at http://$IP:$PORT"
echo "To access from your iPad, make sure your iPad is on the same network and visit:"
echo "http://$IP:$PORT in Safari"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Start a simple HTTP server
if command -v python3 &>/dev/null; then
    python3 -m http.server $PORT
elif command -v python &>/dev/null; then
    python -m SimpleHTTPServer $PORT
else
    echo "Error: Python is not installed. Please install Python or use another HTTP server."
    exit 1
fi
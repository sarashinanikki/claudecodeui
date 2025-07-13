#!/bin/bash

# Start Claude Code UI with ngrok tunnel
# This script starts the application and exposes it via ngrok

PORT=${PORT:-3000}
NGROK_AUTH_TOKEN=${NGROK_AUTH_TOKEN:-""}

echo "Starting Claude Code UI on port $PORT..."

# Build and start the application in background
npm run build
npm run server &
SERVER_PID=$!

# Wait for server to start
sleep 5

# Check if ngrok is installed
if ! command -v ngrok &> /dev/null; then
    echo "ngrok is not installed. Please install ngrok first:"
    echo "1. Download from https://ngrok.com/download"
    echo "2. Install and add to PATH"
    echo "3. Set auth token: ngrok authtoken YOUR_TOKEN"
    kill $SERVER_PID
    exit 1
fi

# Set auth token if provided
if [ ! -z "$NGROK_AUTH_TOKEN" ]; then
    ngrok authtoken $NGROK_AUTH_TOKEN
fi

echo "Starting ngrok tunnel on port $PORT..."
ngrok http $PORT --log stdout --log-format json

# Cleanup on exit
trap "kill $SERVER_PID" EXIT
#!/bin/bash

# CONFIG
BACKEND_URL="http://127.0.0.1:8000"
USERNAME="$1"   # Pass username as first argument: ./start.sh player1

if [ -z "$USERNAME" ]; then
    echo "Usage: $0 <username>"
    exit 1
fi

# GET CURRENT PROGRESS
RESPONSE=$(curl -s "$BACKEND_URL/progress/$USERNAME")

CURRENT_LEVEL=$(echo "$RESPONSE" | grep -oP '"current_level":\K[0-9]+')

if [ -z "$CURRENT_LEVEL" ]; then
    echo "Error: Could not get progress from backend."
    exit 1
fi

echo "Welcome, $USERNAME! You are currently on Level $CURRENT_LEVEL."


# START CONTAINER FOR THIS LEVEL
echo "Starting challenge container for Level $CURRENT_LEVEL..."
docker run -it --rm "ctf_level_$CURRENT_LEVEL"

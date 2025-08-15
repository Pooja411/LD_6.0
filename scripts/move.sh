#!/bin/bash

# -----------------------
# CONFIG
# -----------------------
BACKEND_URL="http://127.0.0.1:8000"
USERNAME="$1"   # First argument: ./move.sh player1 flag{xyz}
FLAG="$2"       # Second argument: the submitted flag

if [ -z "$USERNAME" ] || [ -z "$FLAG" ]; then
    echo "Usage: $0 <username> <flag>"
    exit 1
fi

# -----------------------
# SUBMIT FLAG TO BACKEND
# -----------------------
RESPONSE=$(curl -s -X POST "$BACKEND_URL/submit_flag" \
    -H "Content-Type: application/json" \
    -d "{\"username\": \"$USERNAME\", \"submitted_flag\": \"$FLAG\"}")

STATUS=$(echo "$RESPONSE" | grep -oP '"status":"\K[^"]+')
NEXT_LEVEL=$(echo "$RESPONSE" | grep -oP '"next_level":\K[0-9]+')

if [ "$STATUS" == "correct" ]; then
    echo "✅ Correct flag! Moving to Level $NEXT_LEVEL..."
    docker stop "ctf_level_$((NEXT_LEVEL-1))" 2>/dev/null
    docker run -it --rm "ctf_level_$NEXT_LEVEL"
else
    echo "❌ Wrong flag. Try again."
fi

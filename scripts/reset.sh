#!/bin/bash

# CONFIG

MONGO_URI="mongodb://localhost:27017"
DB_NAME="ctf_game"
COLLECTION="players"
USERNAME="$1"   # Pass username as first argument: ./reset.sh player1

if [ -z "$USERNAME" ]; then
    echo "Usage: $0 <username>"
    exit 1
fi

# RESET PLAYER PROGRESS
echo "Resetting progress for $USERNAME..."

mongo "$MONGO_URI/$DB_NAME" --quiet --eval \
    "db.$COLLECTION.updateOne({username: '$USERNAME'}, {\$set: {current_level: 0}})"

echo "✅ Progress reset for $USERNAME."

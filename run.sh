#!/bin/sh

# Check for .env file
if [ ! -f .env ]; then
  echo "Error: .env file not found. Please copy example.env to .env and fill in your values."
  exit 1
fi

# Start the backend server in the background
uvicorn app:app --host localhost --port 8000 --reload &
SERVER_PID=$!

# Start the frontend
npm run dev --prefix ./frontend

# When frontend exits, stop the backend
kill $SERVER_PID

#!/bin/sh

# Install dependencies
pip install --user -r requirements.txt

npm install --prefix ./frontend

if [ -f run.sh ]; then
  chmod +x run.sh
fi

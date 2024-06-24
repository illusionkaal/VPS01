#!/bin/bash

set -e

/ngrok tcp --authtoken ${AUTH_TOKEN} 22 &
sleep 5

# Debugging information
echo "Checking ngrok status..."
curl -s http://localhost:4040/api/tunnels || echo "Error fetching ngrok status. Check if ngrok is running."

ngrok_status=$(curl -s http://localhost:4040/api/tunnels)

# Check if the ngrok response is empty
if [ -z "$ngrok_status" ]; then
    echo "Error: ngrok is not running or returned an empty response."
    exit 1
fi

# Parse the JSON response
python3 -c "
import sys, json
try:
    data = json.loads('$ngrok_status')
    if 'tunnels' in data and len(data['tunnels']) > 0:
        tunnel = data['tunnels'][0]
        public_url = tunnel['public_url'][6:].replace(':', ' -p ')
        print(f'SSH Info:\\n ssh root@{public_url}\\nROOT Password:${PASSWORD}')
    else:
        print('Error: No tunnels found in ngrok response.')
except json.JSONDecodeError:
    print('Error: Failed to decode JSON response from ngrok.')
"

echo '/usr/sbin/sshd -D'

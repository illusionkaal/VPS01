#!/bin/bash

set -e

./localtonet --key ${AUTH_TOKEN} -ssh 22 &
sleep 5

# Debugging information
echo "Checking Localtonet status..."
localtonet_status=$(curl -s http://localhost:4040/api/tunnels)

# Check if the localtonet response is empty
if [ -z "$localtonet_status" ]; then
    echo "Error: Localtonet is not running or returned an empty response."
    exit 1
fi

# Parse the JSON response
python3 -c "
import sys, json
try:
    data = json.loads('$localtonet_status')
    if 'tunnels' in data and len(data['tunnels']) > 0:
        tunnel = data['tunnels'][0]
        public_url = tunnel['public_url'][6:].replace(':', ' -p ')
        print(f'SSH Info:\\n ssh root@{public_url}\\nROOT Password:${PASSWORD}')
    else:
        print('Error: No tunnels found in Localtonet response.')
except json.JSONDecodeError:
    print('Error: Failed to decode JSON response from Localtonet.')
"

echo '/usr/sbin/sshd -D'

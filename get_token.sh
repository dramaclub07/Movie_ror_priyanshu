#!/bin/bash

# Base URL
BASE_URL="http://localhost:3000/api/v1"

# Test user credentials - replace these with your actual credentials
EMAIL="your_email@example.com"
PASSWORD="your_password"

echo "Attempting to login and get access token..."

# Make the login request
RESPONSE=$(curl -s -X POST "$BASE_URL/auth/sign_in" \
  -H "Content-Type: application/json" \
  -d "{\"user\":{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}}")

# Extract access token
ACCESS_TOKEN=$(echo $RESPONSE | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

if [ -z "$ACCESS_TOKEN" ]; then
  echo "Failed to get access token. Response: $RESPONSE"
  exit 1
fi

echo "✅ Access Token obtained successfully!"
echo "Access Token: $ACCESS_TOKEN"
echo ""
echo "You can now use this token to test endpoints:"
echo "1. In Swagger UI: http://localhost:3000/api-docs"
echo "2. In curl commands: curl -H 'Authorization: Bearer $ACCESS_TOKEN' ..."
echo ""
echo "Example curl command:"
echo "curl -H 'Authorization: Bearer $ACCESS_TOKEN' -H 'Content-Type: application/json' $BASE_URL/users/profile" 
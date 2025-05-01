#!/bin/bash

# Base URL
BASE_URL="http://localhost:3000/api/v1"

# Test user credentials
EMAIL="test@example.com"
PASSWORD="password123"

echo "Testing API Endpoints..."

# Step 1: Sign in and get access token
echo "Signing in..."
RESPONSE=$(curl -s -X POST "$BASE_URL/auth/sign_in" \
  -H "Content-Type: application/json" \
  -d "{\"user\":{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}}")

ACCESS_TOKEN=$(echo $RESPONSE | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

if [ -z "$ACCESS_TOKEN" ]; then
  echo "Failed to get access token. Response: $RESPONSE"
  exit 1
fi

echo "Access token obtained successfully"

# Function to test endpoint
test_endpoint() {
  local method=$1
  local endpoint=$2
  local data=$3
  local expected_status=$4
  
  echo "Testing $method $endpoint..."
  
  if [ -z "$data" ]; then
    RESPONSE=$(curl -s -X $method "$BASE_URL$endpoint" \
      -H "Authorization: Bearer $ACCESS_TOKEN" \
      -H "Content-Type: application/json" \
      -w "\n%{http_code}")
  else
    RESPONSE=$(curl -s -X $method "$BASE_URL$endpoint" \
      -H "Authorization: Bearer $ACCESS_TOKEN" \
      -H "Content-Type: application/json" \
      -d "$data" \
      -w "\n%{http_code}")
  fi
  
  STATUS_CODE=$(echo "$RESPONSE" | tail -n1)
  BODY=$(echo "$RESPONSE" | sed '$d')
  
  if [ "$STATUS_CODE" -eq "$expected_status" ]; then
    echo "✅ Success: $method $endpoint returned $STATUS_CODE"
  else
    echo "❌ Failed: $method $endpoint returned $STATUS_CODE (expected $expected_status)"
    echo "Response body: $BODY"
  fi
}

# Test User Endpoints
test_endpoint "GET" "/users/profile" "" 200
test_endpoint "PUT" "/users/update_profile" '{"user":{"name":"Updated Name"}}' 200

# Test Movie Endpoints
test_endpoint "GET" "/movies" "" 200
test_endpoint "GET" "/movies/1" "" 200
test_endpoint "GET" "/movies/search?query=test" "" 200
test_endpoint "GET" "/movies/recommended" "" 200
test_endpoint "POST" "/movies/1/rate" '{"rating":5}' 200

# Test Genre Endpoints
test_endpoint "GET" "/genres" "" 200
test_endpoint "GET" "/genres/1" "" 200

# Test Subscription Endpoints
test_endpoint "GET" "/subscriptions" "" 200
test_endpoint "GET" "/subscriptions/active" "" 200
test_endpoint "GET" "/subscriptions/history" "" 200

echo "API testing completed" 
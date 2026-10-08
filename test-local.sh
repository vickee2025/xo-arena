#!/usr/bin/env bash
# ========================================================
# XO Arena — Local Smoke Test & Verification Script
# Validates file integrity, Docker build, and container response
# ========================================================

set -euo pipefail

TEST_PORT=8085
CONTAINER_NAME="xo-arena-smoke-test"
IMAGE_NAME="xo-arena:test"

echo "=========================================================="
echo "🧪 Running XO Arena Local Verification Suite"
echo "=========================================================="

# 1. File Integrity Check
echo -n "Checking required project files... "
for file in index.html style.css app.js Dockerfile Jenkinsfile .dockerignore; do
  if [ ! -f "$file" ]; then
    echo "FAILED"
    echo "❌ Error: Required file '$file' is missing!"
    exit 1
  fi
done
echo "✅ OK"

# 2. Docker Daemon Check
echo -n "Checking Docker daemon availability... "
if ! docker info >/dev/null 2>&1; then
  echo "FAILED"
  echo "❌ Error: Docker daemon is not running. Please start Docker first."
  exit 1
fi
echo "✅ OK"

# 3. Cleanup any old test container
docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true

# 4. Build Docker Image
echo "Building Docker container image [${IMAGE_NAME}]..."
docker build -t "${IMAGE_NAME}" . >/dev/null
echo "✅ Docker image built successfully."

# 5. Run Container
echo "Starting container on test port ${TEST_PORT}..."
docker run -d --name "${CONTAINER_NAME}" -p "${TEST_PORT}:80" "${IMAGE_NAME}" >/dev/null

# 6. Wait and Curl Health Check
echo -n "Testing HTTP response on http://127.0.0.1:${TEST_PORT}... "
sleep 2

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://127.0.0.1:${TEST_PORT}/")

if [ "$HTTP_STATUS" -eq 200 ]; then
  echo "✅ HTTP 200 OK"
else
  echo "FAILED (HTTP $HTTP_STATUS)"
  docker logs "${CONTAINER_NAME}"
  docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true
  exit 1
fi

# 7. Verify Content
echo -n "Verifying XO Arena HTML payload... "
if curl -s "http://127.0.0.1:${TEST_PORT}/" | grep -q "XO ARENA"; then
  echo "✅ OK"
else
  echo "FAILED"
  echo "❌ App content did not contain 'XO ARENA'"
  docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true
  exit 1
fi

# 8. Clean up
echo -n "Cleaning up test container... "
docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1
echo "✅ Cleaned up"

echo "=========================================================="
echo "🎉 ALL TESTS PASSED! The application is 100% verified."
echo "=========================================================="

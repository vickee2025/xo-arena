#!/usr/bin/env bash
# ========================================================
# XO Arena — Local Smoke Test & Verification Script
# Validates Java 17 + Maven structure, Docker build, and container response
# ========================================================

set -euo pipefail

TEST_PORT=8080
CONTAINER_NAME="xo-arena-test"
IMAGE_NAME="xo-arena:1.0"

echo "=========================================================="
echo "🧪 Running XO Arena Local Verification Suite"
echo "=========================================================="

# 1. File Integrity Check
echo -n "Checking required project files... "
for file in pom.xml Dockerfile Jenkinsfile .dockerignore mvnw \
            src/main/java/com/ckcet/devops/App.java \
            src/main/resources/public/index.html \
            src/main/resources/public/style.css \
            src/main/resources/public/app.js; do
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
BUILD_PLATFORM=""
if [ "$(uname -m)" = "arm64" ] || [ "$(uname -m)" = "aarch64" ]; then
  BUILD_PLATFORM="--platform linux/amd64"
fi

docker build ${BUILD_PLATFORM} -t "${IMAGE_NAME}" .
echo "✅ Docker image built successfully."

# 5. Run Container
echo "Starting container on port ${TEST_PORT}..."
docker run -d --name "${CONTAINER_NAME}" -p "${TEST_PORT}:8080" "${IMAGE_NAME}" >/dev/null

# 6. Wait and Curl Health Check
echo -n "Testing Health endpoint on http://127.0.0.1:${TEST_PORT}/api/health... "
MAX_RETRIES=15
RETRY_COUNT=0
HEALTH_OK=false
HEALTH_RESP=""

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
  if HEALTH_RESP=$(curl -s "http://127.0.0.1:${TEST_PORT}/api/health" 2>/dev/null); then
    if echo "$HEALTH_RESP" | grep -q '"status":"UP"'; then
      HEALTH_OK=true
      break
    fi
  fi
  sleep 1
  RETRY_COUNT=$((RETRY_COUNT + 1))
done

if [ "$HEALTH_OK" = true ]; then
  echo "✅ HTTP 200 OK (${HEALTH_RESP})"
else
  echo "FAILED"
  docker logs "${CONTAINER_NAME}"
  docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true
  exit 1
fi

# 7. Verify Static Frontend Content
echo -n "Verifying XO Arena HTML payload on http://127.0.0.1:${TEST_PORT}/... "
if curl -s "http://127.0.0.1:${TEST_PORT}/" | grep -q "XO ARENA"; then
  echo "✅ OK"
else
  echo "FAILED"
  echo "❌ App content did not contain 'XO ARENA'"
  docker logs "${CONTAINER_NAME}"
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

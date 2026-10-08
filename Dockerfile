# ========================================================
# XO Arena — Multi-Stage Production Dockerfile
# Stage 1: Build fat JAR with Maven & Java 17
# Stage 2: Minimal Alpine JRE runtime with non-root security
# ========================================================

# Stage 1: Build
FROM maven:3.9-eclipse-temurin-17-alpine AS builder
WORKDIR /build

COPY pom.xml .
COPY src ./src

RUN mvn clean package -DskipTests -B

# Stage 2: Runtime
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

COPY --from=builder --chown=appuser:appgroup /build/target/xo-arena-1.0.0.jar app.jar

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/api/health || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]

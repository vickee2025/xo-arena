# 🎮 XO Arena — Cloud & DevOps Edition

[![Java](https://img.shields.io/badge/Java-17-ED8B00?logo=openjdk&logoColor=white)](https://adoptium.net/)
[![Maven](https://img.shields.io/badge/Maven-3.9-C71A36?logo=apachemaven&logoColor=white)](https://maven.apache.org/)
[![Javalin](https://img.shields.io/badge/Javalin-5.6.3-00A86B.svg)](https://javalin.io/)
[![Docker](https://img.shields.io/badge/Docker-Multi--Stage-2496ED?logo=docker&logoColor=white)](https://hub.docker.com/)
[![CI/CD](https://img.shields.io/badge/CI%2FCD-Jenkins%20Pipeline-D24939?logo=jenkins&logoColor=white)](https://www.jenkins.io/)
[![Cloud](https://img.shields.io/badge/Cloud-AWS%20EC2%20Ubuntu-FF9900?logo=amazon-aws&logoColor=white)](https://aws.amazon.com/ec2/)
[![Cohort](https://img.shields.io/badge/CKCET-Cloud%20%26%20DevOps%202026-green.svg)](https://ckcet.edu.in)

> **Official Student Laboratory Repository for CKCET Cloud & DevOps Bootcamp — Day 4**  
> An enterprise-grade, containerized Java 17 + Javalin web microservice serving a glassmorphic cyberpunk Tic-Tac-Toe web application, engineered for hands-on Maven builds, Multi-Stage Docker packaging, and Jenkins CI/CD automation on AWS EC2.

---

## 📖 Table of Contents
1. [Overview & Features](#-overview--features)
2. [Architecture & Multi-Stage Flow](#-architecture--multi-stage-flow)
3. [Prerequisites](#-prerequisites)
4. [Repository Directory Structure](#-repository-directory-structure)
5. [Track 1: Local Java Build with Maven Wrapper](#-track-1-local-java-build-with-maven-wrapper)
6. [Track 2: Containerization with Multi-Stage Docker](#-track-2-containerization-with-multi-stage-docker)
7. [Track 3: Automated CI/CD Pipeline with Jenkins on AWS EC2](#-track-3-automated-cicd-pipeline-with-jenkins-on-aws-ec2)
8. [Track 4: The Developer Challenge (Verify the Loop)](#-track-4-the-developer-challenge-verify-the-loop)
9. [Automated Local Verification Script](#-automated-local-verification-script)
10. [Troubleshooting & FAQ](#-troubleshooting--faq)

---

## 🌟 Overview & Features

**XO Arena** combines a high-performance Java backend with an interactive browser game:
- **Java 17 & Javalin 5.6.3 Microservice:** Ultra-lightweight REST API and embedded web server running on Port 8080 (or configurable `PORT` environment variable).
- **Embedded Health Route:** `GET /api/health` returning JSON payload `{"status":"UP","app":"XO Arena","version":"1.0.0"}` for automated Docker and Jenkins smoke testing.
- **Glassmorphic Cyberpunk UI:** Served directly from classpath resources (`/public`) with glowing neon styling, real-time 8-vector win detection, and `localStorage` score persistence.
- **Multi-Stage Docker Container:** High-efficiency build using `maven:3.9-eclipse-temurin-17-alpine` as builder and `eclipse-temurin:17-jre-alpine` as runtime. Runs as dedicated non-root user `appuser` for enterprise security.
- **Zero-Install Maven Wrapper (`mvnw`):** Students can compile and package immediately without manually installing Apache Maven.

---

## 🏗️ Architecture & Multi-Stage Flow

```
[ Developer Workstation ]
        │  (git push)
        ▼
[ GitHub Repository (vickee2025/xo-arena) ]
        │
        │ Webhook Trigger (HTTP POST :8088/github-webhook/)
        ▼
[ AWS EC2 Instance (Day 3 Cloud Server) ]
   ├── Jenkins CI/CD Server (Port 8088)
   │     ├── Stage 1: Checkout Git Source
   │     ├── Stage 2: Lint & Validate Project Files
   │     ├── Stage 3: Multi-Stage Docker Build
   │     │      ├── Stage 1 (Builder): maven:3.9-temurin-17 -> mvn clean package -> xo-arena-1.0.0.jar
   │     │      └── Stage 2 (Runner):  eclipse-temurin:17-jre -> Non-root user appuser -> app.jar
   │     ├── Stage 4: Deploy & Restart Container (Port 8080:8080)
   │     └── Stage 5: Smoke Test (/api/health HTTP 200 Verification)
   │
   └── Docker Engine Daemon
         └── Container: xo-arena-production (Port 8080)
               ├── GET /           ──► Serves XO Arena UI (HTML/CSS/JS)
               └── GET /api/health ──► JSON {"status":"UP","app":"XO Arena","version":"1.0.0"}
```

---

## 📋 Prerequisites

Before starting, ensure you have:
- **Git** installed on your laptop (`git --version`)
- A **GitHub Account** (free)
- **Docker Desktop** (or Docker Engine on Linux) running (`docker --version`)
- *(Optional for direct JAR execution)* **Java 17 JDK** (`java -version`)
- A modern web browser (Google Chrome, Firefox, Safari, Edge)
- *(For Cloud Lab)* Your **AWS EC2 Ubuntu Server** from Day 3 with Docker and Jenkins installed

---

## 📁 Repository Directory Structure

```
xo-arena/
├── pom.xml                               # Maven Project Object Model (Java 17, Javalin 5.6.3, Shade plugin)
├── mvnw                                  # Maven wrapper script (macOS / Linux)
├── mvnw.cmd                              # Maven wrapper script (Windows)
├── .mvn/
│   └── wrapper/
│       └── maven-wrapper.properties      # Wrapper configuration (Maven 3.9.16)
├── Dockerfile                            # Multi-stage production container (Maven Builder -> JRE Runner)
├── .dockerignore                         # Excludes target, git, and log files from build context
├── Jenkinsfile                           # Declarative 5-stage CI/CD pipeline definition
├── test-local.sh                         # Automated local smoke test script
├── .gitignore                            # Git ignored build artifacts and environment files
├── README.md                             # Complete laboratory documentation
└── src/
    └── main/
        ├── java/
        │   └── com/ckcet/devops/
        │       └── App.java              # Javalin server, static routing, and /api/health route
        └── resources/
            └── public/
                ├── index.html            # Game layout, scoreboard, player avatars
                ├── style.css             # Glassmorphic cyberpunk styling
                └── app.js                # Game mechanics, win calculation, persistence
```

---

## 💻 Track 1: Local Java Build with Maven Wrapper

You can compile, package, and execute the Java 17 backend directly using the included Maven wrapper.

### Step 1.1: Clone the Repository
```bash
git clone https://github.com/vickee2025/xo-arena.git
cd xo-arena
```

### Step 1.2: Build the Fat JAR with Maven Wrapper
- **macOS / Linux:**
  ```bash
  ./mvnw clean package
  ```
- **Windows (PowerShell / Command Prompt):**
  ```powershell
  .\mvnw.cmd clean package
  ```

This executes a clean build and uses the `maven-shade-plugin` to assemble a self-contained executable JAR at `target/xo-arena-1.0.0.jar`.

### Step 1.3: Run the Application
```bash
java -jar target/xo-arena-1.0.0.jar
```

### Step 1.4: Verify in Browser
- Open **[http://localhost:8080](http://localhost:8080)** to play the game.
- Open **[http://localhost:8080/api/health](http://localhost:8080/api/health)** to inspect the JSON health endpoint:
  ```json
  {"status":"UP","app":"XO Arena","version":"1.0.0"}
  ```

*(Press `Ctrl+C` in your terminal to stop the server).*

---

## 🐳 Track 2: Containerization with Multi-Stage Docker

Multi-stage builds allow you to compile Java code inside an isolated container without requiring Java or Maven installed on the host machine, while producing a lightweight, minimal production image.

### Step 2.1: Inspect the Multi-Stage `Dockerfile`
Notice the separation of concerns between compilation and execution:

```dockerfile
# Stage 1: Build fat JAR with Maven & Java 17
FROM maven:3.9-eclipse-temurin-17-alpine AS builder
WORKDIR /build

COPY pom.xml .
COPY src ./src

RUN mvn clean package -DskipTests -B

# Stage 2: Minimal Alpine JRE runtime with non-root security
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

COPY --from=builder /build/target/xo-arena-1.0.0.jar app.jar

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/api/health || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]
```

### Step 2.2: Build the Docker Image
```bash
docker build -t xo-arena:1.0 .
```
*(On Apple Silicon / ARM64 laptops, Docker Desktop transparently builds via multi-arch emulation).*

### Step 2.3: Run the Container
```bash
docker run -d --name xo-arena-app -p 8080:8080 xo-arena:1.0
```

**Flags Explained:**
- `-d`: Detached mode (runs the container in the background).
- `--name xo-arena-app`: Assigns a readable container name.
- `-p 8080:8080`: Maps host Port 8080 to container Port 8080.
- `xo-arena:1.0`: The target container image.

### Step 2.4: Verify Health & Endpoints
Check container status:
```bash
docker ps
```
You should see status `Up ... (healthy)`.

Test via curl:
```bash
# Test API Health
curl http://localhost:8080/api/health

# Test Static Game HTML
curl -s http://localhost:8080/ | head -n 5
```

Navigate to **[http://localhost:8080](http://localhost:8080)** in your browser and play a round!

### Step 2.5: Stop & Clean Up
```bash
docker stop xo-arena-app
docker rm xo-arena-app
```

---

## 🚀 Track 3: Automated CI/CD Pipeline with Jenkins on AWS EC2

Connect your repository to an automated CI/CD pipeline on your **AWS EC2 Ubuntu Server**.

### Step 3.1: Fork or Create Copy
1. Navigate to `https://github.com/vickee2025/xo-arena`.
2. Click **"Fork"** or **"Use this template"**.
3. Choose your personal GitHub account as destination and make it **Public**.

### Step 3.2: Verify Server Prerequisites on AWS EC2
SSH into your EC2 instance:
```bash
ssh -i your-key.pem ubuntu@<EC2_PUBLIC_IP>
```

#### A. Free Port 8080 & Disable Conflicting Services:
```bash
sudo systemctl stop nginx 2>/dev/null || true
sudo systemctl disable nginx 2>/dev/null || true
sudo apt-get remove -y nginx 2>/dev/null || true
sudo lsof -i :8080
```

#### B. Configure 2GB Swap Memory (Mandatory for `t3.micro` 1GB RAM instances):
```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
free -h
```

#### C. Ensure Docker & Jenkins Permissions:
```bash
sudo apt-get update && sudo apt-get install -y docker.io
sudo systemctl enable --now docker
sudo usermod -aG docker ubuntu
sudo usermod -aG docker jenkins 2>/dev/null || true
sudo systemctl restart jenkins 2>/dev/null || true
```

### Step 3.3: Configure Jenkins Pipeline Job
1. Open Jenkins: `http://<EC2_PUBLIC_IP>:8088`
2. Click **New Item** → Name: `xo-arena-pipeline` → Select **Pipeline** → Click **OK**.
3. Under **Build Triggers**, select ☑️ **GitHub hook trigger for GITScm polling**.
4. Under **Pipeline**:
   - Definition: **Pipeline script from SCM**
   - SCM: **Git**
   - Repository URL: `https://github.com/<YOUR_USERNAME>/xo-arena.git`
   - Branch Specifier: `*/main`
   - Script Path: `Jenkinsfile`
5. Click **Save**.

### Step 3.4: Configure GitHub Webhook
1. In your GitHub repository, open **Settings** → **Webhooks** → **Add webhook**.
2. **Payload URL:** `http://<EC2_PUBLIC_IP>:8088/github-webhook/` *(Ensure trailing slash!)*
3. **Content type:** `application/json`
4. Select **Just the push event**.
5. Click **Add webhook**.

### Step 3.5: Run the Pipeline
In Jenkins, click **Build Now**. The pipeline will:
1. `Checkout Code` from Git.
2. `Static Validation & Lint` verifying Java structure and pom.xml.
3. `Build Docker Image` with multi-stage compilation.
4. `Deploy to Cloud Server` on port 8080.
5. `Automated Smoke Test & Health Check` verifying `/api/health`.

Once green, open **`http://<EC2_PUBLIC_IP>:8080`** in your browser!

---

## ⚡ Track 4: The Developer Challenge (Verify the Loop)

Experience continuous deployment firsthand:

1. On your local machine, edit `src/main/resources/public/index.html`:
   ```bash
   nano src/main/resources/public/index.html
   ```
2. Locate the Player X title around line 22:
   ```html
   <span class="player-name">Player X</span>
   <span class="player-role">DevOps Dev</span>
   ```
   Update it with your personal name:
   ```html
   <span class="player-name">Alex M.</span>
   <span class="player-role">Lead DevOps Engineer</span>
   ```
3. Commit and push:
   ```bash
   git add src/main/resources/public/index.html
   git commit -m "feat: updated player title to Lead DevOps Engineer"
   git push origin main
   ```
4. Within seconds, Jenkins automatically triggers a new build, rebuilds the multi-stage image, restarts the container, and passes the health check!
5. Refresh `http://<EC2_PUBLIC_IP>:8080` to see your change live.

---

## 🧪 Automated Local Verification Script

Before committing or submitting lab exercises, run the automated verification script:

```bash
chmod +x test-local.sh
./test-local.sh
```

**Expected Output:**
```
==========================================================
🧪 Running XO Arena Local Verification Suite
==========================================================
Checking required project files... ✅ OK
Checking Docker daemon availability... ✅ OK
Building Docker container image [xo-arena:1.0]...
✅ Docker image built successfully.
Starting container on port 8080...
Testing Health endpoint on http://127.0.0.1:8080/api/health... ✅ HTTP 200 OK ({"status":"UP","app":"XO Arena","version":"1.0.0"})
Verifying XO Arena HTML payload on http://127.0.0.1:8080/... ✅ OK
Cleaning up test container... ✅ Cleaned up
==========================================================
🎉 ALL TESTS PASSED! The application is 100% verified.
==========================================================
```

---

## ❓ Troubleshooting & FAQ

### Q1: `Error: bind: address already in use` on Port 8080
**Cause:** Another process or previous container is already bound to port 8080.  
**Fix:**
```bash
# Check what process is using port 8080
lsof -i :8080

# Stop any running xo-arena container
docker rm -f xo-arena-app xo-arena-test 2>/dev/null || true
```

### Q2: Java compilation out-of-memory error during Docker build
**Cause:** `t3.micro` EC2 instances have 1GB of physical RAM. Without swap space, the Maven Java compiler can be terminated by the Linux OOM killer.  
**Fix:** Enable 2GB swap space per [Step 3.2.B](#b-configure-2gb-swap-memory-mandatory-for-t3micro-1gb-ram-instances):
```bash
sudo swapon --show
```

### Q3: Jenkins pipeline fails with `Got permission denied while trying to connect to the Docker daemon socket`
**Cause:** The `jenkins` system user lacks permissions on `/var/run/docker.sock`.  
**Fix:**
```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### Q4: GitHub Webhook shows a Red Exclamation Mark (Delivery Failed)
**Cause:** AWS EC2 Security Group is blocking inbound traffic on Port 8088.  
**Fix:**
1. Open AWS EC2 Console → **Security Groups**.
2. Select your instance security group → **Edit Inbound Rules**.
3. Add Rule: Custom TCP, Port `8088`, Source `0.0.0.0/0`.
4. Save and re-test delivery in GitHub.

---

## 📜 License & Acknowledgments
- Built with ❤️ for the **CKCET Cloud & DevOps Engineering Bootcamp 2026**.
- Open source under the MIT License.

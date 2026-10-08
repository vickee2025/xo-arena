# 🎮 XO Arena — Cloud & DevOps Edition

[![Docker Image](https://img.shields.io/badge/docker-nginx%3Aalpine-blue.svg)](https://hub.docker.com/_/nginx)
[![CI/CD](https://img.shields.io/badge/CI%2FCD-Jenkins%20Pipeline-red.svg)](https://www.jenkins.io/)
[![Cloud](https://img.shields.io/badge/Cloud-AWS%20EC2%20Ubuntu-orange.svg)](https://aws.amazon.com/ec2/)
[![Cohort](https://img.shields.io/badge/CKCET-Cloud%20%26%20DevOps%202026-green.svg)](https://ckcet.edu.in)

> **Official Student Laboratory Repository for CKCET Cloud & DevOps Bootcamp — Day 4**  
> A containerized, zero-dependency modern interactive Tic-Tac-Toe web application engineered for hands-on Git, Docker, and Jenkins CI/CD automation on AWS EC2.

---

## 📖 Table of Contents
1. [Overview & Features](#-overview--features)
2. [Architecture & DevOps Flow](#-architecture--devops-flow)
3. [Prerequisites](#-prerequisites)
4. [Repository File Structure](#-repository-file-structure)
5. [Track 1: Quick Local Browser Test (Zero Setup)](#-track-1-quick-local-browser-test-zero-setup)
6. [Track 2: Containerization with Docker (Local Lab)](#-track-2-containerization-with-docker-local-lab)
7. [Track 3: Automated CI/CD Pipeline with Jenkins on AWS EC2](#-track-3-automated-cicd-pipeline-with-jenkins-on-aws-ec2)
8. [Track 4: The Developer Challenge (Verify the Loop)](#-track-4-the-developer-challenge-verify-the-loop)
9. [Automated Verification Script](#-automated-verification-script)
10. [Troubleshooting & FAQ](#-troubleshooting--faq)

---

## 🌟 Overview & Features

**XO Arena** is an interactive, browser-based 2-player Tic-Tac-Toe game featuring:
- **Glassmorphic Cyberpunk UI:** Glowing neon accents, smooth animations, and active player indicator cards.
- **Dual Player Roles:** Player X (*DevOps Dev*) vs. Player O (*Site Reliability*).
- **Engine Logic:** Real-time 8-vector win detection, tie/deadlock detection, and `localStorage` score persistence.
- **Micro-Footprint Container:** Packaged with `nginx:1.27-alpine` (~23MB total image size).
- **Production Pipeline Ready:** Includes a 5-stage Declarative `Jenkinsfile` and Docker health checks.

---

## 🏗️ Architecture & DevOps Flow

```
[ Developer Machine ]
        │  (git push)
        ▼
[ GitHub Repository (vickee2025/xo-arena) ]
        │
        │ Webhook Trigger (HTTP POST :8088/github-webhook/)
        ▼
[ AWS EC2 Instance (Day 3 Cloud Server) ]
   ├── Jenkins CI/CD Server (Port 8088)
   │     ├── Stage 1: Checkout Git Source
   │     ├── Stage 2: Static Asset & Syntax Lint
   │     ├── Stage 3: Build Docker Image (xo-arena:latest)
   │     ├── Stage 4: Deploy & Restart Container (Port 8080:80)
   │     └── Stage 5: Smoke Test & HTTP Health Check
   │
   └── Docker Engine Daemon
         └── Container: xo-arena-production (Port 8080) ────► Served to End Users
```

---

## 📋 Prerequisites

Before starting, make sure you have the following ready:
- **Git** installed on your laptop (`git --version`)
- A **GitHub Account** (free)
- **Docker Desktop** (or Docker Engine on Linux) running (`docker --version`)
- A modern web browser (Google Chrome, Firefox, Safari, Edge)
- *(For Cloud Lab)* Your **AWS EC2 Ubuntu Server** from Day 3 with Docker and Jenkins installed

---

## 📁 Repository File Structure

```
xo-arena/
├── index.html        # Game layout, scoreboard, player avatars, and badges
├── style.css         # Glassmorphic cyberpunk styling and responsive rules
├── app.js            # Game mechanics, win calculation, and score persistence
├── Dockerfile        # Production container instructions (Alpine Nginx)
├── .dockerignore     # Prevents unnecessary files from entering the Docker build context
├── Jenkinsfile       # Automated 5-stage CI/CD pipeline definition
├── test-local.sh     # Automated local verification script
├── .gitignore        # Git ignored operating system and editor files
└── README.md         # Complete beginner-friendly documentation
```

---

## 💻 Track 1: Quick Local Browser Test (Zero Setup)

You can run and play the game directly in your browser without Docker to understand the application source code.

### Step 1.1: Clone the Repository
Open your terminal (macOS/Linux) or PowerShell (Windows):
```bash
git clone https://github.com/vickee2025/xo-arena.git
cd xo-arena
```

### Step 1.2: Open in Browser
- **macOS:**
  ```bash
  open index.html
  ```
- **Linux:**
  ```bash
  xdg-open index.html
  ```
- **Windows (PowerShell):**
  ```powershell
  start index.html
  ```
- **Or via Python HTTP Server:**
  ```bash
  python3 -m http.server 8085
  ```
  Open [http://localhost:8085](http://localhost:8085) in your web browser.

---

## 🐳 Track 2: Containerization with Docker (Local Lab)

In this track, you will package the web application into an immutable Docker container image and run it on your local machine.

### Step 2.1: Inspect the `Dockerfile`
Notice how simple and clean the container recipe is:
```dockerfile
FROM nginx:1.27-alpine
RUN rm -rf /usr/share/nginx/html/*
COPY index.html /usr/share/nginx/html/
COPY style.css /usr/share/nginx/html/
COPY app.js /usr/share/nginx/html/
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1
CMD ["nginx", "-g", "daemon off;"]
```

### Step 2.2: Build the Docker Image
Run the `docker build` command in the root of the project:
```bash
docker build -t xo-arena:1.0 .
```
> 💡 *Note: The `.` at the end tells Docker to look for the `Dockerfile` in the current working directory.*

### Step 2.3: Verify Image in Local Cache
Check your newly built Docker image:
```bash
docker images | grep xo-arena
```
*Expected Output:*
```
REPOSITORY   TAG       IMAGE ID       CREATED         SIZE
xo-arena     1.0       a1b2c3d4e5f6   5 seconds ago   23.6MB
```
Notice how the container is only **~23MB** because of Alpine Linux!

### Step 2.4: Run the Container
Launch your container with port mapping:
```bash
docker run -d --name xo-arena-app -p 8080:80 xo-arena:1.0
```
**Flags Explained:**
- `-d`: Detached mode (runs the container in the background so your terminal remains free).
- `--name xo-arena-app`: Assigns a memorable name to the container instead of a random UUID.
- `-p 8080:80`: Port forwarding. Maps **Port 8080** on your host laptop to **Port 80** inside the container.
- `xo-arena:1.0`: The image name and tag to run.

### Step 2.5: Verify Container Health
```bash
docker ps
```
You will see `xo-arena-app` running with status `Up ... (healthy)`.

Open your browser and navigate to:
👉 **[http://localhost:8080](http://localhost:8080)**

Play a couple of rounds! Notice how your scores persist even if you reload the page.

### Step 2.6: Inspect Container Logs
View live Nginx access logs:
```bash
docker logs -f xo-arena-app
```
*(Press `Ctrl+C` to exit the log view).*

### Step 2.7: Stop & Clean Up Local Container
When you are done testing:
```bash
docker stop xo-arena-app
docker rm xo-arena-app
```

---

## 🚀 Track 3: Automated CI/CD Pipeline with Jenkins on AWS EC2

Now, connect your code to an automated CI/CD pipeline on your **AWS EC2 Ubuntu Server** created on Day 3.

### Step 3.1: Fork this Repository
1. In GitHub, click the **Fork** button at the top-right of this repository (`https://github.com/vickee2025/xo-arena`).
2. Select your personal GitHub username as the destination.
3. You now have your own repository: `https://github.com/<YOUR_USERNAME>/xo-arena`.

### Step 3.2: Verify Server Prerequisites on AWS EC2
SSH into your Day 3 EC2 instance:
```bash
ssh -i your-key.pem ubuntu@<EC2_PUBLIC_IP>
```
Verify that Docker and Jenkins are active:
```bash
docker --version
sudo systemctl status jenkins
```
Ensure the `jenkins` user has permission to control Docker:
```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### Step 3.3: Create Pipeline Job in Jenkins
1. Access Jenkins in your browser: `http://<EC2_PUBLIC_IP>:8088`
2. Click **New Item** on the left menu.
3. Enter item name: `xo-arena-pipeline`.
4. Select **Pipeline** and click **OK**.
5. Scroll down to **Build Triggers**:
   - Check ☑️ **GitHub hook trigger for GITScm polling**.
6. Scroll down to **Pipeline**:
   - Definition: Select **Pipeline script from SCM**.
   - SCM: Select **Git**.
   - Repository URL: Enter your forked URL (`https://github.com/<YOUR_USERNAME>/xo-arena.git`).
   - Branch Specifier: `*/main`.
   - Script Path: `Jenkinsfile`.
7. Click **Save**.

### Step 3.4: Configure GitHub Webhook
1. In your forked GitHub repository, go to **Settings** → **Webhooks** → **Add webhook**.
2. **Payload URL:** `http://<EC2_PUBLIC_IP>:8088/github-webhook/` *(Notice the trailing slash!)*
3. **Content type:** Select `application/json`.
4. **Which events would you like to trigger this webhook?** Select **Just the push event**.
5. Click **Add webhook**.
6. Refresh the page after 5 seconds to ensure a green checkmark appears next to the webhook.

### Step 3.5: Run First Build
In Jenkins, click **Build Now**.
Watch the pipeline execute each stage:
1. `1. Checkout Code`
2. `2. Static Validation & Lint`
3. `3. Build Docker Image`
4. `4. Deploy to Cloud Server`
5. `5. Automated Smoke Test & Health Check`

Once the build turns green, visit:
👉 **`http://<EC2_PUBLIC_IP>:8080`**

Your game is now live on the public cloud!

---

## ⚡ Track 4: The Developer Challenge (Verify the Loop)

The true power of DevOps is **Zero-Friction Continuous Deployment**. Test it yourself!

1. On your laptop, edit `index.html`:
   ```bash
   nano index.html
   ```
2. Locate line 22:
   ```html
   <span class="player-name">Player X</span>
   <span class="player-role">DevOps Dev</span>
   ```
   Change it to include your name:
   ```html
   <span class="player-name">Alex M.</span>
   <span class="player-role">Lead DevOps Engineer</span>
   ```
3. Commit and push the change to your GitHub repo:
   ```bash
   git add index.html
   git commit -m "feat: updated player title to Lead DevOps Engineer"
   git push origin main
   ```
4. Switch to your Jenkins console: within 5 to 10 seconds, **Build #2 triggers automatically**!
5. Once Build #2 completes, refresh `http://<EC2_PUBLIC_IP>:8080`.
6. Your change is live in production without touching SSH or restarting servers manually!

---

## 🧪 Automated Verification Script

Before deploying or submitting your lab work, you can run the built-in automated verification script:

```bash
chmod +x test-local.sh
./test-local.sh
```

**Output:**
```
==========================================================
🧪 Running XO Arena Local Verification Suite
==========================================================
Checking required project files... ✅ OK
Checking Docker daemon availability... ✅ OK
Building Docker container image [xo-arena:test]...
✅ Docker image built successfully.
Starting container on test port 8085...
Testing HTTP response on http://127.0.0.1:8085... ✅ HTTP 200 OK
Verifying XO Arena HTML payload... ✅ OK
Cleaning up test container... ✅ Cleaned up
==========================================================
🎉 ALL TESTS PASSED! The application is 100% verified.
==========================================================
```

---

## ❓ Troubleshooting & FAQ

### Q1: `Error: bind: address already in use` on Port 8080
**Cause:** Another process or previous container is already using port 8080.  
**Fix:**
```bash
# Check what is running on port 8080
lsof -i :8080

# Or remove old container
docker rm -f $(docker ps -q --filter ancestor=xo-arena:latest)
```
Or map to a different host port (e.g. `-p 8085:80`).

### Q2: `Cannot connect to the Docker daemon at unix:///var/run/docker.sock`
**Cause:** Docker daemon is stopped.  
**Fix:**
- On Mac/Windows: Start **Docker Desktop**.
- On Linux/EC2: Run `sudo systemctl start docker`.

### Q3: Jenkins pipeline fails with `Got permission denied while trying to connect to the Docker daemon socket`
**Cause:** The `jenkins` system user does not belong to the `docker` group.  
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
3. Add Rule:
   - **Type:** Custom TCP
   - **Port:** `8088`
   - **Source:** `0.0.0.0/0` (Anywhere IPv4)
4. Save rules and re-deliver the webhook in GitHub.

---

## 📜 License & Acknowledgments
- Built with ❤️ for the **CKCET Cloud & DevOps Engineering Bootcamp 2026**.
- Open source under the MIT License. Feel free to fork, enhance, and deploy!

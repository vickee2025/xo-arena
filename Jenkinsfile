pipeline {
    agent any

    environment {
        APP_NAME        = 'xo-arena'
        IMAGE_NAME      = 'xo-arena'
        CONTAINER_NAME  = 'xo-arena-production'
        HOST_PORT       = '8080'
        CONTAINER_PORT  = '8080'
    }

    stages {
        stage('1. Checkout Code') {
            steps {
                echo "Fetching latest source code from Git repository..."
                checkout scm
            }
        }

        stage('2. Static Validation & Lint') {
            steps {
                echo "Validating core application assets and Dockerfile presence..."
                sh '''
                    test -f pom.xml || { echo "ERROR: pom.xml missing"; exit 1; }
                    test -f src/main/java/com/ckcet/devops/App.java || { echo "ERROR: App.java missing"; exit 1; }
                    test -f src/main/resources/public/index.html || { echo "ERROR: index.html missing"; exit 1; }
                    test -f src/main/resources/public/style.css || { echo "ERROR: style.css missing"; exit 1; }
                    test -f src/main/resources/public/app.js || { echo "ERROR: app.js missing"; exit 1; }
                    test -f Dockerfile || { echo "ERROR: Dockerfile missing"; exit 1; }
                    echo "Static asset and project integrity check passed."
                '''
            }
        }

        stage('3. Build Docker Image') {
            steps {
                echo "Building multi-stage Docker container image..."
                sh """
                    docker build \
                        --label "build_number=${BUILD_NUMBER}" \
                        --label "git_commit=${env.GIT_COMMIT ?: 'latest'}" \
                        -t ${IMAGE_NAME}:${BUILD_NUMBER} \
                        -t ${IMAGE_NAME}:latest .
                """
            }
        }

        stage('4. Deploy to Cloud Server') {
            steps {
                echo "Deploying fresh container to Day 3 EC2 Cloud Server..."
                sh """
                    echo "Stopping any existing container named ${CONTAINER_NAME}..."
                    docker stop ${CONTAINER_NAME} || true
                    docker rm -f ${CONTAINER_NAME} || true

                    echo "Starting new container on Host Port ${HOST_PORT}..."
                    docker run -d \
                        --name ${CONTAINER_NAME} \
                        --restart unless-stopped \
                        -p ${HOST_PORT}:${CONTAINER_PORT} \
                        ${IMAGE_NAME}:latest
                """
            }
        }

        stage('5. Automated Smoke Test & Health Check') {
            steps {
                echo "Running curl health check against deployed container on Port ${HOST_PORT}..."
                sh """
                    sleep 3
                    curl -s -f http://127.0.0.1:${HOST_PORT}/api/health > /dev/null || {
                        echo "ERROR: Health check failed! App not responding on http://127.0.0.1:${HOST_PORT}/api/health"
                        docker logs ${CONTAINER_NAME}
                        exit 1
                    }
                    echo "SUCCESS: XO Arena container is live, healthy, and serving requests on Port ${HOST_PORT}!"
                """
            }
        }
    }

    post {
        always {
            echo "Pipeline run completed for build #${BUILD_NUMBER}."
        }
        success {
            echo "=========================================================="
            echo "🚀 DEPLOYMENT SUCCESSFUL!"
            echo "Application is live at: http://<YOUR_EC2_PUBLIC_IP>:${HOST_PORT}"
            echo "Health endpoint: http://<YOUR_EC2_PUBLIC_IP>:${HOST_PORT}/api/health"
            echo "=========================================================="
        }
        failure {
            echo "❌ Pipeline failed at build #${BUILD_NUMBER}. Check console output for triage."
        }
    }
}

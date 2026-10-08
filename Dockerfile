# ========================================================
# XO Arena — Lightweight Production Dockerfile
# Base: Nginx Alpine (Ultra-lean ~23MB footprint)
# Serves static web assets on Port 80
# ========================================================

FROM nginx:1.27-alpine

LABEL maintainer="CKCET Cloud & DevOps Cohort <devops@ckcet.edu.in>"
LABEL description="Interactive XO Arena containerized web application"

# Remove default nginx welcome page
RUN rm -rf /usr/share/nginx/html/*

# Copy static application assets into Nginx web root
COPY index.html /usr/share/nginx/html/
COPY style.css /usr/share/nginx/html/
COPY app.js /usr/share/nginx/html/

# Expose HTTP container port
EXPOSE 80

# Health check to ensure Nginx is responding to requests
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

# Launch Nginx in foreground to keep container running
CMD ["nginx", "-g", "daemon off;"]

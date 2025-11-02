# Two-tier App (Backend in Docker, Frontend Local)

This project runs the backend with Docker and the frontend locally without Docker.

## What was changed
- Removed Docker from the frontend (deleted `frontend/Dockerfile` and removed `frontend` service from `docker-compose.yml`).
- Updated `frontend/script.js` to use `http://localhost:5000/api` for `API_BASE`.
- Kept the backend containerized and exposed on port 5000.

## How the issue was debugged and fixed
1. Verified Docker CLI/Compose were installed:
   - `docker --version`
   - `docker compose version`
2. The error on `docker compose up` showed the Docker engine wasn’t running.
3. Started Docker Desktop (Windows):
   - Launch "Docker Desktop" from Start menu or run:
     - `Start-Process "C:\\Program Files\\Docker\\Docker\\Docker Desktop.exe"`
4. Confirmed the engine was running with `docker info`.
5. Simplified compose to backend-only by removing the `frontend` service from `docker-compose.yml`.
6. Rebuilt and started backend:
   - `docker compose build --no-cache backend`
   - `docker compose up -d backend`
7. Verified backend health from the host:
   - `curl http://localhost:5000/api/message`
   - Expected response: `{ "message": "Hello from backend!" }`
8. Updated the frontend to call the backend via localhost (no Docker) by setting `API_BASE` in `frontend/script.js` to `http://localhost:5000/api`.

## How to run
### Backend (Docker)
- Build and start:
  - `docker compose up -d --build backend`
- Logs:
  - `docker compose logs -f backend`
- Health check:
  - `curl http://localhost:5000/api/message`

### Frontend (Local)
- Open `frontend/index.html` in a browser, or serve the `frontend` folder with a static server.
  - Example (PowerShell): `python -m http.server 8080` inside `frontend/`
  - Then browse `http://localhost:8080`
- The frontend is configured to call the backend at `http://localhost:5000/api`.

## Notes
- Ensure Docker Desktop is running before using Docker commands on Windows.
- If port 5000 is busy, change the host port in `docker-compose.yml` under the `backend` service `ports` mapping (left side of `host:container`).

## Deploying Frontend to AWS S3 + CloudFront

Yes, you can absolutely deploy the frontend to AWS S3 static hosting with CloudFront for CDN and SSL termination!

### Architecture Overview
- **S3**: Hosts your static files (HTML, CSS, JS)
- **CloudFront**: Provides CDN, SSL/TLS termination, and custom domain support
- **Backend**: Remains on your server (e.g., EC2, ECS, EKS, or Application Load Balancer)

### Deployment Steps

1. **Update API Configuration**:
   - Before deploying, update `frontend/config.js`:
     ```javascript
     window.API_BASE_URL = 'https://your-backend-api-domain.com/api';
     ```

2. **Prepare Frontend Files**:
   - Upload all files from `frontend/` directory to S3:
     - `index.html`
     - `script.js`
     - `config.js`
     - `styles.css`

3. **Configure S3 Bucket**:
   - Enable static website hosting
   - Set `index.html` as the index document
   - Configure bucket policy for public read access (or restrict via CloudFront)

4. **Create CloudFront Distribution**:
   - Origin: Point to your S3 bucket (use S3 website endpoint or REST API endpoint)
   - Default root object: `index.html`
   - SSL Certificate: Request or import an ACM certificate for your domain
   - Behavior: Cache static assets, but configure cache behavior for `index.html` to avoid stale content

5. **Configure CORS on Backend**:
   - Your backend already has CORS enabled via `flask-cors`
   - Ensure your backend allows requests from your CloudFront domain:
     ```python
     # In app.py, you may need to specify allowed origins:
     CORS(app, origins=["https://your-frontend-domain.com"])
     ```

6. **DNS Configuration**:
   - Create a DNS A record (or CNAME) pointing to your CloudFront distribution

### Benefits
- ✅ Global CDN for faster content delivery
- ✅ Free SSL/TLS certificates via CloudFront
- ✅ Low-cost static hosting (S3 + CloudFront)
- ✅ Custom domain support
- ✅ Separation of concerns (static frontend, dynamic backend)

### Important Notes
- **CORS**: Your backend already has CORS enabled, which is required for S3-hosted frontend to call your API
- **API Endpoint**: Update `config.js` with your production backend URL before deployment
- **Cache Invalidation**: After deploying updates, invalidate CloudFront cache for `/index.html` and `/config.js` to ensure users get the latest version
- **Backend Deployment**: Your backend needs to be publicly accessible and configured to allow requests from your CloudFront domain

**NOTE**: Don't forgrt to add the user of docker hub as collabarator before pushing image in docker hub if you are using it. Thats a stupid mistake.

# FastAPI MongoDB Application

This is a simple FastAPI application that provides a key-value store using MongoDB.

---

## 🚀 How to Run Locally

### 1. Start MongoDB (using Docker)
If MongoDB is not running locally, start it using Docker:
```bash
docker run -d --name mongo -p 27017:27017 mongo:latest
# install dependencies
pip install -r requirements.txt

# start fastapi app
uvicorn main:app --host 0.0.0.0 --port 8000

#Build the Docker image:
docker build -t fastapi-app:v1 .

#Deploy on Kubernetes
kubectl apply -f fastapi-app.yaml

#Check the deployment:
kubectl get pods

#Forward port to localhost:
kubectl port-forward svc/fastapi-service 8000:8000

---

### 💡 **Next Steps:**
- Make sure all files are properly committed to your Git repository.
- Push the repo to GitHub using:
```bash
git add .
git commit -m "Initial commit"
git push origin main

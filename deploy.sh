#!/bin/bash

set -e  # Exit script on error
set -o pipefail
set -x  # Print commands for debugging

# Step 1: Start MongoDB using Docker
echo "Starting MongoDB container..."
if ! docker ps | grep -q "mongo"; then
  docker run -d --name mongodb -p 27017:27017 mongo:latest
  echo "MongoDB container started."
else
  echo "MongoDB is already running."
fi

# Step 2: Build and Push Docker Image
echo "Building Docker image for FastAPI service..."
docker build -t fastapi-app:v1 .

echo "Tagging Docker image..."
docker tag fastapi-app:v1 myregistry.com/fastapi-app:v1

echo "Pushing Docker image to registry..."
docker push myregistry.com/fastapi-app:v1

# Step 3: Deploy to Kubernetes
echo "Creating Kubernetes deployment..."
cat <<EOF > fastapi-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fastapi-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: fastapi-app
  template:
    metadata:
      labels:
        app: fastapi-app
    spec:
      containers:
        - name: fastapi-app
          image: myregistry.com/fastapi-app:v1
          ports:
            - containerPort: 8000
          env:
            - name: MONGO_URI
              value: "mongodb://mongodb:27017"
---
apiVersion: v1
kind: Service
metadata:
  name: fastapi-service
spec:
  type: ClusterIP
  selector:
    app: fastapi-app
  ports:
    - protocol: TCP
      port: 8000
      targetPort: 8000
EOF

echo "Applying Kubernetes manifest..."
kubectl apply -f fastapi-deployment.yaml

echo "Deployment successful!"

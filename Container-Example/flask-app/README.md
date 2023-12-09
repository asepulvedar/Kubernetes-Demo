# Authenticate Docker to GCR

gcloud auth configure-docker \
    us-central1-docker.pkg.dev

# Build the Docker Image with Docker with Artifact Registry Tag
docker build -t us-central1-docker.pkg.dev/alan-sandbox-393620/docker-repo/my-flask-app:v1 .

# Push the Image
docker push us-central1-docker.pkg.dev/alan-sandbox-393620/docker-repo/my-flask-app:v1

# Run the Image
docker run -p 80:80 us-central1-docker.pkg.dev/alan-sandbox-393620/docker-repo/my-flask-app:v

# Port forward from a Specific container
kubectl port-forward flask-app-deployment-7d8ffcbd6b-bndvd 8080:80

# Create a LoadBalancer
kubectl apply -f service.yaml

# Port forward to the service
### NAME                   TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
### my-flask-app-service   LoadBalancer   10.96.103.102   <pending>     80:30059/TCP   6m10s
kubectl port-forward service/my-flask-app-service 30059:80 
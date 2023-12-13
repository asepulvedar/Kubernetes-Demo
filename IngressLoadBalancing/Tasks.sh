# Create the Cluster
gcloud container clusters create-auto loadbalancedcluster

# Deploy app
kubectl apply -f web-deployment.yaml

# Exposing your Deployment inside the cluster
kubectl apply -f web-service.yaml

# Creating an Ingress resource
kubectl apply -f basic-ingress.yaml

# Check the ingress
kubectl get ingress basic-ingress

# (Optional) Configuring a static IP address
gcloud compute addresses create web-static-ip --global

kubectl apply -f basic-ingress-static.yaml

# (Optional) Serving multiple applications on a load balancer
kubectl apply -f web-deployment-v2.yaml

# Deploy service for app 2
kubectl apply -f web-service-v2.yaml

# Deploy Ingress
kubectl create -f fanout-ingress.yaml


## Deploy Nginx App
kubectl apply -f nginx-app.yaml

## Deploy Cluster IP Service
kubectl apply -f nginx-clusteripservice.yaml

## Modify ingress path
kubectl apply -f fanout-ingress-v2.yaml



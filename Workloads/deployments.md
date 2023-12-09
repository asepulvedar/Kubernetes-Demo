## Deploy an application and expose it via a L4 load balancer Service

### In Cloud Shell, create a deployment for the hello-app application:
kubectl create deployment hello-app --image=gcr.io/google-samples/hello-app:2.0


### In Cloud Shell, create a Kubernetes Service of type LoadBalancer to access the app:

kubectl expose deployment hello-app --name hello-app-service --type LoadBalancer --port 80 --target-port=8080


### Access the external IP provided by the hello-app-service:
curl 10.200.0.101

## Deploy an application and expose it via a L7 load balancer Ingress
### Create a second application deployment:
kubectl create deployment hello-kubernetes --image=gcr.io/google-samples/node-hello:1.0

### Create a Kubernetes Service of type NodePort to access the app. Notice that no external IP is associated:

kubectl expose deployment hello-kubernetes --name hello-kubernetes-service --type NodePort --port 32123 --target-port=8080

### Create a Kubernetes Ingress resource to route traffic between the two services:



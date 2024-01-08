## Istio Web Site
https://istio.io/latest/docs/setup/getting-started/

## Download Package
curl -L https://istio.io/downloadIstio | sh -

## Add Binary to PATH
export PATH=$PWD/bin:$PATH

## Install istio
istioctl install

## Demo App
### Clone Repo
git clone https://github.com/GoogleCloudPlatform/microservices-demo.git
### Deploy Demo App
cd microservices-demo/release/
kubectl apply -f kubernetes-manifests.yaml 

## Why don´t have two container in every pods?, because we need to configure the namespace
check: 
kubectl get ns default --show-labels

### Apply istio config in namaespace
kubectl label namespace default istio-injection=enabled

### Delete Services
kubectl delete -f kubernetes-manifests.yaml 

### Create Services Again
kubectl apply -f kubernetes-manifests.yaml 


## Istio Dashboards
### Kiali
kubectl apply -f /home/asepulvedar/istio-1.20.1/samples/addons/kiali.yaml
### Prometheus
kubectl apply -f /home/asepulvedar/istio-1.20.1/samples/addons/prometheus.yaml

### Jaeger
kubectl apply -f /home/asepulvedar/istio-1.20.1/samples/addons/jaeger.yamll



## Port forward to access to kubernetes service
(base) asepulvedar@local-sandbox:~/istio-1.20.1/samples/addons$ kubectl get services -n istio-system
NAME                   TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                                      AGE
istio-ingressgateway   LoadBalancer   10.101.215.90   <pending>     15021:30843/TCP,80:32502/TCP,443:32404/TCP   25m
istiod                 ClusterIP      10.102.184.47   <none>        15010/TCP,15012/TCP,443/TCP,15014/TCP        25m
kiali                  ClusterIP      10.98.104.90    <none>        20001/TCP,9090/TCP                           5m58s

### Port forward using microservice port
kubectl port-forward svc/kiali -n istio-system 20001

### Port forward to frontend service

(base) asepulvedar@local-sandbox:~$ kubectl get svc
NAME                    TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
adservice               ClusterIP      10.105.105.230   <none>        9555/TCP       23m
cartservice             ClusterIP      10.105.251.172   <none>        7070/TCP       23m
checkoutservice         ClusterIP      10.110.50.187    <none>        5050/TCP       23m
currencyservice         ClusterIP      10.106.173.205   <none>        7000/TCP       23m
emailservice            ClusterIP      10.100.48.120    <none>        5000/TCP       23m
frontend                ClusterIP      10.105.228.137   <none>        80/TCP         23m
frontend-external       LoadBalancer   10.110.93.47     <pending>     80:30940/TCP   23m
kubernetes              ClusterIP      10.96.0.1        <none>        443/TCP        54m
paymentservice          ClusterIP      10.105.146.40    <none>        50051/TCP      23m
productcatalogservice   ClusterIP      10.110.6.35      <none>        3550/TCP       23m
recommendationservice   ClusterIP      10.98.111.222    <none>        8080/TCP       23m
redis-cart              ClusterIP      10.98.45.87      <none>        6379/TCP       23m
shippingservice         ClusterIP      10.100.38.22     <none>        50051/TCP      23m


### Port Forward
kubectl port-forward svc/frontend -n default 8000:80

### Notes: port 80 is the port used by the cluster service, 81, is the port of the vm to recieve the traffic and use in my computer
## Access to the service: http://127.0.0.1:8000



## Extra: port forward to my macos
### FrontEnd
ssh -L 8000:localhost:8000 sandbox1

### Kialiy
ssh -L 20001:localhost:20001 sandbox1

### Nodeport Service Access with Minikube
minikube service hello-minikube --url






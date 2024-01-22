### Deploy the demo application
kubectl apply -f store-deployment.yaml --context=gke-west-2
kubectl apply -f store-deployment.yaml --context=gke-east-1

### Create the Service and ServiceExports for the gke-west-2 cluster:
kubectl apply -f store-west-service.yaml --context=gke-west-2

### Create the Service and ServiceExports for the gke-east-1 cluster:
kubectl apply -f store-east-service.yaml --context=gke-east-1

## Make sure that the service exports have been successfully created:

kubectl get serviceexports --context gke-west-2 --namespace store
kubectl get serviceexports --context gke-east-1 --namespace store

## Deploy the Gateway and HTTPRoutes
Gateway and HTTPRoutes are resources deployed in the Config cluster, which in this case is the gke-west-1 cluster.

Platform administrators manage and deploy Gateways to centralize security policies such as TLS.

Service Owners in different teams deploy HTTPRoutes in their own namespace so that they can independently control their routing logic.

### Deploy the Gateway in the gke-west-1 config cluster:

kubectl apply -f external-http-gateway.yaml --context=gke-west-1

### Deploy the HTTPRoute in the gke-west-1 config cluster:
kubectl apply -f public-store-route.yaml --context=gke-west-1

### Obtener la IP del Gateway
kubectl describe gateway external-http --context gke-west-1 --namespace store

### Get the external IP created by the Gateway:

EXTERNAL_IP=$(kubectl get gateway external-http -o=jsonpath="{.status.addresses[0].value}" --context gke-west-1 --namespace store)
echo $EXTERNAL_IP

curl -H "host: store.example.com" http://${EXTERNAL_IP}
curl -H "host: store.example.com" http://${EXTERNAL_IP}/east
curl -H "host: store.example.com" http://${EXTERNAL_IP}/west


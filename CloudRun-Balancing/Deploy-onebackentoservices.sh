#%% Deploy Services
# En este laboratorio se despliegan 2 servicios en diferentes regiones, y aunque sean dferentes versiones de la app, solo
tiene como finalizad demostrar el balanceo de 2 servicios en diferentes zonas con una sola dirección IP.
# Deploy Cloud Run service for Hello World 1

gcloud run deploy hello-app-v1 \
  --image=us-docker.pkg.dev/google-samples/containers/gke/hello-app:1.0\
  --allow-unauthenticated \
  --port=8080 \
  --min-instances=0 \
  --max-instances=1 \
  --cpu-boost \
  --region=us-central1 \
  --ingress=all


# Deploy Cloud Run service for Hello World 2
gcloud run deploy hello-app-v2 \
  --image=us-docker.pkg.dev/google-samples/containers/gke/hello-app:2.0\
  --allow-unauthenticated \
  --port=8080 \
  --min-instances=0 \
  --max-instances=1 \
  --cpu-boost \
  --region=us-west1 \
  --ingress=all

# Create the ip addres
gcloud compute addresses create helloworld-ip \
    --network-tier=PREMIUM \
    --ip-version=IPV4 \
    --global

# List reserved ip
gcloud compute addresses describe helloworld-ip \
    --format="get(address)" \
    --global

# Create backend services(NEG) for each Hello World container v1
gcloud compute network-endpoint-groups create helloworld1-backend \
  --region=us-central1 \
  --network-endpoint-type=SERVERLESS \
  --cloud-run-service=hello-app-v1

# Create backend services(NEG) for each Hello World container v2
gcloud compute network-endpoint-groups create helloworld2-backend \
  --region=us-west1 \
  --network-endpoint-type=SERVERLESS \
  --cloud-run-service=hello-app-v2


# Curl the url
# v1
 curl -H "Host: web.helloworld.com" http://34.160.2.19:8080/v1
 # v2
  curl -H "Host: web.helloworld.com" http://34.160.2.19:8080/v2




## Delete IP
gcloud compute addresses delete helloworld-ip --global

# Delete NEGS
gcloud compute network-endpoint-groups delete helloworld1-backend  --region=us-central1
gcloud compute network-endpoint-groups delete helloworld2-backend  --region=us-west1


## Simular trafico
for i in {1..10}; do
  curl http://34.36.178.73:8080/
  echo "Iteration $i completed"
  sleep 1
done


wrk -t1 -c1 -d30s http://34.36.178.73:8080/

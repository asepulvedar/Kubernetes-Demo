#%% Deploy Services

Se tienen 2 servicios (v1=hello-app:1.0, v2=hello-app:1.0) de Cloud Run en diferentes regiones y
una vez desplegadas se crea in Load Balancer para con base un NEG tipo SERVERLESS balancear entre las versiones
desplegadas en distintas regiones a travez de la IP el balancer y el path, Ej:  http://IP_BALANCER:8080/v1

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
  --max-instances=2 \
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


## Simular trafico


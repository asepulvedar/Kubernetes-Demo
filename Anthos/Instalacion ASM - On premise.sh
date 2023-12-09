## 1. Create an overlay file that will be used in the Anthos Service Mesh installation to enable Cloud Trace:
cat <<'EOF' > cloud-trace.yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
    meshConfig:
        enableTracing: true
    values:
            global:
                proxy:
                        tracer: stackdriver
EOF

## 2.- Download the asmcli tool to install Anthos Service Mesh on your cluster:
curl https://storage.googleapis.com/csm-artifacts/asm/asmcli_1.15 > asmcli
chmod +x asmcli

## 3.- Clean up the environment variables to make sure there are no conflicts with Kubeconfig when installing Anthos Service Mesh:

export PROJECT_ID=
export CLUSTER_NAME=
export CLUSTER_LOCATION=


## 4.- Install Anthos Service Mesh in your cluster using the Cloud Trace overlay:


export FLEET_PROJECT_ID=$(gcloud config get-value project)
./asmcli install \
    --kubeconfig kind-kind \
    --fleet_id $FLEET_PROJECT_ID \
    --output_dir . \
    --platform multicloud \
    --enable_all \
    --ca mesh_ca \
    --custom_overlay cloud-trace.yaml


## 5.- Create and label a demo namespace to enable automatic sidecar injection:
export ASM_REV=$(kubectl -n istio-system get pods -l app=istiod -o json | jq -r '.items[0].metadata.labels["istio.io/rev"]')
kubectl create namespace demo
kubectl label namespace demo istio.io/rev=$ASM_REV --overwrite


## 6.- Install the Hipster Shop application in the demo namespace:
kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/microservices-demo/master/release/kubernetes-manifests.yaml -n demo
kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/microservices-demo/master/release/istio-manifests.yaml -n demo
kubectl patch deployments/productcatalogservice -p '{"spec":{"template":{"metadata":{"labels":{"version":"v1"}}}}}' -n demo


## 7.- Install de Ingress Gateway

git clone https://github.com/GoogleCloudPlatform/anthos-service-mesh-packages
kubectl apply -f anthos-service-mesh-packages/samples/gateways/istio-ingressgateway -n demo

## 8.- Cofigure the Gateway
kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/microservices-demo/master/release/istio-manifests.yaml -n demo


## Get pods
kubectl get pods -n demo

## 
kubectl get svc istio-ingressgateway -n demo


curl 10.200.0.103




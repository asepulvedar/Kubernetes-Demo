
# Install Anthos Service Mesh - OnPrem
## Task 9. Install Anthos Service Mesh
Come back to the Cloud Shell window you were using to SSH into the admin workstation. Create an overlay file that will be used in the Anthos Service Mesh installation to enable Cloud Trace:

<p><code>

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
</code></p>

Download the asmcli tool to install Anthos Service Mesh on your cluster:

<p><code>
curl https://storage.googleapis.com/csm-artifacts/asm/asmcli_1.15 > asmcli
chmod +x asmcli
</code></p>

Clean up the environment variables to make sure there are no conflicts with Kubeconfig when installing Anthos Service Mesh:

<p><code>
export PROJECT_ID=
export CLUSTER_NAME=
export CLUSTER_LOCATION=
</code></p>

## Install Anthos Service Mesh in your cluster using the Cloud Trace overlay:
<p><code>
export FLEET_PROJECT_ID=$(gcloud config get-value project)
./asmcli install \
    --kubeconfig ./bmctl-workspace/abm-hybrid-cluster/abm-hybrid-cluster-kubeconfig \
    --fleet_id $FLEET_PROJECT_ID \
    --output_dir . \
    --platform multicloud \
    --enable_all \
    --ca mesh_ca \
    --custom_overlay cloud-trace.yaml
</code></p>


## Task 10. Explore application tracing
Create and label a demo namespace to enable automatic sidecar injection:
<p><code>
export ASM_REV=$(kubectl -n istio-system get pods -l app=istiod -o json | jq -r '.items[0].metadata.labels["istio.io/rev"]')
kubectl create namespace demo
kubectl label namespace demo istio.io/rev=$ASM_REV --overwrite
</code></p>

Install the Hipster Shop application in the demo namespace:
<p><code>
kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/microservices-demo/master/release/kubernetes-manifests.yaml -n demo
kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/microservices-demo/master/release/istio-manifests.yaml -n demo
kubectl patch deployments/productcatalogservice -p '{"spec":{"template":{"metadata":{"labels":{"version":"v1"}}}}}' -n demo
</code></p>

To be able to access the application from outside the cluster, install the ingress Gateway:

<p><code>
git clone https://github.com/GoogleCloudPlatform/anthos-service-mesh-packages
kubectl apply -f anthos-service-mesh-packages/samples/gateways/istio-ingressgateway -n demo
</code></p>

Configure the Gateway:

<p><code>
kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/microservices-demo/master/release/istio-manifests.yaml -n demo
</code></p>

View the Hipster Shop pods that have been created in the demo namespace. Notice that they have a 2/2 in a ready state. That means that the two containers are ready, including the application container and the mesh sidecar container.

<p><code>
kubectl get pods -n demo
</code></p>


Get the external IP from the istio-ingressgateway to access the Hipster Shop that you just deployed:
<p><code>
kubectl get svc istio-ingressgateway -n demo
</code></p>


Access the Hipster Shop using the IP you copied in the previous task:

curl 10.200.0.103
</code></p>

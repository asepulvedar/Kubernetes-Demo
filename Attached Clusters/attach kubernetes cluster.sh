

## Activar el SDK
gcloud auth activate-service-account anthos-onprem@qwiklabs-gcp-00-bde5021db503.iam.gserviceaccount.com --key-file="/Users/alan.sepulveda/Documents/GitHub/Kubernetes-Demo/Attached Clusters/key.json" --project=qwiklabs-gcp-00-bde5021db503

gcloud services enable --project=qwiklabs-gcp-00-bde5021db503\
   anthos.googleapis.com \
   gkehub.googleapis.com


## Registrar el Cluster en el HUB
gcloud container hub memberships register kind-kind --project=qwiklabs-gcp-00-bde5021db503 --context=kind-kind --kubeconfig=${KUBECONFIG} --service-account-key-file="/Users/alan.sepulveda/Documents/GitHub/Kubernetes-Demo/Attached Clusters/key.json"

## Hacer el ClusterRole en el Cluster de Kubernetes y hacer agregar ese role a nivel Cluster

kubectl create serviceaccount -n kube-system admin-user
kubectl create clusterrolebinding admin-user-binding \
--clusterrole cluster-admin --serviceaccount kube-system:admin-user

## Crear el secret, el cual va asociado a la cuenta de servicio

cat <<EOF > service-secret.yaml
apiVersion: v1
kind: Secret
type: kubernetes.io/service-account-token
metadata:
  name: mysecretname
  annotations:
    kubernetes.io/service-account.name: admin-user
EOF

kubectl apply -f service-secret.yaml -n kube-system

## Obtener el Token del Secret
kubectl get secret -n kube-system mysecretname -o jsonpath='{$.data.token}' \
| base64 -d | sed $'s/$/\\\n/g'




##  En Google Cloud, obtener las credenciales
gcloud container fleet memberships get-credentials kind-kind
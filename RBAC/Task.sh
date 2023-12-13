# Crear el Cluster:
gcloud container clusters create-auto autopilot-cluster-1  --region=us-central1

# Crear la cuenta de servicio
## Con Permisos solo para ver componentes
#Permiso: Kubernetes Engine Viewer

## Autenticarse con la cuenta de servicio
# Kubernetes Engine Viewer

gcloud auth activate-service-account --key-file  /Users/alan.sepulveda/Documents/GitHub/Kubernetes-Demo/RBAC/alan-sandbox-393620-713939a97276.json

gcloud container clusters get-credentials autopilot-cluster-1  --region=us-central1

gcloud components install gke-gcloud-auth-plugin


## Intentar crear un pod con el service account
kubectl apply -f nginx-app.yaml

## Error:
# Error from server (Forbidden):
# error when creating "pod-app.yaml": deployments.apps is forbidden:
# User "demo-roles-sa@alan-sandbox-393620.iam.gserviceaccount.com" cannot create resource "deployments"
# in API group "apps" in the namespace "default": requires one of ["container.deployments.create"] permission(s).

# Autenticarme como Alan
gcloud auth login

gcloud config set account `ACCOUNT`

# Borrar el contexto
kubectl config delete-context [CONTEXT]
## Obtener las credenciales de nuevo con mi usuario
gcloud container clusters get-credentials autopilot-cluster-1  --region=us-central1



# Crear namespace
kubectl create namespace accounting


# Crear el rol
kubectl apply -f role.yaml

# Crear el Binding Role
 kubectl apply -f role-binding.yaml

 kubectl get roles -n accounting
 kubectl describe roles -n accounting

kubectl get rolebinding -n accounting
kubectl describe rolebinding -n accounting

## Autenticarse con la cuenta de servicio
kubectl config delete-context gke_alan-sandbox-393620_us-central1_autopilot-cluster-1

gcloud auth activate-service-account --key-file  /Users/alan.sepulveda/Documents/GitHub/Kubernetes-Demo/RBAC/alan-sandbox-393620-713939a97276.json

gcloud container clusters get-credentials autopilot-cluster-1  --region=us-central1

kubectl apply -f pod-app.yaml -n accounting
## Done
kubectl get pods -n accounting
kubectl describe  pods -n accounting
kubectl delete  pods hello -n accounting

# Error:
# Error from server (Forbidden): pods "hello" is forbidden:
# User "demo-roles-sa@alan-sandbox-393620.iam.gserviceaccount.com" cannot delete resource "pods"
# in API group "" in the namespace "accounting": requires one of ["container.pods.delete"] permission(s).

kubectl apply -f pod-app.yaml -n default
# Error

# Error from server (Forbidden): error when creating "pod-app.yaml":
# pods is forbidden: User "demo-roles-sa@alan-sandbox-393620.iam.gserviceaccount.com"
# cannot create resource "pods" in API group "" in the namespace "default": requires one of ["container.pods.create"] permission(s).



# Eliminar Cluster
gcloud config set account
gcloud container clusters delete autopilot-cluster-1  --region=us-central1




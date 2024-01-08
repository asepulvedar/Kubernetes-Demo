## Instalar Docker (Servidor)
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh


## Instalar Docker Desktop
https://www.docker.com/products/docker-desktop

## Instalar Kind on MacOS
brew install kind

## Crear Cluster con Archivo de Configuracion
kind create cluster --config create-cluster.yaml

## Explorar el cluster
kubectl cluster-info --context kind-kind

## Eliminar el cluster
 kind delete cluster
# switch to west context
kubectx west

## Esta es la instalacion donde el control plane se instala dentro del cluster
# install Anthos Service Mesh
./asmcli install \
  --project_id $PROJECT_ID \
  --cluster_name $C1_NAME \
  --cluster_location $C1_LOCATION \
  --fleet_id $FLEET_PROJECT_ID \
  --output_dir $DIR_PATH \
  --enable_all \
  --ca mesh_ca

# Configurar el DataPlane

## Agregar las etiquetas en los namespaces para habilitar la injección de los sidecar 
### Como es la version manual, necesitamos especificar la version de istio que instalamos
kubectl label ns $GATEWAY_NAMESPACE \
  istio.io/rev=$(kubectl -n istio-system get pods -l app=istiod -o json | jq -r '.items[0].metadata.labels["istio.io/rev"]') \
  --overwrite



## Instalar el Gateway
"""
Note: Anthos Service Mesh gives you the option to deploy and manage gateways as part of your service mesh. A gateway describes a load balancer operating at the edge of the mesh receiving incoming or outgoing HTTP/TCP connections. Gateways are Envoy proxies that provide you with fine-grained control over traffic entering and leaving the mesh.
To set up your ingress gateway, you create a namespace for the gateway components, then apply the manifests in the ingress-gateway directory to create the necessary resources on your cluster.
You can take a few minutes to view the contents of the manifests in the ingress-gateway directory to better understand what's being deployed. You should see:
A deployment for the gateway pods, along with autoscaling and disruption budget configurations.
A service that exposes the deployment.
A service account, a customer role, and a rolebinding granting the role to the new service account.

"""
# create the gateway namespace
kubectl create namespace $GATEWAY_NAMESPACE
# enable sidecar injection on the gateway namespace
kubectl label ns $GATEWAY_NAMESPACE \
  istio.io/rev=$(kubectl -n istio-system get pods -l app=istiod -o json | jq -r '.items[0].metadata.labels["istio.io/rev"]') \
  --overwrite
# Apply the configurations
kubectl apply -n $GATEWAY_NAMESPACE \
  -f $DIR_PATH/samples/gateways/istio-ingressgateway






  ## Esta es la instalacion ASM Administrado
./asmcli install \
  --project_id $PROJECT_ID \
  --cluster_name $C1_NAME \
  --cluster_location $C1_LOCATION \
  --fleet_id $FLEET_PROJECT_ID \
  --output_dir $DIR_PATH \
  --enable_all \
  --managed \
  --ca mesh_ca  
## con el flag managed: ## Aqui especificamos que quermeos la version administrada

# Configurar el DataPlane

## Agregar las etiquetas en los namespaces para habilitar la injección de los sidecar 

kubectl label namespace $GATEWAY_NAMESPACE istio.io/rev=asm-managed



## Esta nota viene en el LAB: AHYBRID041 Observing Anthos Services
## La cual dice que: "To enable Google to manage your data plane so that the sidecar proxies will be automatically updated for you, annotate the namespace:""
kubectl annotate --overwrite namespace default \
  mesh.cloud.google.com/proxy='{"managed":"true"}'



## Instalar el Gatewey

# create the gateway namespace
kubectl create namespace $GATEWAY_NAMESPACE
# enable sidecar injection on the gateway namespace
kubectl label ns $GATEWAY_NAMESPACE istio.io/rev=asm-managed --overwrite
# Apply the configurations
kubectl apply -n $GATEWAY_NAMESPACE \
  -f $DIR_PATH/samples/gateways/istio-ingressgateway


# Configura el Mesh, para que dos clusters se puedan comunicar
## 1.- Crear las reglas Firewall, en donde se especifica el rango de ip de los Pods (CIDR)
 function join_by { local IFS="$1"; shift; echo "$*"; }
 # get the service IP CIDRs for each cluster
 ALL_CLUSTER_CIDRS=$(gcloud container clusters list \
   --filter="name:($C1_NAME,$C2_NAME)" \
   --format='value(clusterIpv4Cidr)' | sort | uniq)
 ALL_CLUSTER_CIDRS=$(join_by , $(echo "${ALL_CLUSTER_CIDRS}"))
 # get the network tags for each cluster
 ALL_CLUSTER_NETTAGS=$(gcloud compute instances list  \
   --filter="name:($C1_NAME,$C2_NAME)" \
   --format='value(tags.items.[0])' | sort | uniq)
 ALL_CLUSTER_NETTAGS=$(join_by , $(echo "${ALL_CLUSTER_NETTAGS}"))
 # create the firewall rule allowing traffic between the clusters
 gcloud compute firewall-rules create istio-multi-cluster-pods \
     --allow=tcp,udp,icmp,esp,ah,sctp \
     --direction=INGRESS \
     --priority=900 \
     --source-ranges="${ALL_CLUSTER_CIDRS}" \
     --target-tags="${ALL_CLUSTER_NETTAGS}" --quiet



## Agregar los Clusters al mesh
### Para que cada clúster descubra los endpoitns en el otro clúster, 
### todos los clústeres deben estar registrados en la misma flota, y 
### cada clúster debe configurarse con un secreto que se puede usar para obtener acceso 
### al servidor API del otro clúster para la enumeración de puntos finales. La utilidad asmcli configurará esto por usted.
./asmcli create-mesh \
    $FLEET_PROJECT_ID \
    ${PROJECT_ID}/${C1_LOCATION}/${C1_NAME} \
    ${PROJECT_ID}/${C2_LOCATION}/${C2_NAME}

## Para mas detalle, ver el laboratorio: AHYBRID081 Configuring a multi-cluster mesh with Anthos Service Mesh


#

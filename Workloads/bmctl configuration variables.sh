 bmctl configuration variables. Because this section is valid YAML but not a valid Kubernetes
# resource, this section can only be included when using bmctl to
# create the initial admin/hybrid cluster. Afterwards, when creating user clusters by directly
# applying the cluster and node pool resources to the existing cluster, you must remove this
# section.
gcrKeyPath: bmctl-workspace/.sa-keys/qwiklabs-gcp-03-183b72f64708-anthos-baremetal-gcr.json
sshPrivateKeyPath: /root/.ssh/id_rsa
gkeConnectAgentServiceAccountKeyPath: bmctl-workspace/.sa-keys/qwiklabs-gcp-03-183b72f64708-anthos-baremetal-connect.json
gkeConnectRegisterServiceAccountKeyPath: bmctl-workspace/.sa-keys/qwiklabs-gcp-03-183b72f64708-anthos-baremetal-register.json
cloudOperationsServiceAccountKeyPath: bmctl-workspace/.sa-keys/qwiklabs-gcp-03-183b72f64708-anthos-baremetal-cloud-ops.json
---
apiVersion: v1
kind: Namespace
metadata:
  name: cluster-abm-hybrid-cluster
---
apiVersion: baremetal.cluster.gke.io/v1
kind: Cluster
metadata:
  name: abm-hybrid-cluster
  namespace: cluster-abm-hybrid-cluster
spec:
  # Cluster type. This can be:
  #   1) admin:  to create an admin cluster. This can later be used to create user clusters.
  #   2) user:   to create a user cluster. Requires an existing admin cluster.
  #   3) hybrid: to create a hybrid cluster that runs admin cluster components and user workloads.
  #   4) standalone: to create a cluster that manages itself, runs user workloads, but does not manage other clusters.
  type: hybrid
  # Cluster profile. This can be either 'default' or 'edge'.
  # The edge profile is tailored for deployments on the edge locations
  # and should be used together with the 'standalone' cluster type.
  profile: default
  # Anthos cluster version.
  anthosBareMetalVersion: 1.12.0
  # GKE connect configuration
  gkeConnect:
    projectID: qwiklabs-gcp-03-183b72f64708
  # Control plane configuration
  controlPlane:
    nodePoolSpec:
      nodes:
      # Control plane node pools. Typically, this is either a single machine
      # or 3 machines if using a high availability deployment.
      - address: 10.200.0.3
  # Cluster networking configuration
  clusterNetwork:
    # Pods specify the IP ranges from which pod networks are allocated.
    pods:
      cidrBlocks:
      - 192.168.0.0/16
    # Services specify the network ranges from which service virtual IPs are allocated.
    # This can be any RFC1918 range that does not conflict with any other IP range
    # in the cluster and node pool resources.
    services:
      cidrBlocks:
      - 10.96.0.0/20
  # Load balancer configuration
  loadBalancer:
    # Load balancer mode can be either 'bundled' or 'manual'.
    # In 'bundled' mode a load balancer will be installed on load balancer nodes during cluster creation.
    # In 'manual' mode the cluster relies on a manually-configured external load balancer.
    mode: bundled
    # Load balancer port configuration
    ports:
      # Specifies the port the load balancer serves the Kubernetes control plane on.
      # In 'manual' mode the external load balancer must be listening on this port.
      controlPlaneLBPort: 443
    # There are two load balancer virtual IP (VIP) addresses: one for the control plane
    # and one for the L7 Ingress service. The VIPs must be in the same subnet as the load balancer nodes.
    # These IP addresses do not correspond to physical network interfaces.
    vips:
   --   # ControlPlaneVIP specifies the VIP to connect to the Kubernetes API server.
      # This address must not be in the address pools below.
      controlPlaneVIP: 10.200.0.99
      # IngressVIP specifies the VIP shared by all services for ingress traffic.
      # Allowed only in non-admin clusters.
      # This address must be in the address pools below.
      ingressVIP: 10.200.0.100
    # AddressPools is a list of non-overlapping IP ranges for the data plane load balancer.
    # All addresses must be in the same subnet as the load balancer nodes.
    # Address pool configuration is only valid for 'bundled' LB mode in non-admin clusters.
    addressPools:
    - name: pool1
      addresses:
    #   # Each address must be either in the CIDR form (1.2.3.0/24)
    #   # or range form (1.2.3.1-1.2.3.5).
      - 10.200.0.100-10.200.0.200
    # A load balancer node pool can be configured to specify nodes used for load balancing.
    # These nodes are part of the Kubernetes cluster and run regular workloads as well as load balancers.
    # If the node pool config is absent then the control plane nodes are used.
    # Node pool configuration is only valid for 'bundled' LB mode.
    # nodePoolSpec:
    #  nodes:
    #  - address: 10.200.0.3
  # Proxy configuration
  # proxy:
  #   url: http://[username:password@]domain
  #   # A list of IPs, hostnames or domains that should not be proxied.
  #   noProxy:
  #   - 127.0.0.1
  #   - localhost
  # Logging and Monitoring
  clusterOperations:
    # Cloud project for logs and metrics.
    projectID: qwiklabs-gcp-03-183b72f64708
    # Cloud location for logs and metrics.
    location: us-central1
    # Whether collection of application logs/metrics should be enabled (in addition to
    # collection of system logs/metrics which correspond to system components such as
    # Kubernetes control plane or cluster management agents).
    enableApplication: true
  # Storage configuration
  storage:
    # lvpNodeMounts specifies the config for local PersistentVolumes backed by mounted disks.
    # These disks need to be formatted and mounted by the user, which can be done before or after
    # cluster creation.
    lvpNodeMounts:
      # path specifies the host machine path where mounted disks will be discovered and a local PV
      # will be created for each mount.
      path: /mnt/localpv-disk
      # storageClassName specifies the StorageClass that PVs will be created with. The StorageClass
      # is created during cluster creation.
      storageClassName: local-disks
    # lvpShare specifies the config for local PersistentVolumes backed by subdirectories in a shared filesystem.
    # These subdirectories are automatically created during cluster creation.
    lvpShare:
      # path specifies the host machine path where subdirectories will be created on each host. A local PV
      # will be created for each subdirectory.
      path: /mnt/localpv-share
      # storageClassName specifies the StorageClass that PVs will be created with. The StorageClass
      # is created during cluster creation.
      storageClassName: local-shared
      # numPVUnderSharedPath specifies the number of subdirectories to create under path.
      numPVUnderSharedPath: 5
  # NodeConfig specifies the configuration that applies to all nodes in the cluster.
  nodeConfig:
    # podDensity specifies the pod density configuration.
    podDensity:
      # maxPodsPerNode specifies at most how many pods can be run on a single node.
      maxPodsPerNode: 250
    # containerRuntime specifies which container runtime to use for scheduling containers on nodes.
    # containerd and docker are supported. docker will not be supported starting with Anthos Bare Metal version 1.13.
    containerRuntime: containerd
  # Authentication; uncomment this section if you wish to enable authentication to the cluster with OpenID Connect.
  # authentication:
  #   oidc:
  #     # issuerURL specifies the URL of your OpenID provider, such as "https://accounts.google.com". The Kubernetes API
  #     # server uses this URL to discover public keys for verifying tokens. Must use HTTPS.
  #     issuerURL: <URL for OIDC Provider; required>
  #     # clientID specifies the ID for the client application that makes authentication requests to the OpenID
  #     # provider.
  #     clientID: <ID for OIDC client application; required>
  #     # clientSecret specifies the secret for the client application.
  #     clientSecret: <Secret for OIDC client application; optional>
  #     # kubectlRedirectURL specifies the redirect URL (required) for the gcloud CLI, such as
  #     # "http://localhost:[PORT]/callback".
  #     kubectlRedirectURL: <Redirect URL for the gcloud CLI; optional, default is "http://kubectl.redirect.invalid">
  #     # username specifies the JWT claim to use as the username. The default is "sub", which is expected to be a
  #     # unique identifier of the end user.
  #     username: <JWT claim to use as the username; optional, default is "sub">
  #     # usernamePrefix specifies the prefix prepended to username claims to prevent clashes with existing names.
  #     usernamePrefix: <Prefix prepended to username claims; optional>
  #     # group specifies the JWT claim that the provider will use to return your security groups.
  #     group: <JWT claim to use as the group name; optional>
  #     # groupPrefix specifies the prefix prepended to group claims to prevent clashes with existing names.
  #     groupPrefix: <Prefix prepended to group claims; optional>
  #     # scopes specifies additional scopes to send to the OpenID provider as a comma-delimited list.
  #     scopes: <Additional scopes to send to OIDC provider as a comma-separated list; optional>
  #     # extraParams specifies additional key-value parameters to send to the OpenID provider as a comma-delimited
  #     # list.
  #     extraParams: <Additional key-value parameters to send to OIDC provider as a comma-separated list; optional>
  #     # proxy specifies the proxy server to use for the cluster to connect to your OIDC provider, if applicable.
  #     # Example: https://user:password@10.10.10.10:8888. If left blank, this defaults to no proxy.
  #     proxy: <Proxy server to use for the cluster to connect to your OIDC provider; optional, default is no proxy>
  #     # deployCloudConsoleProxy specifies whether to deploy a reverse proxy in the cluster to allow Google Cloud
  #     # Console access to the on-premises OIDC provider for authenticating users. If your identity provider is not
  #     # reachable over the public internet, and you wish to authenticate using Google Cloud Console, then this field
  #     # must be set to true. If left blank, this field defaults to false.
  #     deployCloudConsoleProxy: <Whether to deploy a reverse proxy for Google Cloud Console authentication; optional>
  #     # certificateAuthorityData specifies a Base64 PEM-encoded certificate authority certificate of your identity
  #     # provider. It's not needed if your identity provider's certificate was issued by a well-known public CA.
  #     # However, if deployCloudConsoleProxy is true, then this value must be provided, even for a well-known public
  #     # CA.
  #     certificateAuthorityData: <Base64 PEM-encoded certificate authority certificate of your OIDC provider; optional>
  # Node access configuration; uncomment this section if you wish to use a non-root user
  # with passwordless sudo capability for machine login.
  # nodeAccess:
  #   loginUser: <login user name>
---
# Node pools for worker nodes
apiVersion: baremetal.cluster.gke.io/v1
kind: NodePool
metadata:
  name: hybrid-cluster-pool-1
  namespace: cluster-abm-hybrid-cluster
spec:
  clusterName: abm-hybrid-cluster
  nodes:
  - address: 10.200.0.4
  - address: 10.200.0.5
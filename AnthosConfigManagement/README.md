
## Install the Config Management Operator on all the cluster

gsutil cp gs://config-management-release/released/latest/config-management-operator.yaml config-management-operator.yaml

### Install on all the Clusters
kubectl apply -f config-management-operator.yaml

## Install the nomos command-line tool in Cloud Shell

gsutil cp gs://config-management-release/released/latest/linux_amd64/nomos nomos
chmod +x ./nomos

git clone https://github.com/GoogleCloudPlatform/training-data-analyst

cd ./training-data-analyst/courses/ahybrid/v1.0/AHYBRID071/config


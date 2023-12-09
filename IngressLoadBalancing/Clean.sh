### Clean
kubectl delete ingress basic-ingress

kubectl delete ingress fanout-ingress

gcloud compute addresses delete web-static-ip --global
gcloud container clusters delete loadbalancedcluster

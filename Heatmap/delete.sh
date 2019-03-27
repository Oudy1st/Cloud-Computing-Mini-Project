export PROJECT_ID="$(gcloud config get-value project -q)"

kubectl delete service heatmap-server

gcloud container clusters delete heatmap-cluster

gcloud container images delete gcr.io/$PROJECT_ID/heatmap:v1
kubectl delete deployment heatmap-server

docker image rm gcr.io/$PROJECT_ID/heatmap:v1
docker image rm python:3.7

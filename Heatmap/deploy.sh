export PROJECT_ID="$(gcloud config get-value project -q)"
gcloud config set project $PROJECT_ID
gcloud config set compute/zone us-central1-b

docker build -t gcr.io/${PROJECT_ID}/heatmap:v1 .
gcloud auth configure-docker
docker push gcr.io/${PROJECT_ID}/heatmap:v1

gcloud container clusters create heatmap-cluster --num-nodes=3

kubectl run web-app-server --image=gcr.io/${PROJECT_ID}/heatmap:v1 --port 8080

kubectl expose deployment web-app-server --type=LoadBalancer --port 80 --target-port 8080

kubectl scale deployment web-app-server --replicas=4

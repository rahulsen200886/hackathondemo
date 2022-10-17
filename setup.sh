#!/bin/bash
sed 's/\r$//' dockerentry.sh >dockerentry.sh.tmp
cp dockerentry.sh.tmp dockerentry.sh
echo "Place holder to selecting cluster sizing options :Example :
Press 1 for 3 node 2 cpu 4GB cluster
Press 2 for 3 node 4 cpu 8GB cluster
"
read size
echo "Place holder to selecting compute region options :Example :
Press 1 US
Press 2 EU
"
read region
echo "Now I am creating your custom cluster and setting up the ecosystem .. .. "
sed -i "s/replaceme/${DEVSHELL_PROJECT_ID}-nas-bucket/g" Dockerfile
sed -i "s/changeme/${DEVSHELL_PROJECT_ID}/g" createcuster.tf
docker build . -t smbshare1
docker tag smbshare1 gcr.io/${DEVSHELL_PROJECT_ID}/smshare.v0.1
docker push gcr.io/${DEVSHELL_PROJECT_ID}/smshare.v0.1
terraform init
terraform apply -auto-approve
gcloud container clusters get-credentials my-gke-cluster --region us-central1 --project ${DEVSHELL_PROJECT_ID}
gsutil mb gs://${DEVSHELL_PROJECT_ID}-nas-bucket
sed -i "s/NAS-BUK/${DEVSHELL_PROJECT_ID}-nas-bucket/g" gkeyml/nas.yaml
gcloud iam service-accounts create smbnfsshare-sa --display-name="My Custom Service Account"
gsutil iam ch serviceAccount:smbnfsshare-sa@${DEVSHELL_PROJECT_ID}.iam.gserviceaccount.com:objectAdmin gs://${DEVSHELL_PROJECT_ID}-nas-bucket
gsutil iam ch serviceAccount:service-account-id@${DEVSHELL_PROJECT_ID}.iam.gserviceaccount.com:objectAdmin gs://artifacts.${DEVSHELL_PROJECT_ID}.appspot.com
gsutil iam ch serviceAccount:service-account-id@${DEVSHELL_PROJECT_ID}.iam.gserviceaccount.com:objectAdmin gs://${DEVSHELL_PROJECT_ID}-nas-bucket
gcloud iam service-accounts keys create ./key.json --iam-account=smbnfsshare-sa@${DEVSHELL_PROJECT_ID}.iam.gserviceaccount.com
kubectl create secret generic sa-account  --from-file=./key.json
#gcloud container clusters update my-gke-cluster  --update-addons=HttpLoadBalancing=ENABLED --region=us-central1
rm -f ./key.json
sed -i "s/PROJECT_NAME/${DEVSHELL_PROJECT_ID}/g" gkeyml/nas.yaml
kubectl apply -f gkeyml/nas.yaml

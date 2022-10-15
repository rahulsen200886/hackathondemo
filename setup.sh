!#/bin/bash
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

gcloud container clusters create example-cluster --zone us-central1-a 
gsutil mb gs://${DEVSHELL_PROJECT_ID}-nas-bucket
sed -i 's/NAS-BUK/${DEVSHELL_PROJECT_ID}-nas-bucket/g' nas.yaml
gcloud iam service-accounts create smbnfsshare-sa --display-name="My Custom Service Account"
gsutil iam ch serviceAccount:smbnfsshare-sa@${DEVSHELL_PROJECT_ID}.iam.gserviceaccount.com:objectAdmin gs://${DEVSHELL_PROJECT_ID}-nas-bucket
gcloud iam service-accounts keys create ./key.json --iam-account=smbnfsshare-sa@${DEVSHELL_PROJECT_ID}.iam.gserviceaccount.com
kubectl create secret generic sa-account  --from-file=./key.json
rm -f ./key.json
docker build . -t smbshare1
docker tag smbshare1 gcr.io/${DEVSHELL_PROJECT_ID}/smshare.v0.1
docker push gcr.io/${DEVSHELL_PROJECT_ID}/smshare.v0.1
sed -i 's/PROJECT_NAME/${DEVSHELL_PROJECT_ID}/g' nas.yaml
kubectl apply -f nas.yaml




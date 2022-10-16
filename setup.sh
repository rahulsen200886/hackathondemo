#!/bin/bash
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

gcloud container --project "${DEVSHELL_PROJECT_ID}" clusters create-auto "example" --region "us-central1" --release-channel "regular" --network "projects/${DEVSHELL_PROJECT_ID}/global/networks/default" --subnetwork "projects/${DEVSHELL_PROJECT_ID}/regions/us-central1/subnetworks/default" --cluster-ipv4-cidr "/17" --services-ipv4-cidr "/22"
gcloud beta container  --project "${DEVSHELL_PROJECT_ID}" clusters create-auto "example" --region "us-central1" --no-enable-basic-auth --cluster-version "1.22.12-gke.2300" --release-channel "regular" --machine-type "e2-medium" --image-type "COS_CONTAINERD" --disk-type "pd-standard" --disk-size "100" --metadata disable-legacy-endpoints=true --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --max-pods-per-node "110" --num-nodes "3" --logging=SYSTEM,WORKLOAD --monitoring=SYSTEM --enable-ip-alias  --no-enable-master-authorized-networks --addons HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver --enable-autoupgrade --enable-autorepair --max-surge-upgrade 1 --max-unavailable-upgrade 0 
gsutil mb gs://${DEVSHELL_PROJECT_ID}-nas-bucket
sed -i "s/NAS-BUK/${DEVSHELL_PROJECT_ID}-nas-bucket/g" gkeyml/nas.yaml
gcloud iam service-accounts create smbnfsshare-sa --display-name="My Custom Service Account"
gsutil iam ch serviceAccount:smbnfsshare-sa@${DEVSHELL_PROJECT_ID}.iam.gserviceaccount.com:objectAdmin gs://${DEVSHELL_PROJECT_ID}-nas-bucket
gcloud iam service-accounts keys create ./key.json --iam-account=smbnfsshare-sa@${DEVSHELL_PROJECT_ID}.iam.gserviceaccount.com
kubectl create secret generic sa-account  --from-file=./key.json
rm -f ./key.json
docker build . -t smbshare1
docker tag smbshare1 gcr.io/${DEVSHELL_PROJECT_ID}/smshare.v0.1
docker push gcr.io/${DEVSHELL_PROJECT_ID}/smshare.v0.1
sed -i "s/PROJECT_NAME/${DEVSHELL_PROJECT_ID}/g" gkeyml/nas.yaml
kubectl apply -f gkeyml/nas.yaml

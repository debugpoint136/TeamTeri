#!/bin/bash

echo "Importing configuration from cli.rc..."
source ./0_cli.rc

echo "authenticate to GCP from your working directory via Terminal"
echo "will not launch if ${ACCOUNT} already has credentials"
gcloud auth login ${ACCOUNT} --brief

echo "Creating firewall rule..."
gcloud compute firewall-rules create --project ${PROJECT} galaxy-allow-http \
    --allow tcp:80 \
    --target-tags ${CLIENT_TAG} \
    &

echo "Creating client image, please wait..."
gcloud compute images create --project ${PROJECT} ${TEAMTERI_IMAGE} \
    --description="Galaxy_client" \
    --source-uri="http://storage.googleapis.com/galaxyproject_images/planemo_machine_smc.06.image.tar.gz" \
    &

echo "Waiting for image to become available..."
wait

echo "Creating client instances, please wait..."
gcloud compute instances create ${GCLOUD_ARGS} ${VANILLA_INSTANCE} \
	--machine-type ${CLIENT_INSTANCE_TYPE} \
	--tags ${CLIENT_TAG} \
	--image ${TEAMTERI_IMAGE} \
	--image-project ${PROJECT} \
	--boot-disk-size ${BOOT_DISK_SIZE} \
	&

gcloud compute instances create ${GCLOUD_ARGS} ${TOOLS_INSTANCE} \
	--machine-type ${CLIENT_INSTANCE_TYPE} \
	--tags ${CLIENT_TAG} \
	--image ${TEAMTERI_IMAGE} \
	--image-project ${PROJECT} \
	--boot-disk-size ${BOOT_DISK_SIZE} \
	--metadata-from-file startup-script=./boot.sh \
    &

echo "Waiting for instances to become available..."
wait
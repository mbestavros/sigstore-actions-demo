#!/usr/bin/env bash

########################
# include the magic
########################
. ~/source/user-apps/demo-magic/demo-magic.sh

DEMO_PROMPT="${GREEN}➜ ${CYAN}\W "

clear

pe "tail -n 30 manifests/imagePolicy-email.yaml"

pe "kubectl apply -f manifests/imagePolicy-email.yaml --namespace next-demo"

pe "kubectl run nginx --image=nginx:latest"

pe "cosign sign ghcr.io/mbestavros/redhat-day-security-demo-unsigned:main"

p "# set log_id from cosign"

cmd

pe "rekor-cli get --log-index=$log_id --format=json | jq \".Body | .HashedRekordObj | .signature | .publicKey | .content\" | cut -d '\"' -f2 | base64 -d > cert-email.pem"

pe "openssl x509 -in cert-email.pem -text -noout"

pe "kubectl run good-image --image=ghcr.io/mbestavros/redhat-day-security-demo-unsigned:main"

pe "kubectl get pod good-image"

pe "kubectl delete pod good-image"

p "# Over to Github!"

p "# set log_id from GitHub Action"

cmd

pe "rekor-cli get --log-index=$log_id --format=json | jq \".Body | .HashedRekordObj | .signature | .publicKey | .content\" | cut -d '\"' -f2 | base64 -d > cert-action.pem"

pe "openssl x509 -in cert-action.pem -text -noout"

pe 'tail -n 28 manifests/imagePolicy-ephemeral.yaml'

pe "kubectl apply -f manifests/imagePolicy-ephemeral.yaml --namespace next-demo"

pe "kubectl run bad-image --image=ghcr.io/lukehinds/blackhat-next-security-demo:main"

pe "kubectl run good-image --image=ghcr.io/mbestavros/redhat-day-security-demo:main"

pe "kubectl get pod good-image"

pe "kubectl delete pod good-image"

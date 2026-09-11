#!/bin/bash -e
## Usage ./kubeconfig.sh ( namespace ) ( service account name ) ( secret name )

# Pull the bearer token and cluster CA from the service account secret.
BEARER_TOKEN=$( kubectl get secrets -n $1 $3 -o jsonpath='{.data.token}' | base64 -d )

CLUSTER_URL=$( kubectl config view -o jsonpath='{.clusters[0].cluster.server}' )


KUBECONFIG=kubeconfig-$1

kubectl config --kubeconfig=$KUBECONFIG \
    set-cluster \
    $CLUSTER_URL \
    --server=$CLUSTER_URL \
    --insecure-skip-tls-verify=true

kubectl config --kubeconfig=$KUBECONFIG \
    set-credentials $2 --token=$BEARER_TOKEN

kubectl config --kubeconfig=$KUBECONFIG \
    set-context $1 \
    --cluster=$CLUSTER_URL \
    --user=$2

kubectl config --kubeconfig=$KUBECONFIG \
    use-context $1
echo "kubeconfig written to file \"$KUBECONFIG\""
#!/bin/bash

# Check if a username is provided as argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <username>"
    exit 1
fi

# Extract username from the argument
user=$(echo "$1" | cut -d: -f1)

# Define context variables
kube_context="${SERVICE_ACCOUNT_NAME}-context"
kube_namespace="${SERVICE_ACCOUNT_NAME}-namespace"
kube_server="https://${KUBERNETES_SERVICE_HOST:-<KUBERNETES_SERVICE_HOST_NOT_SET>}"
kube_token="$(cat /etc/service-account-secret/token)"
kube_cert="/etc/service-account-secret/ca.crt"

# Check if KUBERNETES_SERVICE_HOST is set
if [ "$kube_server" = "https://<KUBERNETES_SERVICE_HOST_NOT_SET>" ]; then
    echo "Error: KUBERNETES_SERVICE_HOST environment variable is not set."
    exit 1
fi

# Determine the home directory of the user
USER_HOME=$(getent passwd $user | cut -d: -f6)

# Create the ~/.kube/config file
mkdir -p $USER_HOME/.kube
cat <<EOF > "$USER_HOME/.kube/config"
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: $(cat "$kube_cert" | base64 -w0)
    server: $kube_server
  name: $kube_context
contexts:
- context:
    cluster: $kube_context
    namespace: $kube_namespace
    user: $kube_context
  name: $kube_context
current-context: $kube_context
users:
- name: $kube_context
  user:
    token: $kube_token
EOF

echo "Generated $USER_HOME/.kube/config file successfully for user $SERVICE_ACCOUNT_NAME."

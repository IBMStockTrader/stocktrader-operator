#!/bin/bash

# Get public IP
PUB_IP=$(curl -s ifconfig.me)

# Get the first node's internal IP and calculate /16 subnet
FIRST_NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
IFS='.' read -r a b _ _ <<< "$FIRST_NODE_IP"
INTERNAL_SUBNET="${a}.${b}.0.0/16"

echo "Using:"
echo "  Public IP: $PUB_IP/32"
echo "  Internal subnet: $INTERNAL_SUBNET"

# Loop through all LoadBalancer services with an assigned EXTERNAL-IP
kubectl get svc -A -o json | jq -r '
  .items[] 
  | select(.spec.type=="LoadBalancer" and .status.loadBalancer.ingress != null) 
  | "\(.metadata.namespace) \(.metadata.name)"
' | while read -r ns svc; do
    echo "Patching service $svc in namespace $ns ..."
    kubectl patch svc "$svc" -n "$ns" --type='merge' -p "{
      \"spec\": {
        \"loadBalancerSourceRanges\": [
          \"$PUB_IP/32\",
          \"$INTERNAL_SUBNET\"
        ]
      }
    }"
done

echo "✅ All public LoadBalancer services have been updated."
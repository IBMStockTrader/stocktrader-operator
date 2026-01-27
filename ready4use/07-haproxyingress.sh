#!/bin/bash
helm repo add haproxytech https://haproxytech.github.io/helm-charts
helm repo update

helm upgrade --install haproxy-ingress haproxytech/kubernetes-ingress \
  --version 1.44.0 \
  --namespace haproxy-controller \
  --create-namespace \
  -f valueshaproxy.yaml
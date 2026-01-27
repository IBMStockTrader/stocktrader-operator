# Ingress Access

This directory contains the Ingress Access integration for IBM Stock Trader, mainly in trader and broker microservices. Stocktrader can look for a zero-trust ingress controller to route incoming requests. Stocktrader microservices have been tested with Haproxy Ingress Controller and kgateway API Gateway.


## Services Overview

| Service                | Tested Type.  | Default Type            | Exposed via Ingress  | Notes |
|------------------------|---------------|-------------------------|----------------------|-------|
| trader                 | LoadBalancer  | ClusterIP (if Ingress ) | Yes (`/trader`)      | Ingress handles routing; HAProxy strict HTTPS backend = 9443. |
| broker                 | LoadBalancer  | ClusterIP (if Ingress ) | Yes (`/broker`)      | Same pattern as trader; only exposed API endpoints. |
| portfolio              | NodePort      | ClusterIP               | No                   | Internal-only; remove NodePort. |
| stock-quote            | ClusterIP     | ClusterIP               | No                   | Internal backend service. |
| tradr                  | ClusterIP     | ClusterIP               | No                   | Optional service, usually disabled. |
| account                | ClusterIP     | ClusterIP               | No                   | Internal microservice. |
| cash-account           | ClusterIP     | ClusterIP               | No                   | Internal microservice. |
| trade-history          | ClusterIP     | ClusterIP               | No                   | Internal history processor. |
| messaging              | ClusterIP     | ClusterIP               | No                   | Internal messaging aggregator. |
| notification-service   | ClusterIP     | ClusterIP               | No                   | Internal eventing. |
| notification-slack     | ClusterIP     | ClusterIP               | No                   | Internal notifier. |
| notification-twitter   | ClusterIP     | ClusterIP               | No                   | Internal notifier. |
| looper                 | ClusterIP     | ClusterIP               | No                   | Internal background worker. |
| tradr                  | LoadBalancer  | Load Balancer           | No (`/tradr`)        | Ingress handles routing; HAProxy strict HTTPS backend = 9443. |

<Note that the tradr service is usually disabled; if neccesary, enable it via the `tradr.enabled` Helm value independently of the Ingress configuration.>

## Architecure
* Controllers ( Ingress or Gateway ) are out of the scope or prerequisites see "APPENDIX A"
* Stocktrader microservices are configured to work with Ingress controllers

![Architecural Ingress Diagram](/images/ingress.png)

## HelmChart section
```yaml
global:
  ingress:
    enabled: true
    className: ""
    fqdn: "st.cloudoptimization.kynhost.com"
    https:
      enabled: true
      tlsSecretName: stocktrader-tls
```

## APPENDIX A: Ingress Controller Prerequisites
### Haproxy Ingress Controller Installation
  - Follow the official documentation to install Haproxy Ingress Controller: https://www.haproxy.com/documentation/kubernetes/latest/user-guide/getting-started/
```bash
#!/bin/bash
helm repo add haproxytech https://haproxytech.github.io/helm-charts
helm repo update

helm upgrade --install haproxy-ingress haproxytech/kubernetes-ingress \
  --version 1.44.0 \
  --namespace haproxy-controller \
  --create-namespace \
  -f valueshaproxy.yaml
```
<Note Review Ingress Controller HealthCheck in azure cases to be controller Up and running .>

### kgateway API Gateway Installation
  - Follow the official documentation to install kgateway API Gateway https://kgateway.dev/blog/guide-to-installing-kgateway/ 
    - Install CRDS
    - Apply example Helm

```bash
    #Install CRDS
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.0/standard-install.yaml

#Install AGIC Helm Chart

helm upgrade -i agentgateway-crds oci://ghcr.io/kgateway-dev/charts/agentgateway-crds \
  --namespace agentgateway-system --create-namespace \
  --version v2.2.0-main \
  --set controller.image.pullPolicy=Always

helm upgrade -i agentgateway oci://ghcr.io/kgateway-dev/charts/agentgateway \
  --namespace agentgateway-system \
  --version v2.2.0-main \
  --set controller.image.pullPolicy=Always \
  --set controller.extraEnv.KGW_ENABLE_GATEWAY_API_EXPERIMENTAL_FEATURES=true
´´´

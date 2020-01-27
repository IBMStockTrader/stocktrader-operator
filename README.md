# IBM Stock Trader operator
This repository contains the results of using the Operator SDK to turn the umbrella helm chart (in the sibling `stocktrader-helm` repo) into a Kubernetes Operator.
The SDK was installed to my Mac via `brew install operator-sdk`.  I ran the following command to create the contents of this repo:
```
operator-sdk new stocktrader --type helm --helm-chart ../stocktrader-helm/stocktrader-0.1.6.tgz
```
Mostly I followed the instructions here: https://docs.openshift.com/container-platform/4.3/operators/operator_sdk/osdk-helm.html

The results of building this repo are in DockerHub at https://hub.docker.com/r/ibmstocktrader/stocktrader-operator

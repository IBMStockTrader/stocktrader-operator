# IBM Stock Trader operator
This operator is intended to install all of the microservices from the IBM Stock Trader sample, and configure them to talk to services they require.

Note it does NOT install such prereqs, like DB2 or MQ - it just asks you to tell it how to connect to such services you already have - whether they be running in the same Kube cluster, or out in a public cloud.

It is a follow-on to the helm chart I created earlier, and described at https://medium.com/cloud-engagement-hub/using-an-umbrella-helm-chart-to-deploy-the-composite-ibm-stock-trader-sample-3b8b69af900d.

![Architecural Diagram](stock-trader.png)

This repository contains the results of using the Operator SDK to turn the umbrella helm chart (in the sibling `stocktrader-helm` repo - which must be built first, via `helm package stocktrader` in that repo) into a Kubernetes Operator.
The SDK was installed to my Mac via `brew install operator-sdk`, which gave me v0.15.0.  I ran the following command to create the contents of this repo:
```
operator-sdk new stocktrader-operator --api-version=operators.ibm.com/v1 --kind StockTrader --type helm --helm-chart ../stocktrader-helm/stocktrader-0.1.9.tgz
```
Mostly I followed the instructions here: https://docs.openshift.com/container-platform/4.3/operators/operator_sdk/osdk-helm.html

The operator is built by going to the `stocktrader-operator` subdirectory and running the following command:
```
operator-sdk build stocktrader-operator
```
This produces a `stocktrader-operator:latest` Docker image, which I then pushed to DockerHub via the following usual commands (if building yourself, you'll need to push to somewhere that you have authority, and will need to update the `operator.yaml` to reference that location):
```
docker tag stocktrader-operator:latest ibmstocktrader/stocktrader-operator:latest
docker push ibmstocktrader/stocktrader-operator:latest
```
The results of building this repo are in DockerHub at https://hub.docker.com/r/ibmstocktrader/stocktrader-operator

Deploy the operator, and its CRD (which I hand-edited extensively, mostly in the `openAPIV3Schema` section), via the following, in the specified order (of course, if you want it to go to a namespace other than the one configured by `oc login`/`oc project`, add it via a `-n` parameter to the commands below):
```
oc create -f deploy/crds/operators.ibm.com_stocktraders_crd.yaml
oc create -f deploy/service_account.yaml
oc create -f deploy/role.yaml
oc create -f deploy/role_binding.yaml
oc create -f deploy/operator.yaml
```
You can do a standard `oc get pods` to see that the operator is running, ready to respond to new CustomResources (CRs) being installed of kind `StockTrader`.

An example CR yaml can be deployed via the following command:
```
oc create -f deploy/crds/operators.ibm.com_v1_stocktrader_cr.yaml
```
You can first edit this file to add any of the fields specified in the values.yaml, such as the `database.host`.
Or, just run the default, then edit the values in the config map and/or the secret, which is where most of the settings from the values.yaml end up.
For example, the `database.host` and `database.port` are placed in the config map (called `{name}-config`) that gets generated for you, and the `database.id` and `database.password` are in the generated secret (called `{name}-credentials`).
The various microservices in the IBM Stock Trader sample look in this config map and secret during pod startup for their configuration values.

You can generate the ClusterServiceVersion (CSV), that registers the operator so it shows up in the Operators catalog page in the OpenShift console, via the following command:
```
operator-sdk generate csv --csv-version 0.1.0
```
This will produce an `olm-catalog` subdirectory of the above mentioned `deploy` directory, containing relevant yaml.  The most important file is the `deploy/olm-catalog/stocktrader-operator/0.1.0/stocktrader-operator.v0.1.0.clusterserviceversion.yaml`, which is the actual CSV itself, containing the "hints" to the UI for how to display the form (which I hand-edited extensively).

I've not yet plugged into some operator registry, so I've just been manually running an `oc create -f` against that CSV file to get it to show up in the list of available operators for the cluster/namespace.
I don't think it makes sense for a sample like this to be in the main Red Hat OperatorHub; there's talk of an IBM-hosted operator registry in the works, so I might plug into that when it's ready.

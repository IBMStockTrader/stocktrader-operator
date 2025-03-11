A *bundle* is used in the process of making your operator known to your cluster's *OperatorHub*.  To build the bundle, run the following command from the directory above this one:
```
docker build -t stocktrader-operator-bundle:v1.0.0 -f bundle.Dockerfile .
```
Then tag and push the image to your desired image registry.  For example, I push mine to *DockerHub*, so after doing a `docker login`, I do the following:
```
docker tag stocktrader-operator-bundle:v1.0.0 ghcr.io/ibmstocktrader/stocktrader-operator-bundle:v1.0.0
docker push ghcr.io/ibmstocktrader/stocktrader-operator-bundle:v1.0.0
```
At that point, you have your bundle available.  Now it is ready to be used by the Operator Package Manager (`opm`) to produce a catalog image that can be loaded into your cluster's *OperatorHub*.
See the ../catalog/README.md for details on how to produce the catalog image

Once the catalog image is available in an image registry, you just add it to your cluster's *OperatorHub*, via the following steps:
1. Login to your OpenShift (4.5 or later) cluster as a cluster administrator
2. Navigate to *Administration->Cluster Settings* in the left nav, then click on the *Global Configuration* tab, and scroll down and click on *OperatorHub*.
3. Click on the *Sources* tab, and then click the **Create CatalogSource** button.
4. In the form that appears, you can enter whatever values you want in the *Catalog source name* field (I typed `cloud-journey-optimization-team`), the *Display name* field (I typed `Cloud Journey Optimization Team`), and the *Publisher name* field (I typed `Kyndryl`)
5. The field that really matters is the *Image* field, where you need to type the value from the `podman push` above of the image that `opm` produced, which was `docker.io/ibmstocktrader/stocktrader-operator-catalog:v1.0.0` in my case.
6. I chose the *Cluster-wide catalog source* radio button under *Availablility*, then clicked the **Create** button.
7. This will take you back to the list of catalog sources, with your new source listed.  At first it will have a dash in the *# of operators* cell of the table (the browser needs to be fairly wide to see this column), but after a few minutes it should switch to "1".
8. Navigate to *Operators->OperatorHub* in the left nav, then scroll down to find **IBM Stock Trader sample Operator** (you can type something like "stock" in the filter field to make only this operator show up, rather than having scroll down past hundreds of them).
9. Click on the tile for that operator, and click the **Install** button to install the *IBM Stock Trader* operator.  In the form that appears, you can leave the fields at their defaults and just click the **Install** button.
10. It will now appear in the *Installed Operators* page. 

See https://www.openshift.com/blog/openshift-4-3-managing-catalog-sources-in-the-openshift-web-console for further details and screenshots.  The base Helm-based operator tutorial is here: https://sdk.operatorframework.io/docs/building-operators/helm/tutorial/.  And there's a good helm-based operator sample for comparison to what's here, at https://github.com/operator-framework/operator-sdk/tree/master/testdata/helm/memcached-operator.  Note that the main operator was generated via `operator-sdk init --plugins helm --group operators --kind StockTrader --domain ibm.com --version v1 --helm-chart ../stocktrader-helm/stocktrader-2.0.0.tgz`.

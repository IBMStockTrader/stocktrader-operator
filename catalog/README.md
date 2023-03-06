Catalog image built following the guidance at 
https://olm.operatorframework.io/docs/tasks/creating-a-catalog/#catalog-creation-with-raw-file-based-catalogs

Specifically, the following commands were run (from the directory above this one):
```
make opm

mkdir catalog

./bin/opm generate dockerfile catalog

./bin/opm init stocktrader-operator -c stable -o yaml > catalog/operator.yaml

./bin/opm render docker.io/ibmstocktrader/stocktrader-operator-bundle:v1.0.0 -o yaml >> catalog/operator.yaml

cat << EOF >> catalog/operator.yaml
---
schema: olm.channel
package: stocktrader-operator
name: stable
entries:
  - name: stocktrader-operator-bundle.v1.0.0
EOF

./bin/opm validate catalog

docker build . -f catalog.Dockerfile -t stocktrader-operator-catalog:v1.0.0

docker tag stocktrader-operator-catalog:v1.0.0 ibmstocktrader/stocktrader-operator-catalog:v1.0.0

docker push ibmstocktrader/stocktrader-operator-catalog:v1.0.0
```

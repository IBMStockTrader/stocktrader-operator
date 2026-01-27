

1. Have a running OpenShift or Kubernetes cluster.

2. Install the Strimzi Kafka Operator in your cluster. You can follow the instructions [here](https://strimzi.io/docs/operators/latest/quickstart.html) to install the Strimzi Operator using the OperatorHub in OpenShift or by applying the Strimzi installation files directly in Kubernetes.

3. Create Kafka cluster by applying the following YAML file (save it as `kafka-cluster.yaml` and run `kubectl apply -f kafka-cluster.yaml`):
```yaml
apiVersion: kafka.strimzi.io/v1beta2
kind: Kafka
metadata:
  name: stocktrader-kafka
  namespace: kafka
spec:
  kafka:
    replicas: 1
    listeners:
      - name: plain
        port: 9092
        type: internal
        tls: false
    storage:
      type: ephemeral
  zookeeper:
    replicas: 1
    storage:
      type: ephemeral
  entityOperator:
    topicOperator: {}
    userOperator: {}
```
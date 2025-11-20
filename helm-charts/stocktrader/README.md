# IBM Stock Trader Helm Chart

## Introduction

This helm chart installs and configures the IBM Stock Trader microservices.
Nowadays, generally the operator in the sibling `stocktrader-operator` repo
is used instead; that operator wraps this helm chart.

## Prerequisites

The user must install and configure (or point to existing installations of) the following dependencies:
* A relational (JDBC-compliant) database, such as IBM DB2 or PostgreSQL

### OpenTelemetry (Optional)

For detailed OpenTelemetry setup and configuration, see [opentelemetry-README.md](opentelemetry-README.md).

The following dependencies are optional:
* An MQ product, such as IBM MQ Series, or Apache ActiveMQ (enables notifications)
* IBM Operational Decision Manager (enables loyalty level determination - can use a serverless function instead)
* A CouchDB database, such as IBM Cloudant (enables account metadata)
* A Kafka service, such as IBM Event Streams (enables Trade History and its return-on-investment calculation)
* Mongo DB (enables Trade History and its return-on-investment calculation)
* Redis (enables stock quote caching)

The [stocktrader-helm project](../README.md) provides instructions for setting up these dependencies.

## Configuration

The following table lists the configurable parameters of this chart and their default values.
The parameters allow you to:
* change the image of any microservice from the one provided by IBM to one that you build (e.g. if you want to try to modify a service)
* enable the deployment of optional microservices (tradr, account, messaging, notification-slack, notification-twitter, trade-history, collector)
* configure OpenTelemetry observability with various backend exporters - see [opentelemetry-README.md](opentelemetry-README.md) for details

### Microservice Image Configuration

| Parameter                           | Description                                         | Default                                                                         |
| ----------------------------------- | ----------------------------------------------------| --------------------------------------------------------------------------------|
| | | |
| broker.image.repository | image repository |  ghcr.io/ibmstocktrader/broker
| broker.image.tag | image tag | latest
| | | |
| portfolio.image.repository | image repository |  ghcr.io/ibmstocktrader/portfolio
| portfolio.image.tag | image tag | latest
| | | |
| stockQuote.image.repository | image repository | ghcr.io/ibmstocktrader/stock-quote
| stockQuote.image.tag | image tag | latest
| | | |
| brokerCQRS.enabled | Deploy broker-CQRS microservice | false
| brokerCQRS.image.repository | image repository |  ghcr.io/ibmstocktrader/broker-cqrs
| brokerCQRS.image.tag | image tag | latest
| | | |
| account.enabled | Deploy account microservice | false
| account.image.repository | image repository | ghcr.io/ibmstocktrader/account
| account.image.tag | image tag | latest
| | | |
| trader.enabled | Deploy trader microservice | true
| trader.image.repository | image repository | ghcr.io/ibmstocktrader/trader
| trader.image.tag | image tag | basicregistry
| | | |
| tradr.enabled | Deploy tradr microservice | false
| tradr.image.repository | image repository | ghcr.io/ibmstocktrader/tradr
| tradr.image.tag | image tag | latest
| | | |
| messaging.enabled | Deploy messaging microservice | false
| messaging.image.repository | image repository | ghcr.io/ibmstocktrader/messaging
| messaging.image.tag | image tag | latest
| | | |
| notificationSlack.enabled | Deploy notification-slack microservice | false
| notificationSlack.image.repository | image repository | ghcr.io/ibmstocktrader/notification-slack
| notificationSlack.image.tag | image tag | latest
| | | |
| notificationTwitter.enabled | Deploy notification-twitter microservice | false
| notificationTwitter.image.repository | image repository | ghcr.io/ibmstocktrader/notification-twitter
| notificationTwitter.image.tag | image tag | latest
| | | |
| looper.enabled | Deploy looper microservice | false
| looper.image.repository | image repository | ghcr.io/ibmstocktrader/looper
| looper.image.tag | image tag | latest
| | | |
| cashAccount.enabled | Deploy cash account microservice | false
| cashAccount.image.repository | image repository | ghcr.io/ibmstocktrader/collector
| cashAccount.image.tag | image tag | latest

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart.

## Building and Deploying the Chart

After cloning this repository and changing directory into it, just run `helm package stocktrader` to produce the stocktrader-2.0.0.tgz file.

It is also handy to change directory into the `stocktrader` directory (where the Chart.yaml is) and run `helm lint` to validate the helm chart.

## Installing the Chart

### Basic Installation

You can install the chart by setting the current directory to the folder where this chart is located and running the following command:

```console
helm install cjot stocktrader-2.0.0.tgz -n stocktrader . 
```

This sets the Helm release name to `cjot` and creates all Kubernetes resources in a namespace called `stocktrader`.

**Important Notes:**
* Make sure that the namespace has an image policy allowing it to pull images from the GitHub Container Registry (unless you have built the sample yourself and are pulling it from your local Docker image registry)

### Installation with OpenTelemetry

For OpenTelemetry installation instructions, see [opentelemetry-README.md](opentelemetry-README.md).


## Uninstalling the Chart

```console
$ helm delete --purge stocktrader --tls
```

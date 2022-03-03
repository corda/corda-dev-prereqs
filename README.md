# Corda Pre-requisites Helm chart

The contents of this repository can be used to install the Kafka and PostgreSQL pre-requisites for Corda 5.
The auto-generated [charts/corda-prereqs/README.md](README.md) contains details of the configurable values.

## Installation from Artifactory

The chart is packaged and published as an OCI bundle to an Artifactory Docker registry. This can be installed as follows:

```shell
helm registry login corda-os-docker.software.r3.com -u $CORDA_ARTIFACTORY_USERNAME -p $CORDA_ARTIFACTORY_PASSWORD 
helm upgrade --install prereqs oci://corda-os-docker.software.r3.com/helm-charts/corda-prereqs --render-subchart-notes 
```

## Installation from source

Assuming [helm](https://helm.sh/) with a version greater than 3.7 is installed, the chart may be used a follows.

### Download dependencies

Dependencies are included in [charts/corda-prereqs/Chart.yaml](Chart.yaml) and [charts/corda-prereqs/Chart.lock](Chart.lock).

NOTE: Before proceeding ensure that all unique repositories declared in [charts/corda-prereqs/Chart.yaml](Chart.yaml) 
have been added via `helm repo add`
ie.
```shell
# TODO: Could automate this further with xargs + helm repo add... ie. helm repo add bitnami charts.bitnami...
helm dep ls charts/corda-prereqs | awk 'NR>1 && NF > 1' | cut -f 3 | sort -u
```

To download these to the required directory, issue the following command:

```shell
helm dep build charts/corda-prereqs
```

### Install helm chart

To install the helm chart with the default values run the following command:
```shell
helm upgrade -i "<RELEASE NAME>" charts/corda-prereqs --namespace "<RELEASE NAMESPACE>" --create-namespace --wait
```

Optionally use the `--render-subchart-notes` for a brief overview of all connection details.

#### Optionally execute test hook

After the release has been installed, it may be tested via the following command:

```shell
helm test "<RELEASE NAME>" -n "<RELEASE NAMESPACE>"
```

#### Optionally externalise services

As an alternative to port-forwarding services, a non-default [values-external.yaml](values-external.yaml)
has been crafted - intended to decorate the existing [values.yaml](values.yaml) to expose Kafka brokers
and Postgresql via NodePort services.

It may be used by appending the following options, to the `helm upgrade` command:

```shell
-f values-external.yaml
```

This will create a NodePort type service for each Kafka Broker and Database.

These services are available on the following ports:

- Kafka-0 -> 30000
- Kafka-1 -> 30001
- Kafka-2 -> 30002


- Postgres -> 30100

### Maintaining

As new value fields are added to the default [charts/corda-prereqs/values.yaml](values.yaml) - doc strings should be included.

For objects prefer this style:
```yaml
# Doc string on an object, which won't show in README.md
foo: {}
```

Whereas for primitive types prefer this style:
```yaml
# -- Doc string for a primitive, which will show in the README.md
foo: "bar"
```

Then using [helm-docs](https://github.com/norwoodj/helm-docs)

Generate the README.md via:

```shell
$ helm-docs
INFO[2022-02-22T18:13:16Z] Found Chart directories [charts/corda-prereqs]
INFO[2022-02-22T18:13:16Z] Generating README Documentation for chart /mnt/c/src/poc-corda-prereqs-helm/charts/corda-prereqs
```

NOTE:
We should explore other tools, such as bitnami's [readme-generator](https://github.com/bitnami-labs/readme-generator-for-helm) as well as integrate into either
a CI pipeline (ie. github actions) or precommit hooks.

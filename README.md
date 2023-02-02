# Corda 5 Development Pre-requisites Helm chart

The contents of this repository can be used to install the Kafka and PostgreSQL pre-requisites for Corda 5 development.
The auto-generated [charts/corda-dev/README.md](README.md) contains details of the configurable values.

## Installation from source

Assuming [helm](https://helm.sh/) with a version greater than 3.7 is installed, the chart may be used a follows.

### Install helm chart

To install the helm chart with the default values run the following command:
```shell
helm upgrade -i "<RELEASE NAME>" charts/corda-dev --namespace "<RELEASE NAMESPACE>" --create-namespace --wait
```

On completion, the chart outputs the overrides that should then be used with your Corda Helm install.

#### Optionally execute test hook

After the release has been installed, it may be tested via the following command:

```shell
helm test "<RELEASE NAME>" -n "<RELEASE NAMESPACE>"
```

### Maintaining

As new value fields are added to the default [charts/corda-dev/values.yaml](values.yaml), doc strings should be included.

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
INFO[2022-02-22T18:13:16Z] Found Chart directories [charts/corda-dev]
INFO[2022-02-22T18:13:16Z] Generating README Documentation for chart /mnt/c/src/corda-dev-helm/charts/corda-dev
```

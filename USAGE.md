# Overview

This document intends to overview how to the helm chart in this repository.

It corresponds with [README.md](README.md) which is auto-generated from docstrings, detailing configurable values.

# Installation

Assuming [helm](https://helm.sh/) with a version greater than 3.7 is installed, the chart may be used a follows.

### Download dependencies

Dependencies are included in [Chart.yaml](Chart.yaml) and [Chart.lock](Chart.lock).

NOTE: Before proceeding ensure that all unique repositories declared in [Chart.yaml](Chart.yaml) 
have been added via `helm repo add`
ie.
```shell
# TODO: Could automate this further with xargs + helm repo add... ie. helm repo add bitnami charts.bitnami...
helm dep ls . | awk 'NR>1 && NF > 1' | cut -f 3 | sort -u
```

To download these to the required directory, issue the following command:

```shell
helm dep build .
```

### Install helm chart

To install the helm chart with the default values run the following command:
```shell
helm upgrade -i "<RELEASE NAME>" . --namespace "<RELEASE NAMESPACE>" --create-namespace --wait
```

Optionally use the `--render-subchart-notes` for a brief overview of all connection details.

#### Optionally execute test hook

After the release has been installed, it may be tested via the following command:

```shell
helm test "<RELEASE NAME>" -n "<RELEASE NAMESPACE>"
```

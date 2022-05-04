# Helm Chart for Corda 5 Development Pre-requisites

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 5.0.0](https://img.shields.io/badge/AppVersion-5.0.0-informational?style=flat-square)

A Helm chart for installing Corda 5 development pre-requisites.

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | kafka | 15.1.0 |
| https://charts.bitnami.com/bitnami | postgresql | 11.0.2 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| kafka.allowPlaintextListener | bool | `true` | enable plaintext as a listener protocol. |
| kafka.auth.clientProtocol | string | `"plaintext"` | protocol of the client listener. |
| kafka.auth.interBrokerProtocol | string | `"tls"` | protocol of the interbroker listener used for replication. |
| kafka.auth.tls.autoGenerated | bool | `true` | autogenerate a CA, and signed certificates for each broker. |
| kafka.auth.tls.type | string | `"pem"` | type of the tls certificates. |
| kafka.enabled | bool | `true` | enable/disable kafka. |
| kafka.replicaCount | int | `3` | set a static replica count of kafka brokers. |
| kafka.zookeeper.replicaCount | int | `3` | set a static replica count of zookeeper nodes. |
| postgresql.auth.database | string | `"cordacluster"` | name of database to be created. |
| postgresql.auth.password | string | `"pass"` | name of the password of the user to be created. |
| postgresql.auth.username | string | `"user"` | name of the user to be created. |
| postgresql.enabled | bool | `true` | enable/disable postgres. |
| postgresql.primary.initdb.scripts | object | corda_user_init.sh | ConfigMap-like object containing scripts to be executed on startup. |
| postgresql.volumePermissions.enabled | bool | `true` | enable/disable an init container which changes ownership of the mounted volumes. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.7.0](https://github.com/norwoodj/helm-docs/releases/v1.7.0)
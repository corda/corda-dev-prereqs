# POC: Corda 5 Prereqs Helm Chart

Contains a Helm chart for the deployment of PostgreSQL and Kafka, secured with TLS.

Install with:
```
helm upgrade --install --render-subchart-notes prereqs .
```
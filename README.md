# POC: Corda 5 Prereqs Helm Chart

Contains a Helm chart for the deployment of PostgreSQL and Kafka, secured with TLS.

Install with:
```
helm upgrade --install --render-subchart-notes --wait prereqs .
```

After installation, you can verify that a successful TLS connection can be made to PostgreSQL and Kafka with:
```
helm test prereqs
```

When you're finished with the release, clean up by running:
```
helm uninstall prereqs
kubectl delete pvc --all
```
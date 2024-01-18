#!/bin/bash
set -E
NAMESPACE=test-corda-dev
CHART_VERSION=0.2.0-test-corda-dev
PATH_TO_CORDA=../corda-runtime-os

kubectl delete ns $NAMESPACE || echo note: corda was not installed before to this cluster in the corda namespace

kubectl create ns $NAMESPACE

kubectl create secret -n $NAMESPACE docker-registry docker-registry-cred \
  --docker-server "*.software.r3.com" \
  --docker-username $CORDA_ARTIFACTORY_USERNAME \
  --docker-password $CORDA_ARTIFACTORY_PASSWORD

echo -e '\n###########################################\nFetching dependencies for corda-dev Helm chart\n###########################################\n'
helm dependency build charts/corda-dev

echo -e '\n###########################################\nLinting corda-dev Helm chart\n###########################################\n'
helm lint charts/corda-dev

echo -e '\n###########################################\nPackaging corda-dev Helm chart\n###########################################\n'
helm package charts/corda-dev --version $CHART_VERSION

echo -e '\n###########################################\nInstalling corda-dev Helm chart\n###########################################\n'
helm install prereqs corda-dev-$CHART_VERSION.tgz -n $NAMESPACE --wait

echo -e '\n###########################################\nTesting corda-dev Helm chart\n###########################################\n'
helm test prereqs -n $NAMESPACE

echo -e '\n###########################################\nCreating Kafka secrets\n###########################################\n'
KAFKA_PASSWORDS=$(kubectl get secret prereqs-kafka-user-passwords -n "${NAMESPACE}" -o go-template="{{ index .data \"client-passwords\" | base64decode }}")

IFS=',' read -r -a KAFKA_PASSWORDS_ARRAY <<< "$KAFKA_PASSWORDS"
            kubectl create secret generic kafka-credentials -n "${NAMESPACE}" \
                --from-literal=bootstrap="${KAFKA_PASSWORDS_ARRAY[0]}" \
                --from-literal=crypto="${KAFKA_PASSWORDS_ARRAY[1]}" \
                --from-literal=db="${KAFKA_PASSWORDS_ARRAY[2]}" \
                --from-literal=flow="${KAFKA_PASSWORDS_ARRAY[3]}" \
                --from-literal=flowMapper="${KAFKA_PASSWORDS_ARRAY[4]}" \
                --from-literal=verification="${KAFKA_PASSWORDS_ARRAY[5]}" \
                --from-literal=membership="${KAFKA_PASSWORDS_ARRAY[6]}" \
                --from-literal=p2pGateway="${KAFKA_PASSWORDS_ARRAY[7]}" \
                --from-literal=p2pLinkManager="${KAFKA_PASSWORDS_ARRAY[8]}" \
                --from-literal=persistence="${KAFKA_PASSWORDS_ARRAY[9]}" \
                --from-literal=tokenSelection="${KAFKA_PASSWORDS_ARRAY[10]}" \
                --from-literal=rest="${KAFKA_PASSWORDS_ARRAY[11]}" \
                --from-literal=uniqueness="${KAFKA_PASSWORDS_ARRAY[12]}"

echo -e '\n###########################################\nInstalling Corda\n###########################################\n'

helm upgrade --install corda -n $NAMESPACE \
    oci://corda-os-docker.software.r3.com/helm-charts/release/os/5.2/corda \
    --version "^5.2.0-beta" \
    -f $PATH_TO_CORDA/values-prereqs.yaml \
    --set 'bootstrap.db.cluster.password.valueFrom.secretKeyRef.name=prereqs-postgresql' \
    --set 'db.cluster.host=prereqs-postgresql' \
    --set 'db.cluster.password.valueFrom.secretKeyRef.name=prereqs-postgresql' \
    --set 'db.cluster.password.valueFrom.secretKeyRef.key=password' \
    --set 'kafka.sasl.mechanism=SCRAM-SHA-256' \
    --set 'kafka.sasl.username.value=bootstrap' \
    --set 'kafka.sasl.password.valueFrom.secretKeyRef.name=kafka-credentials' \
    --set 'kafka.sasl.password.valueFrom.secretKeyRef.key=bootstrap' \
    --set 'kafka.tls.truststore.valueFrom.secretKeyRef.name=prereqs-kafka-tls' \
    --set 'kafka.tls.truststore.valueFrom.secretKeyRef.key=kafka-ca.crt' \
    --set-json 'imagePullSecrets=["docker-registry-cred"]' \
    --timeout 10m \
    --wait
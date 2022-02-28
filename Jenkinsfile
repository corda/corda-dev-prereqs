def chartVersion() {
    def chartVersion = sh(script:'helm show chart charts/corda-prereqs | sed -n \'s/^version: \\(.*\\)$/\\1/p\'', returnStdout: true).trim()
    if (env.BRANCH_NAME == 'main') {
        return $chartVersion
    } else {
        return "$chartVersion-${env.BRANCH_NAME}"
    }
}

pipeline {
    agent {
        docker {
            image 'build-zulu-openjdk:11'
            label 'docker'
            registryUrl 'https://engineering-docker.software.r3.com/'
            registryCredentialsId 'artifactory-credentials'
            // Used to mount storage from the host as a volume to persist the cache between builds
            args '-v /tmp/helm/repository:/host_tmp/helm-cache'
            // make sure build image is always fresh
            alwaysPull true
        }
    }

    environment {
        KUBECONFIG = credentials("e2e-tests-credentials")
        CORDA_REVISION = "${env.GIT_COMMIT}"
        CHART_VERSION = chartVersion()
        NAMESPACE = "run-${UUID.randomUUID().toString()}"
        CLUSTER_NAME = "eks-e2e.e2e.awsdev.r3.com"
        HELM_REPOSITORY_CONFIG = "/tmp/helm/repositories.yaml"
        HELM_REPOSITORY_CACHE = "/tmp/helm/repository"
        HELM_REGISTRY_CONFIG = "/tmp/helm/registry/config.json"
    }

    options {
        buildDiscarder(logRotator(daysToKeepStr: '14', artifactDaysToKeepStr: '14'))
        timeout(time: 30, unit: 'MINUTES')
        timestamps()
    }

    stages {
        stage('Add repositories') {
            steps {
                sh '''
                    helm repo add bitnami https://charts.bitnami.com/bitnami
                '''
            }
        }
        stage('Build dependencies') {
            steps {
                sh '''
                    helm dependency build charts/corda-prereqs
                '''
            }
        }
        stage('Lint') {
            steps {
                sh '''
                    helm lint charts/corda-prereqs
                '''
            }
        }
        stage('Package') {
            steps {
                sh '''
                    helm package charts/corda-prereqs --version $CHART_VERSION
                '''
            }
        }
        stage('Test') {
            steps {
                sh '''
                    helm install prereqs corda-prereqs-$CHART_VERSION.tgz -n $NAMESPACE --create-namespace --wait
                    helm test prereqs
                    kubectl delete namespace $NAMESPACE
                '''
            }
        }
        stage('Publish') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'artifactory-credentials', passwordVariable: 'PASSWORD', usernameVariable: 'USER')]) {
                    sh '''
                        echo $PASSWORD | helm registry login corda-os-docker-dev.software.r3.com -u $USER --password-stdin
                        helm push corda-prereqs-$CHART_VERSION.tgz oci://corda-os-docker-dev.software.r3.com/helm-charts
                    '''
                }
            }
        }
    }
}
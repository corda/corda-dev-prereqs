def chartVersion() {
    def chartVersion = sh(script:'helm show chart charts/corda-dev-prereqs | sed -n \'s/^version: \\(.*\\)$/\\1/p\'', returnStdout: true).trim()
    if (env.BRANCH_NAME == 'main') {
        return "$chartVersion"
    } else {
        return "$chartVersion-${env.BRANCH_NAME}".replaceAll("[/]", "_")
    }
}

def publishHelmChart(String credentialsName) {
    withCredentials([usernamePassword(credentialsId: credentialsName, passwordVariable: 'HELM_REGISTRY_PASSWORD', usernameVariable: 'HELM_REGISTRY_USERNAME')]) {
        sh '''
            echo $HELM_REGISTRY_PASSWORD | helm registry login $HELM_REGISTRY -u $HELM_REGISTRY_USERNAME --password-stdin
            helm push corda-dev-prereqs-$CHART_VERSION.tgz oci://$HELM_REGISTRY/$HELM_REPOSITORY
        '''
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
            args '-v /tmp:/host_tmp'
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
        HELM_REPOSITORY_CACHE = "/host_tmp/helm/repository"
        HELM_REGISTRY_CONFIG = "/tmp/helm/registry/config.json"
    }

    options {
        buildDiscarder(logRotator(daysToKeepStr: '14', artifactDaysToKeepStr: '14'))
        timeout(time: 30, unit: 'MINUTES')
        timestamps()
    }

    stages {
        stage('Lint') {
            steps {
                sh '''
                    helm lint charts/corda-dev-prereqs
                '''
            }
        }
        stage('Package') {
            steps {
                sh '''
                    helm package charts/corda-dev-prereqs --version $CHART_VERSION
                '''
            }
        }
        stage('Test') {
            steps {
                sh '''
                    helm install prereqs corda-dev-prereqs-$CHART_VERSION.tgz -n $NAMESPACE --create-namespace --wait
                    helm test prereqs -n $NAMESPACE
                '''
            }
            post {
                failure {
                    sh '''
                        kubectl describe pod -n $NAMESPACE > describe.txt
                        kubectl logs -n $NAMESPACE -l app.kubernetes.io/instance=prereqs --prefix=true > logs.txt
                    '''
                    archiveArtifacts artifacts: "*.txt", allowEmptyArchive: true, fingerprint: true
                }
                cleanup {
                    sh '''
                        kubectl delete namespace $NAMESPACE
                    '''
                }
            }
        }
        stage('Publish to Artifactory') {
            environment {
                HELM_REGISTRY="corda-os-docker-${env.BRANCH_NAME == 'main' ? 'stable' : 'dev'}.software.r3.com"
                HELM_REPOSITORY='helm-charts'
            }
            steps {
                publishHelmChart('artifactory-credentials')
            }
        }
        stage('Publish to Docker Hub') {
            when {
                branch 'main'
            }
            environment {
                HELM_REGISTRY='registry-1.docker.io'
                HELM_REPOSITORY='corda'
            }
            steps {
                publishHelmChart('docker-hub-cordapusher')
            }
        }
    }
}
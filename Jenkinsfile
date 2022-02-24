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
        ARTIFACTORY_CREDENTIALS = credentials('artifactory-credentials')
        CORDA_ARTIFACTORY_USERNAME = "${env.ARTIFACTORY_CREDENTIALS_USR}"
        CORDA_ARTIFACTORY_PASSWORD = "${env.ARTIFACTORY_CREDENTIALS_PSW}"
        CORDA_USE_CACHE = "corda-remotes"
        KUBECONFIG = credentials("e2e-tests-credentials")
        CORDA_REVISION = "${env.GIT_COMMIT}"
        NAMESPACE = "run-${UUID.randomUUID().toString()}"
        CLUSTER_NAME = "eks-e2e.e2e.awsdev.r3.com"
    }

    options {
        buildDiscarder(logRotator(daysToKeepStr: '14', artifactDaysToKeepStr: '14'))
        timeout(time: 30, unit: 'MINUTES')
        timestamps()
    }

    stages {
        stage('Prepare') {
            steps {
                sh """
                    helm repo add bitnami https://charts.bitnami.com/bitnami
                    helm dependency build charts/corda-prereqs
                """
            }
        }
        stage('Lint') {
            steps {
                sh """
                    helm lint charts/corda-prereqs
                """
            }
        }
    }
}
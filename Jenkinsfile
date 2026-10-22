pipeline {
    agent any

    parameters {
        string(name: 'DOCKER_IMAGE_TAG', defaultValue: 'v1.0', description: 'Tag for the Docker image')
        booleanParam(name: 'DEPLOY_TO_K8S', defaultValue: true, description: 'Deploy to Kubernetes cluster')
    }

    environment {
        DOCKER_HUB_REPO = 'DOCKER_HUB_USERNAME/industrial-monitoring'
        DOCKER_CRED_ID  = 'docker-hub-credentials'
        KUBECONFIG_CRED = 'k8s-kubeconfig'
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code from Git repository...'
                checkout scm
            }
        }

        stage('Parallel Build & Validation') {
            parallel {
                stage('Validate Source Files') {
                    steps {
                        echo 'Checking required application files...'
                        sh 'test -f index.html'
                        sh 'test -f Dockerfile'
                        sh 'test -f deployment.yaml'
                    }
                }
                stage('Build Docker Image') {
                    steps {
                        echo "Building Docker image ${DOCKER_HUB_REPO}:${params.DOCKER_IMAGE_TAG}"
                        sh "docker build -t ${DOCKER_HUB_REPO}:${params.DOCKER_IMAGE_TAG} ."
                    }
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', "${DOCKER_CRED_ID}") {
                        sh "docker push ${DOCKER_HUB_REPO}:${params.DOCKER_IMAGE_TAG}"
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            when {
                expression { return params.DEPLOY_TO_K8S == true }
            }
            steps {
                script {
                    configFileProvider([configFile(fileId: "${KUBECONFIG_CRED}", variable: 'KUBECONFIG')]) {
                        sh """
                            sed -i 's|DOCKER_HUB_USERNAME/industrial-monitoring:v1.0|${DOCKER_HUB_REPO}:${params.DOCKER_IMAGE_TAG}|g' deployment.yaml
                            kubectl apply -f deployment.yaml --kubeconfig=\$KUBECONFIG
                            kubectl rollout status deployment/industrial-monitoring-deployment --kubeconfig=\$KUBECONFIG
                        """
                    }
                }
            }
        }

        stage('Archive Artifacts') {
            steps {
                echo 'Archiving Kubernetes Deployment & Configuration Manifests...'
                archiveArtifacts artifacts: '*.yaml, Dockerfile', allowEmptyArchive: false
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
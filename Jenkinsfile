pipeline {
    agent any

    parameters {
        string(name: 'DOCKER_IMAGE_TAG', defaultValue: 'v1.0', description: 'Tag for the Docker image')
        booleanParam(name: 'DEPLOY_TO_K8S', defaultValue: true, description: 'Deploy to Kubernetes cluster')
    }

    stages {
        stage('Parallel Validation & Build') {
            parallel {
                stage('Validate Workspace') {
                    steps {
                        echo 'Checking required application files...'
                        bat 'if not exist index.html exit /b 1'
                        bat 'if not exist Dockerfile exit /b 1'
                    }
                }
                stage('Simulate Build Stage') {
                    steps {
                        echo "Building image version: ${params.DOCKER_IMAGE_TAG}"
                        bat 'docker build -t industrial-monitoring:%DOCKER_IMAGE_TAG% .'
                    }
                }
            }
        }

        stage('Conditional Deployment') {
            when {
                expression { return params.DEPLOY_TO_K8S == true }
            }
            steps {
                echo "Deploying version ${params.DOCKER_IMAGE_TAG} to cluster..."
            }
        }

        stage('Archive Artifacts') {
            steps {
                echo 'Archiving project artifacts...'
                archiveArtifacts artifacts: 'index.html, Dockerfile, deployment.yaml', allowEmptyArchive: false
            }
        }
    }
}

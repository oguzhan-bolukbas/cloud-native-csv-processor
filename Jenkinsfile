pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_REGION = credentials('AWS_REGION')
        S3_BUCKET_NAME = credentials('S3_BUCKET_NAME')
        DOCKER_IMAGE_NAME = credentials('DOCKER_IMAGE_NAME')
        DOCKER_IMAGE_TAG = credentials('DOCKER_IMAGE_TAG')
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Install & Test') {
            steps {
                sh 'npm install'
                sh 'npm test'
            }
        }
        stage('Setup Docker Buildx') {
            steps {
                sh '''
                    # Check if buildx is available
                    if ! docker buildx version >/dev/null 2>&1; then
                        echo "Installing Docker Buildx..."
                        mkdir -p ~/.docker/cli-plugins/
                        curl -SL https://github.com/docker/buildx/releases/download/v0.12.1/buildx-v0.12.1.linux-amd64 -o ~/.docker/cli-plugins/docker-buildx
                        chmod a+x ~/.docker/cli-plugins/docker-buildx
                        docker buildx version
                    fi
                    
                    # Create and use buildx builder
                    docker buildx create --name multiarch-builder --use || docker buildx use multiarch-builder
                    docker buildx inspect --bootstrap
                '''
            }
        }
        stage('Build Multi-Platform Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_PASSWORD')]) {
                    sh 'echo $DOCKERHUB_PASSWORD | docker login -u $DOCKERHUB_USERNAME --password-stdin'
                    sh """
                        docker buildx build \\
                            --platform linux/amd64,linux/arm64 \\
                            --tag $DOCKER_IMAGE_NAME:$BUILD_NUMBER \\
                            --tag $DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG \\
                            --push \\
                            .
                    """
                }
            }
        }
        stage('Deploy to Local Kubernetes') {
            steps {
                script {
                    // Deploy to local Kubernetes (Minikube)
                    sh '''
                        # Make sure kubectl is pointing to local cluster
                        kubectl config current-context
                        
                        # Deploy using Helm to local cluster
                        helm upgrade --install csv-processor ./helm/csv-processor \\
                            --values ./helm/csv-processor/values-override.yaml \\
                            --set image.tag=$BUILD_NUMBER \\
                            --wait
                    '''
                }
            }
        }
    }
    post {
        always {
            sh 'docker logout'
        }
    }
}

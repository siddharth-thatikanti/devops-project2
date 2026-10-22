
pipeline {
    agent any

    environment {
        DOCKERHUB_USER = 'sidduthatikanti93'
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                dir('frontend') {
                    sh 'npm install'
                }
                dir('backend') {
                    sh 'npm install'
                }
            }
        }

        stage('Test') {
            steps {
                dir('frontend') {
                    sh 'npm test -- --watchAll=false'
                }
                dir('backend') {
                    sh 'npm test'
                }
            }
        }

        stage('Build Docker Images') {
            steps {
                sh '''
                    docker build -t $DOCKERHUB_USER/mern-frontend:$IMAGE_TAG ./frontend
                    docker build -t $DOCKERHUB_USER/mern-backend:$IMAGE_TAG ./backend
                '''
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_TOKEN'
                    )
                ]) {
                    sh '''
                        set +x
                        echo "$DOCKER_TOKEN" | docker login \
                          -u "$DOCKER_USER" --password-stdin

                        docker push $DOCKERHUB_USER/mern-frontend:$IMAGE_TAG
                        docker push $DOCKERHUB_USER/mern-backend:$IMAGE_TAG

                        docker logout
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'CI successful! Images pushed to Docker Hub.'
        }
        failure {
            echo 'CI failed. Check Console Output.'
        }
        always {
            sh 'docker logout || true'
        }
    }
}


pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        skipDefaultCheckout(true)
    }

    environment {
        DOCKERHUB_USER = 'sidduthatikanti93'
        FRONTEND_IMAGE = "${DOCKERHUB_USER}/mern-frontend"
        BACKEND_IMAGE  = "${DOCKERHUB_USER}/mern-backend"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm

                script {
                    env.IMAGE_TAG = sh(
                        script: 'git rev-parse --short=12 HEAD',
                        returnStdout: true
                    ).trim()

                    echo "Building commit: ${env.IMAGE_TAG}"
                }
            }
        }

        stage('Validate Project') {
            steps {
                sh '''
                    set -eu

                    test -f frontend/package.json
                    test -f frontend/Dockerfile
                    test -f backend/package.json
                    test -f backend/Dockerfile

                    docker --version
                    trivy --version
                '''
            }
        }

        stage('Install Dependencies and Test') {
            steps {
                sh '''
                    set -eu

                    # npm ci requires a committed package-lock.json.
                    # Do not silently replace a missing lockfile.
                    for dir in frontend backend; do
                        if [ ! -f "$dir/package-lock.json" ]; then
                            echo "Missing $dir/package-lock.json"
                            echo "Generate and commit the lockfile first."
                            exit 1
                        fi

                        if node -e "const p=require('./$dir/package.json'); process.exit(p.scripts && p.scripts.test && p.scripts.test !== 'echo \\"Error: no test specified\\" && exit 1' ? 0 : 1)"; then
                            (
                                cd "$dir"
                                npm ci
                                npm test -- --runInBand
                            )
                        else
                            echo "No usable test script found in $dir/package.json"
                            exit 1
                        fi
                    done
                '''
            }
        }

        stage('Trivy Source and Configuration Scan') {
            steps {
                sh '''
                    set -eu

                    trivy fs \
                      --scanners vuln,misconfig,secret \
                      --severity HIGH,CRITICAL \
                      --exit-code 1 \
                      --ignore-unfixed \
                      .

                    trivy config \
                      --severity HIGH,CRITICAL \
                      --exit-code 1 \
                      .
                '''
            }
        }

        stage('Build Docker Images') {
            steps {
                sh '''
                    set -eu

                    docker build \
                      -t "$FRONTEND_IMAGE:$IMAGE_TAG" \
                      -f frontend/Dockerfile frontend

                    docker build \
                      -t "$BACKEND_IMAGE:$IMAGE_TAG" \
                      -f backend/Dockerfile backend
                '''
            }
        }

        stage('Scan Docker Images') {
            steps {
                sh '''
                    set -eu

                    trivy image \
                      --severity HIGH,CRITICAL \
                      --exit-code 1 \
                      --ignore-unfixed \
                      "$FRONTEND_IMAGE:$IMAGE_TAG"

                    trivy image \
                      --severity HIGH,CRITICAL \
                      --exit-code 1 \
                      --ignore-unfixed \
                      "$BACKEND_IMAGE:$IMAGE_TAG"
                '''
            }
        }

        stage('Push Images to Docker Hub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DH_USER',
                        passwordVariable: 'DH_TOKEN'
                    )
                ]) {
                    sh '''
                        set -eu
                        set +x

                        echo "$DH_TOKEN" | docker login \
                          --username "$DH_USER" \
                          --password-stdin

                        docker push "$FRONTEND_IMAGE:$IMAGE_TAG"
                        docker push "$BACKEND_IMAGE:$IMAGE_TAG"

                        docker logout
                    '''
                }
            }
        }
    }

    post {
        always {
            echo 'CI pipeline finished. Review stage results above.'
        }
        success {
            echo 'CI passed: scanned images were pushed to Docker Hub.'
        }
        failure {
            echo 'CI failed: inspect the first failed stage before retrying.'
        }
    }
}

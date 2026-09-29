pipeline {
    agent {
        label 'agent'
    }

    environment {
        IMAGE_NAME  = 'prt-cicd'
        IMAGE_TAG   = 'latest'
        TARGET_HOST = '10.0.8.80'
        IMAGE_FILE  = '/tmp/prt-cicd.tar.gz'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                '''
            }
        }

        stage('Run Docker on Jenkins Agent') {
            steps {
                sh '''
                    docker stop ${IMAGE_NAME} || true
                    docker rm ${IMAGE_NAME} || true

                    docker run -d \
                        --name ${IMAGE_NAME} \
                        -p 8080:8080 \
                        ${IMAGE_NAME}:${IMAGE_TAG}

                    docker ps | grep ${IMAGE_NAME}
                '''
            }
        }

        stage('Save Docker Image') {
            steps {
                sh '''
                    docker save ${IMAGE_NAME}:${IMAGE_TAG} | \
                    gzip > ${IMAGE_FILE}

                    ls -lh ${IMAGE_FILE}
                '''
            }
        }

        stage('Copy Image to Target Server') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'K8S-node',
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USER'
                    )
                ]) {
                    sh '''
                        chmod 600 "$SSH_KEY"

                        scp \
                            -i "$SSH_KEY" \
                            -o StrictHostKeyChecking=no \
                            "${IMAGE_FILE}" \
                            "${SSH_USER}@${TARGET_HOST}:${IMAGE_FILE}"
                    '''
                }
            }
        }

        stage('Load Image on Target Server') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'K8S-node',
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USER'
                    )
                ]) {
                    sh '''
                        chmod 600 "$SSH_KEY"

                        ssh \
                            -i "$SSH_KEY" \
                            -o StrictHostKeyChecking=no \
                            "${SSH_USER}@${TARGET_HOST}" \
                            "gunzip -c ${IMAGE_FILE} | docker load"
                    '''
                }
            }
        }

        stage('Verify Image on Target Server') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'K8S-node',
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USER'
                    )
                ]) {
                    sh '''
                        ssh \
                            -i "$SSH_KEY" \
                            -o StrictHostKeyChecking=no \
                            "${SSH_USER}@${TARGET_HOST}" \
                            "docker images ${IMAGE_NAME}"
                    '''
                }
            }
        }

        stage('Cleanup') {
            steps {
                sh '''
                    rm -f ${IMAGE_FILE}
                '''
            }
        }
    }
}

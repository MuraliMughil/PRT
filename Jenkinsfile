pipeline {
    agent {
        label 'agent'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh ' docker build -t prt-cicd:latest .'
            }
        }

        stage('Verify Docker Image') {
            steps {
                sh ' docker run -d --name prt-test -p 8081:80 prt-cicd:latest'
                sh 'sleep 3'
                sh 'curl -f http://localhost:8081'
            }
        }
    }

    post {
        success {
            echo 'PRT – CI/CD Completed Successfully'
        }
    }
}

pipeline {
    agent {
        kubernetes {
            defaultContainer 'jnlp'
            yaml """
                apiVersion: v1
                kind: Pod
                spec:
                  containers:
                  - name: maven
                    image: maven:3.8.7-openjdk-18-slim
                    command:
                    - cat
                    tty: true
            """
        }
    }

    stages {
        stage('Build') {
            steps {
                script {
                    try {
                        container('maven') {
                            sh 'mvn clean package'
                        }
                    } catch (Exception e) {
                        echo "Build failed: ${e.message}"
                    }
                }
            }
        }

        stage('Test') {
            steps {
                script {
                    try {
                        container('maven') {
                            sh 'mvn test'
                        }
                    } catch (Exception e) {
                        echo "Test failed: ${e.message}"
                    }
                }
            }
        }
        stage('Deploy') {
            steps {
                script {
                    try {
                        container('maven') {
                            sh 'kubectl apply -f deployment.yaml'
                        }
                    } catch (Exception e) {
                        echo "Deployment failed: ${e.message}"
                    }
                }
            }
        }
    }

    post {
        success {
            // Trigger downstream job
            build job: 'QA/Content Services QA/Staging/API Postman Tests/*', wait: false
        }
    }
}

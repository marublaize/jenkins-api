pipeline {
    agent {
        kubernetes {
            label 'my-kubernetes-agent'
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
                container('maven') {
                    sh 'mvn clean package'
                }
            }
        }
        // stage('Test') {
        //     steps {
        //         container('maven') {
        //             // sh 'mvn test'
        //             exit 0
        //         }
        //     }
        // }
        // stage('Deploy') {
        //     steps {
        //         container('maven') {
        //             // sh 'kubectl apply -f deployment.yaml'
        //             exit 0
        //         }
        //     }
        // }
    }
}

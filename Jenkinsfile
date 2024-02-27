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

    environment {
        // These variables are mandatory to stay exactly how they are, or else
        // it won't be able to identify the moment to build or promote an image
        GIT_COMMIT_SHORT = sh (
            script: 'git rev-parse --short=8 ${GIT_COMMIT}',
            returnStdout: true
        ).trim()
    }

    stages {
        // Sets variables defined by the branch name
        stage ('Set Environment') {
            steps {
                script {
                    // Set default values
                    env.DEPLOY = "1"
                    def envMap = [:]

                    // Production only has tagged commits, not ending in -rc
                    if (env.TAG_NAME && env.TAG_NAME ==~ /^\d+\.\d+\.\d+$/) {
                        envMap = [ohEnv           : 'production']
                    }
                    // Staging has tagged commits with -rc in the end
                    else if ((env.TAG_NAME && env.TAG_NAME ==~ /^\d+\.\d+\.\d+-rc.*$/) ||
                              env.BRANCH_NAME ==~ /^(release|hotfix)-.*/) {
                        envMap = [ohEnv           : 'staging']
                    }
                    // Main goes to platform
                    else if (env.BRANCH_NAME ==~ /^(main|master)$/) {
                        envMap = [ohEnv           : 'development']
                    }
                    // Other branches can compile and test, but no artifact will be created
                    else {
                        envMap = [ohEnv: 'test']
                        env.DEPLOY = "0"
                    }

                    env.ohEnv               = envMap.ohEnv
                }
            }
        }

        stage('Build') {
            when {
                not {
                    environment name: 'ohEnv', value: 'production'
                }
            }
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
            when {
                not {
                    environment name: 'ohEnv', value: 'production'
                }
            }
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
            when {
                not {
                    environment name: 'DEPLOY', value: '0'
                }
            }
            steps {
                script {
                    try {
                        container('maven') {
                            sh 'apt update && apt install -y kubectl'
                            sh 'kubectl apply -f deployment.yaml'
                        }
                    } catch (Exception e) {
                        echo "Deployment failed: ${e.message}"
                    }
                }
            }
        }
    }

    // post {
    //     success {
    //         script {
    //             // Define wildcard pattern for branch names
    //             def wildcardPattern = /^(main|master)$|(release|hotfix)-.*/

    //             // Get list of branch names from downstream job
    //             def allBranches = jenkins.model.Jenkins.instance.getItemByFullName('QA/Content Services QA/Staging/API Postman Tests').getAllJobs().findAll { it instanceof hudson.model.AbstractProject }

    //             // Filter branches using wildcard pattern
    //             def matchingBranches = allBranches.findAll { branch ->
    //                 branch.name ==~ wildcardPattern
    //             }

    //             // Trigger downstream job for matching branches
    //             matchingBranches.each { matchingBranch ->
    //                 build job: "${matchingBranch.fullName}", wait: false
    //             }
    //         }
    //     }
    // }

    post {
        success {
            // Trigger downstream pipeline
            build job: 'QA/Content Services QA/Staging/API Postman Tests/main', wait: false
        }
    }

}

pipeline {
    agent any


    tools {
        jdk 'JDK17'
        nodejs 'node22'
    }

   environment {
        SCANNER_HOME = tool "sonar-scanner"
    }


    stages {


         stage('Cleanup Workspace') {
            steps {
                cleanWs()
            }
        }


        stage('Checkout from SCM') {
            steps {
                git branch: 'master',  url: 'https://github.com/mimaraslan/devops-004-pipeline-aws.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                  sh 'npm install'
            }
        }

        /*
        stage("Sonarqube Analysis") {
            steps {
                withSonarQubeEnv('SonarTokenForJenkins') {
                    sh '''$SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=devops-004-pipeline-aws \
                    -Dsonar.projectKey=devops-004-pipeline-aws'''
                }
            }
        }
       */

        stage('Run SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarTokenForJenkins') {
                    sh '''
                        ${SCANNER_HOME}/bin/sonar-scanner \
                        -Dsonar.projectKey=devops-004-pipeline-aws \
                        -Dsonar.sources=src
                    '''
                }
            }
        }


       stage("Quality Gate"){
           steps {
               script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'SonarTokenForJenkins'
                }
            }
        }


        stage('TRIVY FS SCAN') {
             steps {
                 sh "trivy fs . > trivyfs.txt"
             }
         }


        stage("Docker Build & Push"){
             steps{
                 script{
                   withDockerRegistry(credentialsId: 'dockerhub', toolName: 'docker'){
                      sh "docker build -t devops-004-pipeline-aws ."
                      sh "docker tag devops-004-pipeline-aws mimaraslan/devops-004-pipeline-aws:latest "
                      sh "docker push mimaraslan/devops-004-pipeline-aws:latest "
                    }
                }
            }
        }


        stage("TRIVY Image Scan"){
            steps{
                sh "trivy image mimaraslan/devops-004-pipeline-aws:latest > trivyimage.txt"
            }
        }



        stage('Deploy to Kubernetes'){
            steps{
                script{
                    dir('kubernetes') {
                      withKubeConfig(caCertificate: '', clusterName: '', contextName: '', credentialsId: 'kubernetes', namespace: '', restrictKubeConfigAccess: false, serverUrl: '') {
                      sh 'kubectl delete --all pods'
                      sh 'kubectl apply -f deployment.yml'
                      sh 'kubectl apply -f service.yml'
                      }
                    }
                }
            }
        }



        stage('Docker Image to Clean') {
            steps {
                // sh 'docker rmi mimaraslan/devops-004-pipeline-aws:latest'
                sh 'docker image prune -f'
            }
        }

    }


/*
    post {
     always {
        emailext attachLog: true,
            subject: "'${currentBuild.result}'",
            body: "Project: ${env.JOB_NAME}<br/>" +
                "Build Number: ${env.BUILD_NUMBER}<br/>" +
                "URL: ${env.BUILD_URL}<br/>",
            to: 'mimaraslan@gmail.com',
            attachmentsPattern: 'trivyfs.txt,trivyimage.txt'
        }
    }
*/

}
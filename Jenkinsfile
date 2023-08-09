pipeline {
    agent any
/*
	tools {
        maven "maven3"
    }
*/
    environment {
        registry = "abhishekm89/app"        // DockerHub Registry path
        registryCredential = 'dockerhub'    // DockerHub creds saved in Jenkins globalCreds
    }
    stages {
        stage('BUILD') {
            steps {
                sh 'mvn clean install -DskipTests'
            }
            post {
                success {
                    echo 'Now Archiving...'
                    archiveArtifacts artifacts: '**/target/*.war'
                }
            }
        }
        stage('UNIT TEST') {
            steps {
                sh 'mvn test'
            }
        }
        stage('INTEGRATION TEST') {
            steps {
                sh 'mvn verify -DskipUnitTests'
            }
        }
        stage ('CODE ANALYSIS WITH CHECKSTYLE') {
            steps {
                sh 'mvn checkstyle:checkstyle'
            }
            post {
                success {
                    echo 'Generated Analysis Result'
                }
            }
        }
        stage('CODE ANALYSIS WITH SONARQUBE') {
            environment {
                scannerHome = tool 'sonarscanner'   // Value from SonarQube Scanner - Jenkins Tool Configuration
            }
            steps {
                withSonarQubeEnv('sonar-pro') {     // value from Jenkins SonarQube - Configure System
                    sh '''${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=vprofile \
                   -Dsonar.projectName=vprofile-repo \
                   -Dsonar.projectVersion=1.0 \
                   -Dsonar.sources=src/ \
                   -Dsonar.java.binaries=target/test-classes/com/visualpathit/account/controllerTest/ \
                   -Dsonar.junit.reportsPath=target/surefire-reports/ \
                   -Dsonar.jacoco.reportsPath=target/jacoco.exec \
                   -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml'''
                }

                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        stage('BUILDING IMAGE') {
            steps {
                script {
                    dockerImage = docker.build registry + ":v$BUILD_NUMBER"
                }
            }
        }    
        stage('UPLOAD IMAGE TO REGISTRY') {
            steps {
                script {
                    docker.withRegistry( '', registryCredential ) {
                        dockerImage.push("v$BUILD_NUMBER")
                        dockerImage.push('latest')
                    }
                }
            }
        }
        stage('REMOVE UNUSED DOCKER IMAGE') {
          steps{
            sh "docker rmi $registry:$BUILD_NUMBER"
          }
        }
        stage('KUBERNETES DEPLOY') {
	        agent { 
                label 'KOPS' 
            }
            steps {
                sh "helm upgrade --install --force vprofile-stack helm/vprofilecharts --set appimage=${registry}:v${BUILD_NUMBER} --namespace prod"
                // helm command will run from KOPS_Server
            }
        }
    }
}

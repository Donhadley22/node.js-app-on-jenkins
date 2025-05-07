pipeline {
  agent any

  tools {
    nodejs 'Nodejs 23'
  }

  environment {
    DOCKER_IMAGE          = 'donhadley/chucknorris-jokes'
    DOCKERFILE            = 'Dockerfile'
    DOCKER_REGISTRY       = 'index.docker.io/v1'
    DOCKER_CREDENTIALS_ID = 'dockerhub-creds'
    DOCKER_TAG            = "${env.BUILD_NUMBER}"
    EC2_REGION            = 'us-east-1'
    SSH_CREDENTIALS_ID    = 'ec2-ssh-key'
    EC2_USER              = 'ubuntu'
    EC2_HOST              = '3.87.218.77'
    CONTAINER_NAME        = 'chucknorris-app'
    HOST_PORT             = 80
    CONTAINER_PORT        = 3000
    SONAR_PROJECT_KEY     = 'nodejs-app-sonar'
    SONAR_URL             = 'http://sonarqube:9000'
    SONAR_TOKEN           = 'your-sonar-token' // Replace with your actual SonarQube token
    SONAR_CREDENTIALS_ID  = 'sonar-creds' // Replace with your actual SonarQube credentials ID
  }

  stages {

    stage('Git Checkout') {
      steps {
        echo 'Checking out code...'
        git url: 'https://github.com/Donhadley22/node.js-app-on-jenkins.git', branch: 'main'
        checkout scm
      }
    }

    stage('Install Dependencies') {
      steps {
        echo 'Installing dependencies...'
        sh 'npm install'
      }
    }
    
    stage('Run Test') {
      steps {
        echo 'Running tests...'
        sh 'npm test'
      }
    }

    stage('SonarQube Analysis') {
      steps {
        withSonarQubeEnv('MySonarServer') { // This name must match Jenkins config
          sh """
            npx sonar-scanner \
              -Dsonar.projectKey=$SONAR_PROJECT_KEY \
              -Dsonar.sources=. \
              -Dsonar.host.url=$SONAR_URL \
              -Dsonar.login=$SONAR_TOKEN
          """
        }
      }
    }


    stage('Build') {
      steps {
        echo 'Building Docker image...'
        script {
          docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}", "-f ${DOCKERFILE} .")
        }
      }
    }

    stage('Push') {
      steps {
        echo 'Pushing Docker image to Docker Hub...'
        script {
          docker.withRegistry('https://index.docker.io/v1/', "${DOCKER_CREDENTIALS_ID}") {
          docker.image("${DOCKER_IMAGE}:${DOCKER_TAG}").push()
      }
    }
  }
}


    stage('Deploy') {
      steps {
        echo 'Deploying to AWS EC2...'
        script {
          sshagent([SSH_CREDENTIALS_ID]) {
            sh """
              ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} \\
              'docker pull ${DOCKER_IMAGE}:${DOCKER_TAG} && \
              docker stop ${CONTAINER_NAME} || true && \
              docker rm ${CONTAINER_NAME} || true && \
              docker run -d --name ${CONTAINER_NAME} -p ${HOST_PORT}:${CONTAINER_PORT} ${DOCKER_IMAGE}:${DOCKER_TAG}'
             """

          }
        }
      }
    }
  }

  post {
    success {
      echo "✅ Deployed successfully to EC2 🎉"
    }
    failure {
      echo "❌ Deployment failed. Please check the logs for details."
    }
  }
}
// This Jenkinsfile is a declarative pipeline that automates the process of building, testing, and deploying a Dockerized Node.js application to an AWS EC2 instance. It includes stages for checking out the code, building the Docker image, running tests, pushing the image to Docker Hub, and deploying it to the EC2 instance. The pipeline uses environment variables for configuration and SSH credentials for secure access to the EC2 instance.
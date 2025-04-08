pipeline{
    agent any

    environment {
        // Define any environment variables here
        DOCKER_IMAGE = 'donhadley/chucknorris-jokes'
        DOCKERFILE = 'Dockerfile'
        DOCKER_REGISTRY = 'donhadley'
        DOCKER_CREDENTIALS_ID = 'dockerhub-creds'
        DOCKER_TAG = "${env.BUILD_NUMBER}"
        EC2_INSTANCE_ID = 'i-02eb6d1560b86c5c3'
        EC2_REGION = 'us-east-1'
        SSH_CREDENTIALS_ID = 'ec2-ssh-ke'
        EC2_USER              = 'ubuntu' // Change to your EC2 user (e.g., 'ec2-user' for Amazon Linux)
        EC2_KEY_PAIR_NAME     = 'Caleb-key' // Change to your EC2 key pair name
        EC2_HOST              = '54.234.226.28' // Add your EC2 public IP here
        CONTAINER_NAME        = 'chucknorris-app'
        HOST_PORT             = 80
        CONTAINER_PORT        = 3000
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code...'
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo 'Building...'
                script {
                    docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}", "-f ${DOCKERFILE} .")
                }
        }
        stage('Test') {
            steps {
                echo 'Testing...'
                script {
                    docker.image("${DOCKER_IMAGE}:${DOCKER_TAG}").inside {
                        sh 'npm install'
                        sh 'npm test'
                    }
                }
            }
        }
        stage('Push') {
            steps {
                echo 'Pushing Docker image...'
                script {
                    docker.withRegistry("https://${DOCKER_REGISTRY}", "${DOCKER_CREDENTIALS_ID}") {
                        docker.image("${DOCKER_IMAGE}:${DOCKER_TAG}").push()
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying to EC2...'
                script {
                    // SSH into the EC2 instance and run the Docker container
                    sshagent([SSH_CREDENTIALS_ID]) {
                        sh """
                            ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} << EOF
                            docker pull ${DOCKER_IMAGE}:${DOCKER_TAG}
                            docker stop ${CONTAINER_NAME} || true
                            docker rm ${CONTAINER_NAME} || true
                            docker run -d --name ${CONTAINER_NAME} -p ${HOST_PORT}:${CONTAINER_PORT} ${DOCKER_IMAGE}:${DOCKER_TAG}
                            EOF
                        """
                    }
                }
            }
        }
    }
}
}

    // Post actions to handle success or failure
post {
    success {
      echo "Deployed successfully to EC2 🎉"
    }
    failure {
      echo "Deployment failed ❌"
    }
  }


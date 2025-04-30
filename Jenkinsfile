pipeline {
  agent any

  environment {
    SSH_CREDENTIALS_ID = 'jenkins-slave-ssh'
    TERRAFORM_DIR      = 'terraform'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Init Terraform') {
      steps {
        dir("${env.TERRAFORM_DIR}") {
          sshagent (credentials: [env.SSH_CREDENTIALS_ID]) {
            sh 'terraform init'
          }
        }
      }
    }

    stage('Terraform Plan') {
      steps {
        dir("${env.TERRAFORM_DIR}") {
          sshagent (credentials: [env.SSH_CREDENTIALS_ID]) {
            sh 'terraform plan -out=tfplan'
          }
        }
      }
    }

    stage('Terraform Apply') {
      steps {
        dir("${env.TERRAFORM_DIR}") {
          sshagent (credentials: [env.SSH_CREDENTIALS_ID]) {
            sh 'terraform apply -auto-approve tfplan'
          }
        }
      }
    }
  }

  post {
    success { echo "K8s cluster created!" }
    failure { echo "Build failed, check logs." }
  }
}


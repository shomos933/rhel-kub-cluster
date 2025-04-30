// jenkins который к корне репозитория
pipeline {
  agent any

  environment {
    SSH_CRED = "jenkins-slave-ssh"
    TER_DIR = 'terraform'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Init Terraform') {
      steps {
        dir("${env.TER_DIR}") {
          sshagent (credentials: [env.SSH_CRED]) {
            sh 'terraform init'
          }
        }
      }
    }

    stage('Terraform Plan') {
      steps {
        dir("${env.TER_DIR}") {
          sshagent (credentials: [env.SSH_CRED]) {
            sh 'terraform plan -out=tfplan'
          }
        }
      }
    }

    stage('Terraform Apply') {
      steps {
        dir("${env.TER_DIR}") {
          sshagent (credentials: [env.SSH_CRED] {
            sh 'terraform apply -auto-approve tfplan'
          }
        }
      }
    }

    post {
      success {
        echo "Kubernetes cluster created successfully!"
    }
      failure {
        echo "Something went wrong, check the logs."
    }
  }
}



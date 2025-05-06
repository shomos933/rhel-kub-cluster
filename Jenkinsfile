pipeline {
  // 1) глобально на весь пайплайн
  agent { label "hypervisor" }

  environment {
    TERRAFORM_DIR = 'terraform'
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Init Terraform') {
      steps {
        dir("${env.TERRAFORM_DIR}") {
          sh 'terraform init'
        }
      }
    }
    stage('Terraform Plan') {
      steps {
        dir("${env.TERRAFORM_DIR}") {
          sh 'terraform plan -out=tfplan'
        }
      }
    }
    stage('Terraform Apply') {
      steps {
        dir("${env.TERRAFORM_DIR}") {
          sh 'terraform apply -auto-approve tfplan'
        }
      }
    }
  }

  post {
    success { echo "K8s cluster created!" }
    failure { echo "Build failed, check logs." }
  }
}


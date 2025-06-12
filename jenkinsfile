pipeline {
    agent any

    tools {
        nodejs 'Node 18'  // Ensure this matches your Jenkins NodeJS tool name
    }

    environment {
        APP_DIR = '/home/ec2-user/chat-app'
    }

    stages {
        stage('Clone Repository') {
            steps {
                git url: 'https://github.com/your-username/project2_chat_nodejs.git', branch: 'project2'
            }
        }

        stage('Install Dependencies') {
            steps {
                dir('chat-app') {
                    sh 'npm install'
                }
            }
        }

        stage('Deploy App') {
            steps {
                // Sync files to live app dir (skip node_modules)
                sh 'rsync -av --exclude=node_modules chat-app/ $APP_DIR/'

                // Restart Node.js app
                sh 'sudo systemctl restart chat-app'
            }
        }
    }

    post {
        success {
            echo "Deployment completed successfully!"
        }
        failure {
            echo "Deployment failed!"
        }
    }
}

pipeline {
    agent any

    environment {
        APP_DIR = '/home/ec2-user/chat-app'
    }

    stages {
        stage('Clone Repository') {
            steps {
                git url: 'https://github.com/Divine-Yawson/project2_chat_nodejs.git', branch: 'project2'
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
                sh 'rsync -av --exclude=node_modules chat-app/ $APP_DIR/'
                sh 'sudo systemctl restart chat-app'
            }
        }
    }
}

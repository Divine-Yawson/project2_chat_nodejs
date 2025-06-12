# Real-Time Chat App 🚀

A simple real-time chat application built with **Node.js**, **Express**, and **Socket.IO**, deployed to an **AWS EC2 instance** using a **Jenkins CI/CD pipeline**.

## 🌐 Live Demo

> Replace with your public IP or domain (e.g., http://your-ec2-ip)

---

## 📁 Project Structure

project2_chat_nodejs/
├── chat-app/
│ ├── app.js # Main server file
│ ├── index.html # Frontend UI
│ ├── package.json # Dependencies and scripts
│ └── package-lock.json # Dependency lock file
├── Jenkinsfile # Jenkins pipeline script
└── README.md


---

## 🚀 Features

- Real-time bi-directional chat using Socket.IO
- Lightweight frontend with HTML
- Automated build & deployment with Jenkins
- Hosted on an AWS EC2 instance

---

## 🛠️ Technologies Used

- Node.js
- Express.js
- Socket.IO
- HTML/CSS (minimal)
- Jenkins
- AWS EC2
- Nginx (optional for reverse proxy)
- Ansible (for server setup, optional)

---

## 📦 Installation

### Local Development

1. Clone the repository:
   ```bash
   git clone https://github.com/Divine-Yawson/project2_chat_nodejs.git
   cd project2_chat_nodejs/chat-app
Install dependencies:

bash
Copy
Edit
npm install
Start the server:

bash
Copy
Edit
node app.js
Visit http://localhost:3000 in your browser.

⚙️ CI/CD Pipeline Overview
Jenkinsfile Stages:
Checkout Code
Clones dev branch from GitHub.

Install Dependencies
Installs NPM dependencies via npm install.

Deploy App

Uses rsync to transfer app to EC2 /home/ec2-user/chat-app.

Restarts the systemd service (chat-app.service).

Systemd Service Configuration (on EC2):
ini
Copy
Edit
[Unit]
Description=Chat App
After=network.target

[Service]
ExecStart=/usr/bin/node /home/ec2-user/chat-app/app.js
Restart=always
User=ec2-user
Environment=PORT=3000

[Install]
WantedBy=multi-user.target
🔐 Security & Permissions
Jenkins runs without sudo by default.

Ensure EC2 directories like /home/ec2-user/chat-app are writable by Jenkins.

For secure sudo usage in Jenkins, consider using:

groovy
Copy
Edit
sh 'echo your_password | sudo -S systemctl restart chat-app'
Or better, allow passwordless restart in /etc/sudoers.d/jenkins.

📡 Deployment URL
Replace with your EC2 IP or domain

cpp
Copy
Edit
http://<your-ec2-ip>:3001

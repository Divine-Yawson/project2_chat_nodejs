const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const path = require('path');

const app = express();
const server = http.createServer(app);
const io = socketIo(server);

// Serve the index.html file
app.use(express.static(path.join(__dirname)));

io.on('connection', socket => {
    console.log('User connected');

    socket.on('chat message', msg => {
        console.log('Message received:', msg);
        io.emit('chat message', msg); // Broadcast to all clients
    });

    socket.on('disconnect', () => console.log('User disconnected'));
});

server.listen(3001, () => console.log('Chat app running on port 3001'));

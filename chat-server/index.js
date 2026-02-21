const express = require("express");
const http = require("http");
const { Server } = require("socket.io");
const cors = require("cors");

const app = express();
app.use(cors());

const server = http.createServer(app);

const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

let users = {}; // Store online users: { userId: socketId }

io.on("connection", (socket) => {
  console.log("A user connected:", socket.id);

  // Register user with their ID
  socket.on("register", (userId) => {
    users[userId] = socket.id;
    console.log("User registered:", userId);
  });

  // Handle sending message
  socket.on("send_message", (data) => {
    const { fromId, toId, message } = data;
    const receiverSocket = users[toId];
    if (receiverSocket) {
      io.to(receiverSocket).emit("receive_message", { fromId, message });
    }
  });

  socket.on("disconnect", () => {
    for (let id in users) {
      if (users[id] === socket.id) delete users[id];
    }
    console.log("User disconnected:", socket.id);
  });
});

server.listen(3000, () => console.log("Server running on port 3000"));

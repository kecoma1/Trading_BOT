import socket

# Creating a TCP socket
serversocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Setting the ip and the port of the server
serversocket.bind(("localhost", 8456))

# Max 5 connections in a queue
serversocket.listen(5) 

# Accepting one connection
connection, addr = serversocket.accept()
print("Connection stablished with:", addr)

print("Waiting for message")
rec_msg = connection.recv(1024).decode()
connection.close()
print(addr, "sent you the message:", rec_msg)


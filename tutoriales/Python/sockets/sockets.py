import socket

# Cretating a TCP socket
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Connecting to the server
s.connect(("localhost", 8456))

# Message to send
msg = input("Message to send: ")

s.sendall(msg.encode())
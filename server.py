import socket

ADDR = "localhost"
PORT = 8081

server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    
server_socket.bind((ADDR, PORT))
server_socket.listen(10)

connection, addr = server_socket.accept()
print("[INFO]\t", addr, "connected")

msg = connection.recv(1024).decode()
print(msg)
connection.send("Hello".encode())
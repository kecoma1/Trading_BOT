import socket

# Creating the server socket
serversocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
serversocket.bind(("localhost", 8466))
serversocket.listen(10)

connection, addr = serversocket.accept()
print("[INFO]\tConnection stablished with:", addr)

msg = ""
while not "END CONNECTION\0" in msg:
    msg = connection.recv(1024).decode()
    print("[INFO]\t Message:", msg)
connection.close()

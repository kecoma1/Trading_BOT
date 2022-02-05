import socket

serversocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

serversocket.bind(("localhost", 8888))
serversocket.listen(10)

connection, addr = serversocket.accept()
print("[INFO]\tConexión establecida con:", addr)

msg = "\0"
while not "END CONNECTION\0" in msg and msg != "":
    msg = connection.recv(1024).decode()
    print("[INFO]\tMensaje:", msg)
connection.close()
serversocket.close()
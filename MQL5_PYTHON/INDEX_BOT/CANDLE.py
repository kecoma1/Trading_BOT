import socket
import json

PORT = 8678
ADDR = "localhost"

def socket_ini():
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    
    server_socket.bind((ADDR, PORT))
    server_socket.listen(10)
    
    connection, addr = server_socket.accept()
    print("[INFO]\t", addr, "connected")
    
    return connection, server_socket
    

def thread_candle(stop_event, data):
    msg = ""
    
    connection, server_socket = socket_ini()
    
    while not stop_event.is_set():
        msg = connection.recv(1024).decode()
        
        if "END" in msg:
            break
                
        try:
            temp = json.loads(msg)
            data['0'], data['1'] = temp['0'], temp['1']
        except:
            print("[INFO]\tError trying to convert to float, ignored")
            break
            
        
    connection.close()
    server_socket.close()
        
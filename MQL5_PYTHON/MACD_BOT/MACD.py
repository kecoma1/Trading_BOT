from http import server
import socket


def socket_ini():
    """Function to initialice a server to receive the MACD info.

    Returns:
        Connection object
    """
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    
    server_socket.bind(("localhost", 8888))
    server_socket.listen(10)
    
    connection, addr = server_socket.accept()
    print("[INFO]\tConnected with:", addr)
    
    return connection, server_socket

def thread_macd(stop_event, data):
    """Function executed by a thread. Loads the MACD indicator
    directly from MT5

    Args:
        stop_event (thread.Event): Event to stop the thread.
        data (dict): Dictionary where the data is going to be stored.
    """
    msg = ""
    
    connection, server_socket = socket_ini()
    
    while not stop_event.wait(0.00001):
        # Taking the ticks
        msg = connection.recv(1024).decode()
        
        if "END CONNECTION" in msg:
            break
        macds, signals = msg.split("|")
        macds, signals = macds.split(","), signals.split(",")
        
        data["MACD"] = [float(m) for m in reversed(macds)]
        data["SIGNAL"] = [float(s) for s in reversed(signals)]
        
    connection.close()
    server_socket.close()
        
    
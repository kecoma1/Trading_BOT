string   address = "localhost";
int      port = 8466;


void OnInit() {
   // Initializing the socket
   int socket = SocketCreate();
   if (socket == INVALID_HANDLE) Print("Error - 1: SocketCreate failure. ", GetLastError());
   else {
      if (SocketConnect(socket, address, port, 10000)) {
         Print("[INFO]\tConnection stablished");
         
         // Creating the message
         char req[];
         int len = StringToCharArray("END CONNECTION\0", req)-1;
         
         SocketSend(socket, req, len);
      } else Print("Error - 2: SocketConnect failure. ", GetLastError());
      SocketClose(socket);
   }
}

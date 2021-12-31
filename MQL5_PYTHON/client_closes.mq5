string   address = "localhost";
int      port = 8466;
short    num_msg = 0;
bool closed = false;
int socket;
MqlRates candles[];

void OnInit() {

   // Initializing candles
   ArraySetAsSeries(candles, true);

   // Initializing the socket
   socket = SocketCreate();
   if (socket == INVALID_HANDLE) Print("Error - 1: SocketCreate failure. ", GetLastError());
   else {
      if (SocketConnect(socket, address, port, 10000)) Print("[INFO]\tConnection stablished");
      else Print("Error - 2: SocketConnect failure. ", GetLastError());
   }
}

void OnTick() {
   CopyRates(_Symbol, _Period, 0, 1, candles);

   if (num_msg < 10) {
      Print("[INFO]\tSending close");
      num_msg++;
      string msg;
      StringConcatenate(msg, _Symbol, " CLOSE: ", candles[0].close);
      
      char req[];
      int len = StringToCharArray(msg, req)-1;
      SocketSend(socket, req, len);
   } else {
      if (!closed) {
         // Creating the message
         char req[];
         int len = StringToCharArray("END CONNECTION\0", req)-1;

         SocketSend(socket, req, len);

         SocketClose(socket);
         closed = true;
      }
   }
   
}
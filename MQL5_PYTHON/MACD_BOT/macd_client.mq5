/* Socket variables */
string   address = "localhost";
int      port = 8686;
int      socket;                 // Socket handle
int      MAX_BUFF_LEN = 1024;    // Max size for reading in the buffer

/* MACD variables */
int      macd_h;                 // MACD handle
double   macd[];
double   signal[];


void OnInit() {
   macd_h = iMACD(_Symbol, _Period, 12, 26, 9, PRICE_CLOSE);
   if (macd_h == INVALID_HANDLE) Print("Error - 3: iMACD failure. ", GetLastError());

   // Initializing the socket
   socket = SocketCreate();
   if (socket == INVALID_HANDLE) Print("Error - 1: SocketCreate failure. ", GetLastError());
   else {
      if (SocketConnect(socket, address, port, 10000)) Print("[INFO]\tConnection stablished");
      else Print("Error - 2: SocketConnect failure. ", GetLastError());
   }
}


void OnDeinit(const int reason) {
   /* Closing the socket */
   // Creating the message
   char req[];
   
   Print("[INFO]\tClosing the socket.");
   
   int len = StringToCharArray("END CONNECTION\0", req)-1;
   SocketSend(socket, req, len);
   SocketClose(socket);
}


void OnTick() {
   // Loading the macd values
   CopyBuffer(macd_h, MAIN_LINE, 0, 2, macd);
   CopyBuffer(macd_h, SIGNAL_LINE, 0, 2, signal);
      
   // Sending MACD data
   Print("[INFO]\tSending MACD and SIGNAL");
   string msg;
   StringConcatenate(msg, macd[0], ",", macd[1], "|", signal[0], ",", signal[1]);
   
   char req[];
   int len = StringToCharArray(msg, req)-1;
   SocketSend(socket, req, len);
}
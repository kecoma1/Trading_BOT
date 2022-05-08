#define PORT 8688
#define ADDR "localhost"
#define MAX_BUFF_LEN 1024
#define TIMEOUT 10000

/* Socket variables */
int      socket;                 // Socket handle

/* RSI variables */
int      rsi_h;                  // RSI handle
double   rsi[];                  // RSI array


void OnInit() {
   rsi_h = iRSI(_Symbol, _Period, 14, PRICE_CLOSE);
   if (rsi_h == INVALID_HANDLE) Print("Error - 3: iRSI failure. ", GetLastError());

   // Initializing the socket
   socket = SocketCreate();
   if (socket == INVALID_HANDLE) Print("Error - 1: SocketCreate failure. ", GetLastError());
   else {
      if (SocketConnect(socket, ADDR, PORT, TIMEOUT)) Print("[INFO]\tConnection stablished");
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
   CopyBuffer(rsi_h, 0, 0, 2, rsi);
      
   // Sending RSI data
   Print("[INFO]\tSending RSI");
   string msg;
   StringConcatenate(msg, rsi[0], ",", rsi[1]);
   
   char req[];
   int len = StringToCharArray(msg, req)-1;
   SocketSend(socket, req, len);
}
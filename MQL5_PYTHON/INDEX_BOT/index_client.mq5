#define PORT 8676
#define ADDR "localhost"
#define MAX_BUFF_LEN 1024
#define TIMEOUT 10000

/* Socket variables */
int      socket;                 // Socket handle

/* Candle variables */
MqlRates candles[];


void OnInit() {
   ArraySetAsSeries(candles, true);

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
   // Loading the candles values
   CopyRates(_Symbol, _Period, 0, 2, candles);
      
   // Sending RSI data
   Print("[INFO]\tSending Candles");
   string msg;
   StringConcatenate(msg, "{\"0\": [", candles[0].close, ", ", candles[0].open,  "], "
                           "\"1\": [", candles[1].close, ", ", candles[1].open, "]}");
   
   char req[];
   int len = StringToCharArray(msg, req)-1;
   SocketSend(socket, req, len);
}
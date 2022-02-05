/*
MESSAGES TO SEND IMPLEMENTED:
   macd value 0,macd value 1,macd value 2|signal value 0,signal value 1,signal value 2
   Example:
      0.000032,0.000031,0.000028|0.000032,0.000031,0.000028
   

MESSAGES TO RECEIVE NOT IMPLEMENTED:
   BUY|LOTAGE (double 2 decimals)|STOP_LOSS POINTS (int)|TAKE_PROFIT POINTS (int)
   Example:
      BUY|0.01|30|90
      This opens a buy operation in the current market of 0.01 lotage, with
      a stop loss 30 points below the opening price and a take profit 90 points
      above the opening price.
      
   SELL|LOTAGE (double 2 decimals)|STOP_LOSS POINTS (int)|TAKE_PROFIT POINTS (int)
   Example:
      SELL|0.01|30|90
      This opens a sell operation in the current market of 0.01 lotage, with
      a stop loss 30 points above the opening price and a take profit 90 points
      below the opening price.
*/

#include <Trade/Trade.mqh>
CTrade trade;


/* Socket variables */
string   address = "localhost";
int      port = 8888;
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
   CopyBuffer(macd_h, MAIN_LINE, 0, 3, macd);
   CopyBuffer(macd_h, SIGNAL_LINE, 0, 3, signal);
      
   // Sending MACD data
   Print("[INFO]\tSending MACD and SIGNAL");
   string msg;
   StringConcatenate(msg, macd[0], ",", macd[1], ",", macd[2], " | ", signal[0], ",", signal[1], ",", signal[2]);
   
   char req[];
   int len = StringToCharArray(msg, req)-1;
   SocketSend(socket, req, len);
}

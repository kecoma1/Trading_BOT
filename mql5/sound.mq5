// https://www.mql5.com/es/articles/748

#include <Trade/Trade.mqh>
#resource "\\Files\\sound.wav"

/* Handler */
int MACD_h;

/* Arrays where the indicator data is stored */
double MACD[];
double SIGNAL[];

/* For openning operations */
CTrade trade;
ulong trade_ticket = 0;
bool time_passed = true;


int OnInit() {

   PlaySound("::Files\\sound.wav");
   /* Initializing the handlers */
   MACD_h = iMACD(_Symbol, _Period, 12, 26, 9, PRICE_CLOSE);
   
   ArraySetAsSeries(MACD, true);
   ArraySetAsSeries(SIGNAL, true);

   return(INIT_SUCCEEDED);
}

void OnTick() {
   /* Saving the data of the indicator */
   CopyBuffer(MACD_h, 0, 1, 4, MACD);
   CopyBuffer(MACD_h, 1, 1, 4, SIGNAL);
   
   /* Checking if there's an open operation */
   if (PositionSelectByTicket(trade_ticket) == false) {
      // Reseting the trade flags
      trade_ticket = 0;
   }
   
   
   if ( // Buy
      MACD[1] < SIGNAL[1] && MACD[0] > SIGNAL[0]      // Cross
      ) {
      PlaySound("::Files\\sound.wav");
   } else if ( // venta
   MACD[1] > SIGNAL[1] && MACD[0] <  SIGNAL[0]      // Cross
   ) {
      PlaySound("::Files\\sound.wav");
   }
}

void OnTimer() {
   time_passed = true;
}
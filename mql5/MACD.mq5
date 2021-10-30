#include <Trade/Trade.mqh>

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
      && MACD[0] < -0.0002
      && trade_ticket <= 0 && time_passed == true
      ) {
      /* Precio actual */
      double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
      
      //--- Abrir compra
      trade.Buy(0.1, _Symbol, Ask, Ask-40*_Point, Ask+50*_Point, NULL);
      trade_ticket = trade.ResultOrder();

      time_passed = false;
      
      EventSetTimer(PeriodSeconds(PERIOD_CURRENT)*3);
      
   } else if ( // venta
   MACD[1] > SIGNAL[1] && MACD[0] <  SIGNAL[0]      // Cross
   && MACD[0] > 0.0002
   && trade_ticket <= 0 && time_passed == true
   ) {
      /* Precio actual */
      double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
      
      //--- Abrir venta      
      trade.Sell(0.1, _Symbol, Bid, Bid+40*_Point, Bid-50*_Point, NULL);
      trade_ticket = trade.ResultOrder();
      
      time_passed = false;
      
      EventSetTimer(PeriodSeconds(PERIOD_CURRENT)*3);
   }
}

void OnTimer() {
   time_passed = true;
}
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
double open_price = 0;


//  500€ -> 0.02
// 1000€ -> 0.05
// 2000€ -> 0.1
// 1500€ -> 0.07
double get_lotage() {
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   return NormalizeDouble((balance/1000)*0.01, 2);
}


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
   if (PositionSelectByTicket(trade_ticket) == false && trade_ticket != 0) {
      // Reseting the trade flags
      trade_ticket = 0;
      open_price = 0;
   } 
   
   /*  BREAK EVEN  */
   else if (trade_ticket != 0 && open_price != 0) {
      double profit = PositionGetDouble(POSITION_PROFIT);
      
      if (profit >= 0.5) {
         trade.PositionModify(trade_ticket, open_price, 0);
         open_price = 0;
      }
   }
   /*  BREAK EVEN  */
   
   
   if ( // Buy
      MACD[1] < SIGNAL[1] && MACD[0] > SIGNAL[0]      // Cross
      && trade_ticket <= 0 && time_passed == true
      ) {
      /* Precio actual */
      double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
      open_price = Ask;
      
      //--- Abrir compra
      double lotage = get_lotage();
      trade.Buy(lotage, _Symbol, Ask, Ask-100*_Point, 0, NULL);
      trade_ticket = trade.ResultOrder();

      time_passed = false;
      
      EventSetTimer(PeriodSeconds(PERIOD_CURRENT)*3);
      
   } else if ( // venta
   MACD[1] > SIGNAL[1] && MACD[0] <  SIGNAL[0]      // Cross
   && trade_ticket <= 0 && time_passed == true
   ) {
      /* Precio actual */
      double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
      open_price = Bid;
      
      //--- Abrir venta
      double lotage = get_lotage();      
      trade.Sell(lotage, _Symbol, Bid, Bid+100*_Point, 0, NULL);
      trade_ticket = trade.ResultOrder();
      
      time_passed = false;
      
      EventSetTimer(PeriodSeconds(PERIOD_CURRENT)*3);
   }
}

void OnTimer() {
   time_passed = true;
}
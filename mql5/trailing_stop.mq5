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
double open_trade_price = 0;

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
   if (PositionSelectByTicket(trade_ticket) == false && trade_ticket != 0) { // No operations
      // Reseting the trade flags
      trade_ticket = 0;
   } 
   /*  TRAILING STOP  */
   else if (trade_ticket != 0) { // Open operation
      ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      
      double cur_price = PositionGetDouble(POSITION_PRICE_CURRENT);
      double new_sl = 0;
      
      if (type == POSITION_TYPE_BUY && cur_price > open_trade_price+20*_Point) {
         new_sl = NormalizeDouble(cur_price-20*_Point, _Digits);
         trade.PositionModify(trade_ticket, new_sl, 0);
         // open_trade_price = new_sl
      }
      else if (type == POSITION_TYPE_SELL && cur_price < open_trade_price-20*_Point) {
         new_sl = NormalizeDouble(cur_price+20*_Point, _Digits);
         trade.PositionModify(trade_ticket, new_sl, 0);
         // open_trade_price = new_sl
      }

      // Si no se cambia el stop loss (es igual a 0) el open_trade_price se mantiene
      // Esto se podría implementar de otra forma, en concreto como muestro en las líneas 61 y 56
      open_trade_price = new_sl ? new_sl : open_trade_price;
   }
   /*  TRAILING STOP  */
   
   
   if ( // Buy
      MACD[1] < SIGNAL[1] && MACD[0] > SIGNAL[0]      // Cross
      && trade_ticket <= 0 && time_passed == true
      ) {
      /* Precio actual */
      double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
      open_trade_price = Ask;
      
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
      open_trade_price = Bid;

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
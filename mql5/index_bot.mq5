// For orders
#include <Trade/Trade.mqh>
CTrade trade;
ulong trade_ticket = 0;

// Variable where the candles are going to be stored
MqlRates candles[];

// For the timer
double time_flag = true;

double get_lotage() {
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double lotage = NormalizeDouble((balance/1000)*0.2, 2);
   return lotage <= 50 ? lotage : 50;
}

void OnInit() {
   ArraySetAsSeries(candles, true);
}

bool bullish(int candle_pos, double points_diff=0) {
   return candles[candle_pos].close-candles[candle_pos].open > points_diff;
}

void OnTick() {
   CopyRates(_Symbol, _Period, 0, 3, candles);
   
   if (bullish(1) && !bullish(0) && trade_ticket <= 0 && time_flag) { // Openning sell
      
      double bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
      
      trade.Sell(get_lotage(), _Symbol, bid, 0, 0);
      trade_ticket = trade.ResultOrder();
      
      time_flag = false;
      EventSetTimer(60);

   } else if (trade_ticket != 0 && bullish(0, 500*_Point) && time_flag) { // Closing sell
   
      trade.PositionClose(trade_ticket);
      trade_ticket = 0;
      
      time_flag = false;
      EventSetTimer(60);
   
   }
}

void OnTimer() { time_flag = true; }
#include <Trade/Trade.mqh>
CTrade trade;
ulong trade_ticket = 0;
bool time_flag = true;

MqlRates candles[];

/*double get_lotage() { // The lotage grows, not static
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double lotage = NormalizeDouble((balance/1000)*0.2, 2);
   return lotage <= 50 ? lotage : 50;
}*/

double get_lotage() { return 0.1; }

bool bearish(int candle_pos, double candle_len=0) {
   return candles[candle_pos].open-candles[candle_pos].close > candle_len;
}

void OnInit() {
   ArraySetAsSeries(candles, true);
}

void OnTick() {
   CopyRates(_Symbol, _Period, 0, 3, candles); 
   
   if (bearish(0, 200*_Point) && time_flag) {
      double bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
   
      trade.Sell(get_lotage(), _Symbol, bid);
      trade_ticket = trade.ResultOrder();
      
      time_flag = false;
      EventSetTimer(60);
      
   } else if (trade_ticket > 0 && !bearish(0)) {
   
      trade.PositionClose(trade_ticket);
      trade_ticket = 0;
      
   }
}

void OnTimer() { 
   time_flag = true;
   EventKillTimer();
}
#include <Trade/Trade.mqh>
CTrade trade;
ulong trade_ticket = 0;
bool time_flag = true;

MqlRates candles[];

/*double get_lotage() {
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double lotage = NormalizeDouble((balance/1000)*0.2, 2);
   return lotage <= 50 ? lotage : 50;
}*/

double get_lotage() { return 0.1; }

bool bullish(int candle_pos, double candle_len=0) {
   return candles[candle_pos].close-candles[candle_pos].open > candle_len;
}

void OnInit() {
   ArraySetAsSeries(candles, true);
}

void OnTick() {
   CopyRates(_Symbol, _Period, 0, 3, candles); 
   
   if (bullish(0, 200*_Point) && time_flag) {
      double ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
   
      trade.Buy(get_lotage(), _Symbol, ask);
      trade_ticket = trade.ResultOrder();
      
      time_flag = false;
      EventSetTimer(60);
      
   } else if (trade_ticket > 0 && !bullish(0)) {
   
      trade.PositionClose(trade_ticket);
      trade_ticket = 0;
      
   }
}

void OnTimer() { 
   time_flag = true;
   EventKillTimer();
}                                                       
#include <Trade/Trade.mqh>
CTrade trade;
ulong trade_ticket = 0;

MqlRates candles[];

bool time_flag = true;

double get_lotage() {
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double lotage = NormalizeDouble((balance/1000)*0.2, 2);
   return lotage <= 50 ? lotage : 50;
}

bool bullish(int candle_pos, double candle_len=0) {
   return candles[candle_pos].close-candles[candle_pos].open > candle_len;
}

void OnInit() {
   ArraySetAsSeries(candles, true);
}

void OnTick() {
   CopyRates(_Symbol, _Period, 0, 3, candles);
   
   if (bullish(1) && !bullish(0) && trade_ticket <= 0 && time_flag) {
   
      double bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
   
      trade.Sell(get_lotage(), _Symbol, bid);
      trade_ticket = trade.ResultOrder();
      
      time_flag = false;
   
   } else if (trade_ticket > 0 && bullish(0, 500*_Point)) {
      trade.PositionClose(trade_ticket);
      
      trade_ticket = 0;
      
      EventSetTimer(60);
   }
}

void OnTimer() { time_flag = true; }
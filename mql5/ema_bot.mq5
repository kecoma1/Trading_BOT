#define SL 100*_Point
#define TP 300*_Point

#include <Trade/Trade.mqh>
CTrade trade;
ulong trade_ticket = 0;
bool time_flag = true;

/* Handlers */
int ema_fast_h;
int ema_medium_h;
int ema_slow_h;

/* Array's */
double ema_fast[];
double ema_medium[];
double ema_slow[];

MqlRates candles[];

bool is_going_up() { 
   for (int i = 1; i < 5; i++)
      if (ema_slow[i-1] > ema_slow[i]) return false;
   
   return true;
}

bool is_going_down() { 
   for (int i = 1; i < 5; i++)
      if (ema_slow[i-1] < ema_slow[i]) return false;
   
   return true;
}

bool is_below_fast() { return ema_fast[0] > candles[0].close; }
bool is_below_medium() { return ema_medium[0] > candles[0].close; }
bool is_below_slow() { return ema_slow[0] > candles[0].close; }

bool is_above_fast() { return ema_fast[0] < candles[0].close; }
bool is_above_medium() { return ema_medium[0] < candles[0].close; }
bool is_above_slow() { return ema_slow[0] < candles[0].close; }

bool buy_cross() { return ema_fast[1] < ema_medium[1] && ema_fast[0] > ema_medium[0]; }
bool sell_cross() { return ema_fast[1] > ema_medium[1] && ema_fast[0] < ema_medium[0]; }

void OnInit() {
   ema_fast_h = iMA(_Symbol, _Period, 14, 0, MODE_EMA, PRICE_CLOSE);
   ema_medium_h = iMA(_Symbol, _Period, 50, 0, MODE_EMA, PRICE_CLOSE);
   ema_slow_h = iMA(_Symbol, _Period, 200, 0, MODE_EMA, PRICE_CLOSE);
   
   ArraySetAsSeries(ema_fast, true);
   ArraySetAsSeries(ema_medium, true);
   ArraySetAsSeries(ema_slow, true);
   
   ArraySetAsSeries(candles, true);
}

void OnTick() {
   CopyBuffer(ema_fast_h, 0, 0, 3, ema_fast);
   CopyBuffer(ema_medium_h, 0, 0, 3, ema_medium);
   CopyBuffer(ema_slow_h, 0, 0, 5, ema_slow);
   
   CopyRates(_Symbol, _Period, 0, 3, candles);
   
   if (sell_cross() && is_below_slow() && is_going_down() && time_flag) {
      double bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
   
      trade.Sell(0.1, _Symbol, bid, bid+SL, bid-TP);
      
      time_flag = false;
      EventSetTimer(PeriodSeconds());
   } else if (buy_cross() && is_above_slow() && is_going_up() && time_flag) {
      double ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
   
      trade.Buy(0.1, _Symbol, ask, ask-SL, ask+TP);
      
      time_flag = false;
      EventSetTimer(PeriodSeconds());
   }
}


void OnTimer() { 
   time_flag = true;
   EventKillTimer();
}
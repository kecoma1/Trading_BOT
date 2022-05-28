#define SL 100*_Point
#define TP 300*_Point

#include <Trade/Trade.mqh>
CTrade trade;
ulong trade_ticket = 0;
bool time_flag = true;

/* Handlers */
int ma_fast_h;
int ma_medium_h;
int ma_slow_h;

/* Array's */
double ma_fast[];
double ma_medium[];
double ma_slow[];

MqlRates candles[];

bool is_going_up() { 
   for (int i = 1; i < 5; i++)
      if (ma_slow[i-1] > ma_slow[i]) return false;
   
   return true;
}

bool is_going_down() { 
   for (int i = 1; i < 5; i++)
      if (ma_slow[i-1] < ma_slow[i]) return false;
   
   return true;
}

bool is_below_fast() { return ma_fast[0] > candles[0].close; }
bool is_below_medium() { return ma_medium[0] > candles[0].close; }
bool is_below_slow() { return ma_slow[0] > candles[0].close; }

bool is_above_fast() { return ma_fast[0] < candles[0].close; }
bool is_above_medium() { return ma_medium[0] < candles[0].close; }
bool is_above_slow() { return ma_slow[0] < candles[0].close; }

bool buy_cross() { return ma_fast[1] < ma_medium[1] && ma_fast[0] > ma_medium[0]; }
bool sell_cross() { return ma_fast[1] > ma_medium[1] && ma_fast[0] < ma_medium[0]; }

void OnInit() {
   ma_fast_h = iMA(_Symbol, _Period, 14, 0, MODE_SMA, PRICE_CLOSE);
   ma_medium_h = iMA(_Symbol, _Period, 50, 0, MODE_SMA, PRICE_CLOSE);
   ma_slow_h = iMA(_Symbol, _Period, 200, 0, MODE_SMA, PRICE_CLOSE);
   
   ArraySetAsSeries(ma_fast, true);
   ArraySetAsSeries(ma_medium, true);
   ArraySetAsSeries(ma_slow, true);
   
   ArraySetAsSeries(candles, true);
}

void OnTick() {
   CopyBuffer(ma_fast_h, 0, 0, 3, ma_fast);
   CopyBuffer(ma_medium_h, 0, 0, 3, ma_medium);
   CopyBuffer(ma_slow_h, 0, 0, 5, ma_slow);
   
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
#define SL 150*_Point
#define TP 300*_Point
#define BUFFLEN 5

input int MARGIN_SL = 100;

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

void trailing_stop(ulong ticket) {
   if(!PositionSelectByTicket(ticket)) return;
   
   double cur_sl = PositionGetDouble(POSITION_SL);
   double open = PositionGetDouble(POSITION_PRICE_OPEN);
   double cur_price = candles[0].close;
   ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
   
   if (type == POSITION_TYPE_SELL && cur_sl - MARGIN_SL*_Point > cur_price && open-MARGIN_SL*_Point > cur_price)
      trade.PositionModify(ticket, cur_price+MARGIN_SL*_Point, 0);
   else if (cur_sl + MARGIN_SL*_Point < cur_price && open+MARGIN_SL*_Point < cur_price)
      trade.PositionModify(ticket, cur_price-MARGIN_SL*_Point, 0);
}

void trailing_stop_all() {
   for(int i = 0; i < PositionsTotal(); i++) {
      ulong ticket = PositionGetTicket(i);
      PositionGetSymbol(i);
      
      trailing_stop(ticket);
   }
}

bool is_going_up() { 
   for (int i = BUFFLEN-1; i >= 1; i--)
      if (!(ema_slow[i] < ema_slow[i-1])) return false;
   
   return true;
}

bool is_going_down() { 
   for (int i = BUFFLEN-1; i >= 1; i--)
      if (!(ema_slow[i] > ema_slow[i-1])) return false;
   
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
   
   trailing_stop_all();
   
   if (sell_cross() && is_below_slow() && is_going_down() && time_flag) {
      double bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
   
      trade.Sell(0.1, _Symbol, bid, bid+SL);
      
      time_flag = false;
      EventSetTimer(PeriodSeconds());
   } else if (buy_cross() && is_above_slow() && is_going_up() && time_flag) {
      double ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
   
      trade.Buy(0.1, _Symbol, ask, ask-SL);
      
      time_flag = false;
      EventSetTimer(PeriodSeconds());
   }
}


void OnTimer() { 
   time_flag = true;
   EventKillTimer();
}
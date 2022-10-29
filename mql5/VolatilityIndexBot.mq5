#include <Trade/Trade.mqh>
CTrade trade;
ulong trade_ticket;


int ema_fast_h;
int ema_slow_h;

double ema_fast[];
double ema_slow[];


bool buy_cross() {
   return ema_slow[1] > ema_fast[1] && ema_slow[0] < ema_fast[0];
}

bool sell_cross() {
   return ema_slow[1] > ema_fast[1] && ema_slow[0] < ema_fast[0];
}

int bars;
bool new_candle() {
   int current_bars = Bars(_Symbol, _Period);
   if (current_bars != bars) {
      bars = current_bars;
      return true;
   }
   
   return false;
}

bool operation_closed() {
   return !PositionSelectByTicket(trade_ticket);
}


int OnInit() {
   ema_fast_h = iMA(_Symbol, _Period, 14, 0, MODE_EMA, PRICE_CLOSE);
   ema_slow_h = iMA(_Symbol, _Period, 100, 0, MODE_EMA, PRICE_CLOSE);
   if (ema_fast_h == INVALID_HANDLE ||ema_slow_h == INVALID_HANDLE) {
      Print("[ERROR] - Indicators not loaded");
      return INIT_FAILED;
   }
   
   ArraySetAsSeries(ema_fast, true);
   ArraySetAsSeries(ema_slow, true);
   
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason) {
   if (ema_fast_h != INVALID_HANDLE) IndicatorRelease(ema_fast_h);
   if (ema_slow_h != INVALID_HANDLE) IndicatorRelease(ema_slow_h);
}

void OnTick() {
   CopyBuffer(ema_fast_h, 0, 1, 2, ema_fast);
   CopyBuffer(ema_slow_h, 0, 1, 2, ema_slow);
   
   if (buy_cross() && new_candle() && operation_closed()) {
      double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
      
      trade.Buy(1, _Symbol, Ask, Ask-50*_Point, Ask+120*_Point);
      trade_ticket = trade.ResultOrder();
   } else if (sell_cross() && new_candle() && operation_closed()) {
      double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);

      trade.Sell(1, _Symbol, Bid, Bid+50*_Point, Bid-120*_Point);
      trade_ticket = trade.ResultOrder();
   }
}
#include <Trade/Trade.mqh>
CTrade trade;
ulong trade_ticket;


int ema_fast_h;
int ema_slow_h;

double ema_fast[];
double ema_slow[];


bool cruce_compra() {
   return ema_fast[1] < ema_slow[1] && ema_fast[0] > ema_slow[0];
}

bool cruce_venta() {
   return ema_fast[1] > ema_slow[1] && ema_fast[0] < ema_slow[0];
}


int bars;
bool nueva_vela() {
   int current_bars = Bars(_Symbol, _Period);
   if (current_bars != bars) {
      bars = current_bars;
      return true;
   }
   
   return false;
}

bool operacion_cerrada() {
   return !PositionSelectByTicket(trade_ticket);
}


int OnInit() {
   ema_fast_h = iMA(_Symbol, _Period, 15, 0, MODE_EMA, PRICE_CLOSE);
   ema_slow_h = iMA(_Symbol, _Period, 100, 0, MODE_EMA, PRICE_CLOSE);
   
   if (ema_fast_h == INVALID_HANDLE || ema_slow_h == INVALID_HANDLE) {
      Print("Error loading the indicators");
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
   
   if (operacion_cerrada()) {
      if (cruce_compra()) {
         trade.Buy(0.01);
         trade_ticket = trade.ResultOrder();
      } else if (cruce_venta()) {
         trade.Sell(0.01);
         trade_ticket = trade.ResultOrder();
      }
   } else if (nueva_vela()) {
      if (cruce_compra() || cruce_venta())
         trade.PositionClose(trade_ticket);
   }
}
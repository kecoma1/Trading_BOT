

input group "EMA";
input int PERIOD_RAPIDA = 10;
input int PERIOD_LENTA = 100;

input group "Operaciones";
input int SL = 400;
input int TP = 1200;

#include <Trade/Trade.mqh>
CTrade trade;
ulong trade_ticket;

int ema_rapida_h;
int ema_lenta_h;
double ema_rapida[];
double ema_lenta[];

// Manejador indicador y array para el SAR
int      sar_h;
double   sar[];


bool operacion_cerrada() {
   return !PositionSelectByTicket(trade_ticket);
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

bool cruce_compra() {
   return ema_rapida[1] < ema_lenta[1] && ema_rapida[0] > ema_lenta[0];
}

bool cruce_venta() {
   return ema_rapida[1] > ema_lenta[1] && ema_rapida[0] < ema_lenta[0];
}

bool precio_encima_sar(double current_price, double normalized_sar) {
   return current_price > normalized_sar;
}

bool precio_debajo_sar(double current_price, double normalized_sar) {
   return current_price < normalized_sar;
}

void trailing_stop() {
   PositionSelectByTicket(trade_ticket);

   double sl_anterior = PositionGetDouble(POSITION_SL);
   double current_price = NormalizeDouble(PositionGetDouble(POSITION_PRICE_CURRENT), _Digits);
   double open_price = NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN), _Digits);
   long type = PositionGetInteger(POSITION_TYPE);
   double movimiento = (current_price-open_price)/_Point;
   
   double normalized_sar = NormalizeDouble(sar[0], _Digits);
   double normalized_sl = NormalizeDouble(sl_anterior, _Digits);
   
   if (normalized_sl != normalized_sar) {
      if (type == POSITION_TYPE_BUY && precio_encima_sar(current_price, normalized_sar))
         trade.PositionModify(trade_ticket, normalized_sar, 0);
      else if (type == POSITION_TYPE_SELL && precio_debajo_sar(current_price, normalized_sar)) {
         trade.PositionModify(trade_ticket, normalized_sar, 0);
      }
   }
}


int OnInit() {
   ema_rapida_h = iMA(_Symbol, _Period, PERIOD_RAPIDA, 0, MODE_EMA, PRICE_CLOSE);
   ema_lenta_h = iMA(_Symbol, _Period, PERIOD_LENTA, 0, MODE_EMA, PRICE_CLOSE);
   sar_h = iSAR(_Symbol, _Period, 0.02, 0.2);
   
   if (ema_rapida_h == INVALID_HANDLE ||ema_rapida_h == INVALID_HANDLE) {
      Print("Error cargando las EMAs");
      return INIT_FAILED;
   }
   
   ArraySetAsSeries(ema_lenta, true);
   ArraySetAsSeries(ema_rapida, true);
   ArraySetAsSeries(sar, true);
   
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason) {
   if (ema_rapida_h != INVALID_HANDLE) IndicatorRelease(ema_rapida_h);
   if (ema_lenta_h!= INVALID_HANDLE) IndicatorRelease(ema_lenta_h);
}

void OnTick() {
   CopyBuffer(ema_lenta_h, 0, 1, 2, ema_lenta);
   CopyBuffer(ema_rapida_h, 0, 1, 2, ema_rapida);
   CopyBuffer(sar_h, 0, 0, 3, sar);
   
   trailing_stop();
   
   if (nueva_vela() && operacion_cerrada()) {
      if (cruce_compra()) {
         double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
         trade.Buy(0.1, _Symbol, Ask, Ask-SL*_Point, Ask+TP*_Point);
         trade_ticket = trade.ResultOrder();
      } else if (cruce_venta()) {
         double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
         trade.Sell(0.1, _Symbol, Bid, Bid+SL*_Point, Bid-TP*_Point);
         trade_ticket = trade.ResultOrder();
      }
   }
}
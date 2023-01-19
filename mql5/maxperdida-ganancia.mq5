#include <Trade/Trade.mqh>
CTrade trade;
ulong trade_ticket;


input int SECOND_TO_CLOSE = 58;           // Segundo de la vela en el que cerrar la operación


MqlRates velas[];

int dia = 0;
double profit = 0;
input double MAX_WIN = 100;   // Máximas ganancias
input double MAX_LOSS = 100;  // Máximas pérdidas


bool ganancias_perdidas_alcanzadas() {
   // Vemos si el día ha cambiado
   MqlDateTime time;
   TimeCurrent(time);
   if (time.day != dia) {
      // Actualizamos el día y reseteamos el profit
      dia = time.day;
      profit = 0;
   }
   
   return profit >= MAX_WIN || profit <= MAX_LOSS*-1;
}


bool es_boom() {
   return velas[0].open < velas[0].close;
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


void OnTick() {

   // Si se han alcanzado las ganancias o las pérdidas no hacemos nada
   if (ganancias_perdidas_alcanzadas()) return;

   CopyRates(_Symbol, _Period, 0, 1, velas);

   if (es_boom() && nueva_vela() && operacion_cerrada()) {
      double bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
      trade.Sell(0.1, _Symbol, bid);
      trade_ticket = trade.ResultOrder();
      
      // Obtenemos el segunddo actual en el que estamos
      MqlDateTime time;
      TimeCurrent(time);
      
      // Calculamos cuantos segundos han de pasar hasta cerrar la operación
      int seconds_until_close = SECOND_TO_CLOSE - time.sec;
      if (seconds_until_close <= 0) seconds_until_close += 60;
      
      // Establecemos el temporizador para cerrar operaciones
      EventSetTimer(seconds_until_close);
   }
}

void OnTimer() {
   trade.PositionClose(trade_ticket);
   EventKillTimer();
}
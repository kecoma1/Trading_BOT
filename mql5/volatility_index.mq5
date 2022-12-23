#include <Trade/Trade.mqh>
CTrade trade;


input int UMBRAL_PUNTOS = 10; // Umbral de puntos a superar
input int RITMO = 1;          // Cada cuantos segundos comprobamos el precio
input int TP = 30;            // Puntos hasta el TP
input int SL = 30;            // Puntos hasta el SL
input int DISTANCIA_TS = 15;  // Puntos entre el precio y el trailing stop


// Variables para guardar los precios a comparar
double precioAnterior = 0;
double precioActual = 0;

// Array donde guardar los closes
double closes[];


void trailing_stop() {
   for (int i = 0; i < PositionsTotal(); i++) {
      ulong ticket = PositionGetTicket(i);
      PositionSelectByTicket(ticket);
      
      double sl_anterior = PositionGetDouble(POSITION_SL);
      double tp = PositionGetDouble(POSITION_TP);
      double current_price = PositionGetDouble(POSITION_PRICE_CURRENT);
      if (current_price > sl_anterior+DISTANCIA_TS*_Point) {
         trade.PositionModify(ticket, current_price-DISTANCIA_TS*_Point, tp);
      }
   }
}


void OnInit() {
   // Inicializamos el array
   ArraySetAsSeries(closes, true);
   
   // Inicializamos los precios
   CopyClose(_Symbol, _Period, 0, 1, closes);
   precioActual = closes[0];
   precioAnterior = precioActual;
   
   // Inicializamos el temporizador
   EventSetTimer(RITMO);
}

void OnTick() {
   trailing_stop();
}

void OnTimer() {
   // Actualizamos los precios
   CopyClose(_Symbol, _Period, 0, 1, closes);
   precioAnterior = precioActual;
   precioActual = closes[0];

   // Guardamos cuanto se ha movido el precio en puntos
   double movimiento = (precioActual - precioAnterior)/_Point;

   // Si el precio se ha movido por encima del umbral abrimos una compra
   if (movimiento > UMBRAL_PUNTOS) {
      double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
      trade.Buy(0.1, _Symbol, Ask, Ask-SL*_Point, Ask+TP*_Point);
   }
}
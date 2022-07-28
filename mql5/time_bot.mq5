input int   HOUR   = 8;    // Hour
input int   MINUTE = 0;    // Minute

#include <Trade/Trade.mqh>
CTrade   trade;
ulong    trade_ticket = 0;

// Documentation of time:
// https://www.mql5.com/en/docs/dateandtime/timecurrent

// Documentación del tiempo:
// https://www.mql5.com/es/docs/dateandtime/timecurrent


void OnInit() {
   MqlDateTime time;
   TimeLocal(time);
   
   // Second way: Computing when how much time do we have left until the specified time
   // The most consistent way.
   
   // Segunda solución: Calculando cuanto tiempo nos queda hasta la hora especificada
   // El método más consistente.
   
   // Computing the seconds left until the time established
   // Calculando los segundos que quedan hasta la hora establecida
   int hours_left = time.hour <= HOUR ? HOUR - time.hour : 24 - (time.hour - HOUR);
   int minutes_left = time.min <= MINUTE ? MINUTE - time.min : 60 - (time.min - MINUTE);
   
   int seconds_left = hours_left*60*60 + minutes_left*60;
   
   EventSetTimer(seconds_left);
}

void OnTick() {
   /* REMOVE THIS LINE IF YOU WANT IT TO WORK - QUITA ESTA LÍNEA SI QUIERES QUE EL BOT FUNCIONE 
   MqlDateTime time;
   TimeLocal(time);
   
   // Reseting the trade ticket
   if (!PositionSelectByTicket(trade_ticket)) trade_ticket = 0;
   
   // First way: Checking time on every tick. We depend that there's a tick at the specified time
   // This is not the best way
   
   // Solución uno: Comprobar el tiempo en cada tick. Dependemos de que haya un tick en la hora específica
   // Esta no es la mejor forma
   if ((time.min == MINUTE || time.hour == HOUR) && trade_ticket == 0) {
       double bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
   
      trade.Sell(0.1, _Symbol, bid, bid+2000*_Point, bid-2000*_Point);
      trade_ticket = trade.ResultOrder();
   }
   REMOVE THIS LINE IF YOU WANT IT TO WORK - QUITA ESTA LÍNEA SI QUIERES QUE EL BOT FUNCIONE */
}

void OnTimer() {
   double bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
   
   trade.Sell(0.1, _Symbol, bid, bid+10000*_Point, bid-10000*_Point);
   trade_ticket = trade.ResultOrder();
   
   EventKillTimer();
   EventSetTimer(24*60*60);
}

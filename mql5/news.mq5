void OnInit() {
   // Eventos del euro
   MqlCalendarEvent eventos_euro[];
   int euro_count = CalendarEventByCurrency("EUR", eventos_euro);
   Print("Hay ", IntegerToString(euro_count), " eventos del euro.");
   
   // Mostramos la fecha de cada evento y su importancia
   for (int i = 0; i < euro_count; i++) {
      Print("Evento ", eventos_euro[i].name, " con importancia=", eventos_euro[i].importance);
      
      Print("Calendario:");
      MqlCalendarValue calendarios_eventos[];
      datetime desde = D'2022.01.01 00:00';
      if (CalendarValueHistoryByEvent(eventos_euro[i].id, calendarios_eventos, desde)) {
      
         // Recorremos todos los calendarios
         for (int n = 0; n < ArraySize(calendarios_eventos); n++) {
            Print("\tFecha: ", calendarios_eventos[n].time);
         }
         
      } else {
         Print("\tSin calendario");
      }
      Print("------------------------------------------------------------");
   }
}
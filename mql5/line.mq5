int MAX_CANDLES = 50;

MqlRates candles[];
double closes[];

bool line_created = false;

double avg_close_in_period(int start, int end) {
   double values = 0;
   for (int i = start; i < end; i++) values += closes[i];
   return values/(end-start);
}

int OnInit() {
   ArraySetAsSeries(candles, true);
   ArraySetAsSeries(closes, true);
   
   return INIT_SUCCEEDED;
}


void OnTick() {

   // Loading the candles
   CopyRates(_Symbol, _Period, 0, MAX_CANDLES, candles);

   // Getting all the closes
   CopyClose(_Symbol, _Period, 0, MAX_CANDLES, closes);
      
   double avg_first = avg_close_in_period(MAX_CANDLES/2, MAX_CANDLES);
   double avg_second = avg_close_in_period(0, MAX_CANDLES/2);
   
   Print(candles[MAX_CANDLES-1].time, " ", candles[0].time);
   
   // Setting the lines
   if (line_created == true) ObjectDelete(0, "line");
   else line_created = true;
   ObjectCreate(0, "line", OBJ_TREND, 0, candles[MAX_CANDLES-1].time, avg_first, candles[0].time, avg_second);
   
   // Setting the color
   ObjectSetInteger(0, "line", OBJPROP_COLOR, clrAqua);
   
   // Setting the width
   ObjectSetInteger(0, "line", OBJPROP_WIDTH, 4);
 }
#define SIZE 800
#define MARGIN 20
#define MARGIN_POINTS 500000*_Point
#define REQ_LOWS_FOR_SUPPORT 1

MqlRates candles[];

double lows[];

bool isMin(int index, double value) {
   int i = index >= MARGIN ? index - MARGIN : 0;
   int end = index + MARGIN > SIZE - 1 ? SIZE - 1 : index + MARGIN;
   
   for(; i < end; i++)
      if (candles[i].close < value) 
         return false;
   
   return true;
}

void findMins() {
   for(int i = 0; i < SIZE; i++) {
      if (isMin(i, candles[i].close)) {
         int size = ArraySize(lows);
         ArrayResize(lows, size+1);
         lows[size] = candles[i].close;
      }
   }
}

bool support_drawn(double value, double& lines_drawn[]) {
   int size = ArraySize(lines_drawn);
   
   if (size == 0) return false;
   
   for(int i = 0; i < size; i++)
      if (lines_drawn[i] + MARGIN_POINTS > value 
       && lines_drawn[i] - MARGIN_POINTS < value) return true;
       
   return false;
}

void draw_supports() {

   findMins();
   
   double val_lines_drawn[];

   for(int i = 0; i < ArraySize(lows); i++) {
      
      int lows_in = 0;
      
      for(int n = 0; n < ArraySize(lows); n++) {
         if (n == i) continue;
         else if (lows[i] + MARGIN_POINTS > lows[n] 
               && lows[i] - MARGIN_POINTS < lows[n]) lows_in++;
      }
      
      if (lows_in >= REQ_LOWS_FOR_SUPPORT) {
         if (!support_drawn(candles[i].close, val_lines_drawn)) {
            ObjectCreate(0, "support"+IntegerToString(ArraySize(val_lines_drawn)), OBJ_HLINE, 0, 0, candles[i].close);
            ObjectSetInteger(0, "support"+IntegerToString(ArraySize(val_lines_drawn)), OBJPROP_COLOR, clrRed);
            ObjectSetInteger(0, "support"+IntegerToString(ArraySize(val_lines_drawn)), OBJPROP_WIDTH, 4);
            
            int size = ArraySize(val_lines_drawn);
            ArrayResize(val_lines_drawn, size+1);
            val_lines_drawn[size] = candles[i].close; 
         }
      }
   }
}

void OnInit() {

   ArraySetAsSeries(candles, true);
   
   CopyRates(_Symbol, _Period, 0, SIZE, candles);
   
   draw_supports();
   
}
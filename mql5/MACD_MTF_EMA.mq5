#include <Trade/Trade.mqh>

/* Handlers */
int mtf_1h_h;
int mtf_15m_h;
int macd_h;

/* For storing indicator data */
double mtf_1h[];
double mtf_15m[];
double macd[];
double signal[];

/* Array for candles */
MqlRates candles[];
int MAX_CANDLES = 50;
int CANDLES_TO_CHECK = 3;

/* For operations */
CTrade trade;
ulong trade_ticket = 0;
bool time_passed = true;


/* =============================================================================== */
/* Functions to check if a close is a low or a high 
I'm basicaly checking the following:
In order to say that a point is a low, the 3 previous candles must have a smaller
value (also each of them with the next previous one). The same should happen with
the next 3 ones (each of them must have a bigger value than the previous one)
For example:
    ·      ·
      ·   ·
        o
Here all the dots are aligned and the one in the middle is a minimum.
But, for example:
         o
      ·      ·
    ·      ·
The point in the middle here would be considered a maximum although the next ones
aren't aligned.

What would definitively not be considered a maximum is this:
             ·
         o   
    · ·    ·
*/

bool is_low(int index) {
    for (int i = index-1; i > index-CANDLES_TO_CHECK && i >= 0; i--) // Checking the next candles
        if (candles[i].close > candles[index].close) return false;
    for (int i = index+1; i < index+CANDLES_TO_CHECK && i < MAX_CANDLES; i++) // Checking the previous candles
        if (candles[i].close < candles[index].close) return false;
    return true;
}

bool is_high(int index) {
    for (int i = index-1; i > index-CANDLES_TO_CHECK && i >= 0; i--) // Checking the next candles
        if (candles[i].close < candles[index].close) return false;
    for (int i = index+1; i < index+CANDLES_TO_CHECK && i < MAX_CANDLES; i++) // Checking the previous candles
        if (candles[i].close > candles[index].close) return false;
    return true;
}

/* =============================================================================== */
/* Indicator signals for buying and selling */

/* Multi time frame signals */
bool mtf_buy() { return mtf_1h[0] < mtf_15m[0]; }
bool mtf_sell() { return mtf_1h[0] > mtf_15m[0]; }

/* MACD signals cross */
bool macd_buy_cross(int cur) { 
   return macd[cur+1] < signal[cur+1] && macd[cur] > signal[cur]    // Cross
   && macd[0] < 0 && signal[0] < 0; }                               // Below 0
bool macd_sell_cross(int cur) { 
   return macd[cur+1] > signal[cur+1] && macd[cur] < signal[cur]    // Cross
   && macd[cur] > 0 && signal[cur] > 0; }                           // Above 0
   
/* MACD signals "divergence" */
bool macd_buy_divergence() {
   double cur_cross_value = signal[0];
   double last_cross_value = 0;
   bool sell_cross_between = false;
   for (int i = 1; i < MAX_CANDLES-1; i++) { // From i=1 because we skip the last cross
      if (macd[i] >= 0 || signal [i] >= 0) return false; // Checking if we touch the cero or we go above
      if (sell_cross_between && last_cross_value < cur_cross_value) return true; // Conditions are met
      
      // Looking for the previous buy cross
      if (macd_buy_cross(i)) {
         sell_cross_between = true;
         last_cross_value = signal[i];
      }
   }
   
   return false;
}

bool macd_sell_divergence() {
   double cur_cross_value = signal[0];
   double last_cross_value = 0;
   bool buy_cross_between = false;
   for (int i = 1; i < MAX_CANDLES-1; i++) { // From i=1 because we skip the last cross
      if (macd[i] <= 0 || signal [i] <= 0) return false; // Checking if we touch the cero or we go below
      if (buy_cross_between && last_cross_value > cur_cross_value) return true; // Conditions are met

      // Looking for the previous sell cross
      if (macd_sell_cross(i)) {
         buy_cross_between = true;
         last_cross_value = signal[i];
      }
   }

   return false;
}

/* Price "divergence" */
bool price_buy_divergence() {
    int num_of_lows = 0;
    double first_low = 0;
    double second_low = 0;
    for(int i = 1; i < MAX_CANDLES; i++) { 
        // Getting the lows
        if (is_low(i)) {
            num_of_lows += 1;
            if (num_of_lows == 1) first_low = candles[i].close;
            else if (num_of_lows == 2) second_low = candles[i].close;
        }

        // Checking the "divergence between the lows"
        if (num_of_lows >= 2 && first_low < second_low) return true;
    }

    return false;
}

bool price_sell_divergence() {
    int num_of_highs = 0;
    double first_high = 0;
    double second_high = 0;
    for(int i = 1; i < MAX_CANDLES; i++) { 
        // Getting the highs
        if (is_high(i)) {
            num_of_highs += 1;
            if (num_of_highs == 1) first_high = candles[i].close;
            else if (num_of_highs == 2) second_high = candles[i].close;
        }

        // Checking the "divergence between the highs"
        if (num_of_highs >= 2 && first_high < second_high) return true;
    }

    return false;
}

/* =============================================================================== */
/* Functions for getting the last high and the last low */

double last_high() {
   double high = 0;
   for (int i = 1; i < MAX_CANDLES; i++) 
      if (candles[i].high > high) high = candles[i].high;
   return high;
}

double last_low() {
   double low = candles[0].high;
   for (int i = 1; i < MAX_CANDLES; i++) 
      if (candles[i].low < low) low = candles[i].low;
   return low;
}

/* =============================================================================== */

int OnInit() {
   /* Setting the handlers */
   mtf_1h_h = iMA(_Symbol, PERIOD_H1, 50, 0, MODE_EMA, PRICE_CLOSE);
   mtf_15m_h = iMA(_Symbol, PERIOD_M15, 50, 0, MODE_EMA, PRICE_CLOSE);
   macd_h = iMACD(_Symbol, PERIOD_M5, 12, 26, 9, PRICE_CLOSE);
   
   /* Setting the arrays */
   ArraySetAsSeries(mtf_15m, true);
   ArraySetAsSeries(mtf_1h, true);
   ArraySetAsSeries(macd, true);
   ArraySetAsSeries(signal, true);

   return (INIT_SUCCEEDED);
}


void OnTick() {
   /* Taking the values of the indicators */
   CopyBuffer(mtf_1h_h, 0, 1, MAX_CANDLES, mtf_1h);
   CopyBuffer(mtf_15m_h, 0, 1, MAX_CANDLES, mtf_15m);
   CopyBuffer(macd_h, MAIN_LINE, 1, MAX_CANDLES, macd);
   CopyBuffer(macd_h, SIGNAL_LINE, 1, MAX_CANDLES, signal);
   
   /* Candles */
   CopyRates(_Symbol, _Period, 1, MAX_CANDLES, candles);
   
   /* Checking if there's an open operation */
   if (PositionSelectByTicket(trade_ticket) == false) trade_ticket = 0;
   
   /* Conditions for operations */
   if (mtf_buy() && macd_buy_cross(0) && macd_buy_divergence() && price_buy_divergence()
   && trade_ticket <= 0 && time_passed == true) {
      double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
      double sl = last_low()-20*_Point;
      double tp = Ask+((Ask-sl)*2);
      
      trade.Buy(0.1, _Symbol, Ask, sl, tp, NULL);
      trade_ticket = trade.ResultOrder();
      time_passed = false;
      
      EventSetTimer(PeriodSeconds(PERIOD_CURRENT)*10);
   } else if (mtf_sell() && macd_sell_cross(0) && macd_sell_divergence() && price_sell_divergence()
   && trade_ticket <= 0 && time_passed == true) {
      double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
      double sl = last_high()+20*_Point;
      double tp = Bid-((sl-Bid)*2);

      trade.Sell(0.1, _Symbol, Bid, sl, tp, NULL);
      trade_ticket = trade.ResultOrder();
      time_passed = false;
      
      EventSetTimer(PeriodSeconds(PERIOD_CURRENT)*10);
   }
}

void OnTimer() { time_passed = true; }

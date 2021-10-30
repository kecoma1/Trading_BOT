/* 15 minute, from 2017 to 2021 */

#include <Trade/Trade.mqh>

CTrade trade;
ulong trade_ticket = 0;
bool time_passed = true;

/* Handlers */
int stoch_h, rsi_h, macd_h;

/* Signal arrays */
double stoch0[], stoch1[], rsi[], macd[], signal[];

/* Candle array */
MqlRates price_information[];

int CANDLES_TO_USE = 10;
int CANDLES_TO_CHECK = 20; // For sl and tp

int OnInit() {
   /* Handlers */
   stoch_h = iStochastic(_Symbol, _Period, 5, 3, 3, MODE_SMA, STO_LOWHIGH);
   rsi_h = iRSI(_Symbol, _Period, 14, PRICE_CLOSE);
   macd_h = iMACD(_Symbol, _Period, 12, 26, 9, PRICE_CLOSE);
   
   /* Settings the arrays */
   ArraySetAsSeries(stoch0, true);
   ArraySetAsSeries(stoch1, true);
   ArraySetAsSeries(rsi, true);
   ArraySetAsSeries(macd, true);
   ArraySetAsSeries(signal, true);
   ArraySetAsSeries(price_information, true);
   
   return(INIT_SUCCEEDED);
}

void OnTick() {
   /* Loading indicator values */
   CopyBuffer(stoch_h, MAIN_LINE, 0, CANDLES_TO_USE, stoch0);
   CopyBuffer(stoch_h, SIGNAL_LINE, 0, CANDLES_TO_USE, stoch1);
   CopyBuffer(rsi_h, 0, 0, CANDLES_TO_USE, rsi);
   CopyBuffer(macd_h, MAIN_LINE, 0, CANDLES_TO_USE, macd);
   CopyBuffer(macd_h, SIGNAL_LINE, 0, CANDLES_TO_USE, signal);
   CopyRates(_Symbol, _Period, 0, CANDLES_TO_CHECK, price_information);
   
   /* This won't allow two open operations at the same time */
   if (PositionSelectByTicket(trade_ticket) == false) trade_ticket = 0;
   
   /* Buy? */
   if (trade_ticket == 0 && time_passed
       && stoch_was_oversold()         // Both stochastic lines were in oversold
       && rsi_buy_signal()          // Current rsi is in buy
       && !stoch_was_overbought()   // The stochastic have not hit the overbought
       && macd_was_buy()) {         // There was a macd cross
       
      /* Current price */
      double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
      
      //--- Open Buy
      double sl = nearest_low();
      double tp = Ask +(Ask-sl)*1.5;
      
      if (Ask-sl < 150*_Point && Ask-sl > 50*_Point) {
         trade.Buy(0.1, _Symbol, Ask, sl, tp, NULL);
         trade_ticket = trade.ResultOrder();
         
         /* We don't allow a second trade in the same candle */
         EventSetTimer(PeriodSeconds(_Period)*2);
         time_passed = false;
      }

   } /* Sell? */
   else if (trade_ticket == 0 && time_passed
            && stoch_was_overbought()     // Stochastic lines were in overbough
            && rsi_sell_signal()       // Current rsi is in sell
            && !stoch_was_oversold()   // Stochastic have not hit the oversold
            && macd_was_sell()) {      // There was a macd cross;

      /* Current price */
      double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
      
      //--- Open Sell
      double sl = nearest_high();
      double tp = Bid - (sl-Bid)*1.5;
      
      if (sl-Bid < 150*_Point && sl-Bid > 50*_Point) {
         trade.Sell(0.1, _Symbol, Bid, sl, tp, NULL);
         trade_ticket = trade.ResultOrder();
         
         /* We don't allow a second trade in the same candle */
         EventSetTimer(PeriodSeconds(_Period)*2);
         time_passed = false;
      }
   }
   
}

void OnTimer() {
   time_passed = true;
}

/**** Private functions ****/

bool stoch_was_overbought() {
   for (int i = 0; i < CANDLES_TO_USE; i++)
      if (stoch0[i] > 80 && stoch1[i] > 80) return true;
   
   return false;
}

bool stoch_was_oversold() {
   for (int i = 0; i < CANDLES_TO_USE; i++)
      if (stoch0[i] < 20 && stoch1[i] < 20) return true;
   
   return false;
}

bool rsi_buy_signal() {
   return rsi[0] > 50;
}

bool rsi_sell_signal() {
   return rsi[0] < 50;
}

bool macd_was_buy() {
   for (int i = CANDLES_TO_USE-1; i > 1; i--)
      if (macd[i] < signal[i] && macd[i-1] > signal[i-1]) return true;
      
   return false;
}

bool macd_was_sell() {
   for (int i = CANDLES_TO_USE-1; i > 1; i--)
      if (macd[i] > signal[i] && macd[i-1] < signal[i-1]) return true;
      
   return false;
}

double nearest_high() {
   int i = 0;
   double high = 0;
   
   for (i = 0; i < CANDLES_TO_CHECK; i++)
      if (high < price_information[i].close) high = price_information[i].close;
   
   return high;
}

double nearest_low() {
   int i = 0;
   double low = 100000;
   
   for (i = 0; i < CANDLES_TO_CHECK; i++)
      if (low > price_information[i].close) low = price_information[i].close;
   
   return low;
}
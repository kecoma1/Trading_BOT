/* Dynamic lotage. Depending on the balance the operations contain
one lotage or another. */

#include <Trade/Trade.mqh>

/* Handlers */
int rsi_h;
int macd_h;
int stoch_h;

/* Arrays for the indicators */
double rsi[];

double macd_main[];
double macd_signal[];

double stoch_main[];
double stoch_signal[];

/* Array for candles */
MqlRates candles[];
int MAX_CANDLES = 15;

/* For operations */
CTrade trade;
ulong trade_ticket = 0;
bool time_passed = true;
double goal_price = 0;
double next_sl = 0;

/* =============================================================================== */

/* 1000 EUR == 0.05 Lots */
double get_lotage() {
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   
   return NormalizeDouble((balance/1000)*0.05, 2);
}

/* =============================================================================== */

double last_high() {
   double high = 0;
   for (int i = 1; i < MAX_CANDLES; i++) 
      if (candles[i].high > high) high = candles[i].high;
   return high;
}

double last_min() {
   double min = candles[0].high;
   for (int i = 1; i < MAX_CANDLES; i++) 
      if (candles[i].low < min) min = candles[i].low;
   return min;
}

/* =============================================================================== */

bool rsi_buy() { return rsi[0] > 50.0; } // && rsi[0] < 70
bool rsi_sell() { return rsi[0] < 50.0; } // && rsi[0] > 30


bool macd_buy() { return macd_main[1] < macd_signal[1] && macd_main[0] > macd_signal[0] && macd_main[0] < 0 && macd_signal[0] < 0; }
bool macd_sell() { return macd_main[1] > macd_signal[1] && macd_main[0] < macd_signal[0] && macd_main[0] > 0 && macd_signal[0] > 0; }

bool stoch_buy() { return stoch_main[0] > 25 && stoch_signal[0] > 25; } // && stoch_main[0] < 50 && stoch_signal[0] < 50
bool stoch_sell() { return stoch_main[0] < 75 && stoch_signal[0] < 75; } // && stoch_main[0] > 50 && stoch_signal[0] > 50

/* =============================================================================== */

bool rsi_overbought() { return rsi[0] > 70; }
bool rsi_oversold() { return rsi[0] < 30; }

bool stoch_overbought() { return stoch_main[0] > 75 && stoch_signal[0] > 75; }
bool stoch_oversold() { return stoch_main[0] < 25 && stoch_signal[0] < 25; }

/* =============================================================================== */

int OnInit() {
   /* Setting the handlers */
   rsi_h = iRSI(_Symbol, _Period, 14, PRICE_CLOSE);
   macd_h = iMACD(_Symbol, _Period, 8, 21, 5, PRICE_CLOSE);
   stoch_h = iStochastic(_Symbol, _Period, 14, 3, 3, MODE_SMA, STO_LOWHIGH);
   
   /* Setting the arrays */
   ArraySetAsSeries(rsi, true);
   ArraySetAsSeries(macd_main, true);
   ArraySetAsSeries(macd_signal, true);
   ArraySetAsSeries(stoch_main, true);
   ArraySetAsSeries(stoch_signal, true);

   return (INIT_SUCCEEDED);
}

void OnTick() {
   /* Taking the values of the indicators */
   CopyBuffer(rsi_h, 0, 0, 3, rsi);
   CopyBuffer(macd_h, MAIN_LINE, 1, 3, macd_main);
   CopyBuffer(macd_h, SIGNAL_LINE, 1, 3, macd_signal);
   CopyBuffer(stoch_h, MAIN_LINE, 1, 3, stoch_main);
   CopyBuffer(stoch_h, SIGNAL_LINE, 1, 3, stoch_signal);
   
   /* Candles */
   CopyRates(_Symbol, _Period, 1, MAX_CANDLES, candles);
   
   /* Checking if there's an open operation */
   if (PositionSelectByTicket(trade_ticket) == false) trade_ticket = 0;
   else {
      /* Checking if we have to close the position */
      ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      
      if ((type == POSITION_TYPE_BUY && rsi_overbought() && stoch_overbought())
      ||  (type == POSITION_TYPE_SELL && rsi_oversold() && stoch_oversold())) {
         trade.PositionClose(trade_ticket);
         trade_ticket = 0;
      } else {
         double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
         double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
         
         /* If we reach a 1.75 sl we put the stop loss at 1.1 sl */
         if (type == POSITION_TYPE_BUY && Bid >= goal_price) {
            trade.PositionModify(trade_ticket, next_sl, 0);

            double distance = goal_price-next_sl;
            next_sl += distance;
            goal_price += distance;
            
         } else if (Ask <= goal_price && type == POSITION_TYPE_SELL) {
            trade.PositionModify(trade_ticket, next_sl, 0);
            
            double distance = next_sl-goal_price;
            next_sl -= distance;
            goal_price -= distance;
         }
      }
   }
   
   /* Conditions for operations */
   if (macd_buy() && rsi_buy() && stoch_buy() && trade_ticket <= 0 && time_passed == true) {
      double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
      double sl = last_min();
      
      goal_price = Ask+((Ask-sl)*1.75);
      next_sl = Ask+((Ask-sl)*1.1);
      
      trade.Buy(get_lotage(), _Symbol, Ask, sl, 0, NULL);
      trade_ticket = trade.ResultOrder();
      time_passed = false;
      
      EventSetTimer(PeriodSeconds(PERIOD_CURRENT)*10);
   } else if (macd_sell() && rsi_sell() && stoch_sell() && trade_ticket <= 0 && time_passed == true) {
      double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
      double sl = last_high();
      
      goal_price = Bid-((sl-Bid)*1.75);
      next_sl = Bid-((sl-Bid)*1.1);
      
      trade.Sell(get_lotage(), _Symbol, Bid, sl, 0, NULL);
      trade_ticket = trade.ResultOrder();
      time_passed = false;
      
      EventSetTimer(PeriodSeconds(PERIOD_CURRENT)*10);
   }
}

void OnTimer() { time_passed = true; }
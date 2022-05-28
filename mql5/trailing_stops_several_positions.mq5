#define TOP_RSI_LEVEL 65
#define SL 5000*_Point
#define TP SL*3

/* For the trailling stop */
#define SL_MARGIN 2000*_Point

/* For openning operations */ 
#include <Trade/Trade.mqh>
CTrade trade;
bool time_flag = true;

/* Array of candles */
MqlRates candles[];

/* For the rsi */
int rsi_h;
double rsi[];

bool is_rsi_above_top() { return rsi[0] > TOP_RSI_LEVEL; }


/* TRAILING STOP IMPLEMENTATION STARTS HERE */
void trailing_stop(ulong ticket) {
   double open = PositionGetDouble(POSITION_PRICE_OPEN);
   double cur_sl = PositionGetDouble(POSITION_SL);
   double cur_price = candles[0].close;
   
   if (cur_sl - SL_MARGIN > cur_price)
      trade.PositionModify(ticket, cur_price+SL_MARGIN, 0);
}

void trailing_stop_all() {
   for(int i = 0; i < PositionsTotal(); i++) {
      ulong trade_ticket = PositionGetTicket(i);
      
      trailing_stop(trade_ticket);
   }
}
/* TRAILING STOP IMPLEMENTATION ENDS HERE */


void OnInit() {
   rsi_h = iRSI(_Symbol, _Period, 14, PRICE_CLOSE);

   ArraySetAsSeries(candles, true);
}

void OnTick() {
   CopyRates(_Symbol, _Period, 0, 3, candles);
   CopyBuffer(rsi_h, 0, 1, 3, rsi);
   
   /* CALL TO THE METHOD */
   trailing_stop_all();
   
   if (is_rsi_above_top() && time_flag) {
   
      double bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
   
      trade.Sell(0.1, _Symbol, bid, bid+SL, bid-TP);
      
      time_flag = false;
      EventSetTimer(PeriodSeconds());
   }
}

void OnTimer() { 
   time_flag = true;
   EventKillTimer();
}
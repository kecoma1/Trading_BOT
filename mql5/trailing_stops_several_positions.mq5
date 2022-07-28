#define TOP_RSI_LEVEL 55
#define SL 5000*_Point
#define TP SL*3

#define MARGIN_SL 2000*_Point

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

void trailing_stop(ulong ticket) {
   double cur_sl = PositionGetDouble(POSITION_SL);
   double cur_price = candles[0].close;
   
   if (cur_sl - MARGIN_SL > cur_price)
      trade.PositionModify(ticket, cur_price+MARGIN_SL, 0);
}

void trailing_stop_all() {
   for(int i = 0; i < PositionsTotal(); i++) {
      ulong ticket = PositionGetTicket(i);
      PositionGetSymbol(i);
	   PositionSelectByTicket(ticket);
      
      trailing_stop(ticket);
   }
}

void OnInit() {
   rsi_h = iRSI(_Symbol, _Period, 14, PRICE_CLOSE);

   ArraySetAsSeries(candles, true);
}

void OnTick() {
   CopyRates(_Symbol, _Period, 0, 3, candles);
   CopyBuffer(rsi_h, 0, 1, 3, rsi);
   
   trailing_stop_all();
   
   if (is_rsi_above_top() && time_flag) {
   
      double bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
   
      trade.Sell(0.1, _Symbol, bid, bid+SL);
      
      time_flag = false;
      EventSetTimer(PeriodSeconds());
   }
}

void OnTimer() { 
   time_flag = true;
   EventKillTimer();
}

#include <Trade/Trade.mqh>

int rsi_h;

double rsi[];

CTrade trade;
ulong trade_ticket = 0;
bool time_passed = true;

int OnInit() {
   rsi_h = iRSI(_Symbol, _Period, 14, PRICE_CLOSE);
   ArraySetAsSeries(rsi, true);
   return (INIT_SUCCEEDED);
}

void OnTick() {
   CopyBuffer(rsi_h, 0, 1, 3, rsi);
   
   if (PositionSelectByTicket(trade_ticket) == false) trade_ticket = 0;

   if (rsi[0] < 30 && trade_ticket <= 0 && time_passed == true) { // compras
      double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
      
      trade.Buy(0.1, _Symbol, Ask, Ask-40*_Point, Ask+80*_Point, NULL);
      trade_ticket = trade.ResultOrder();
      time_passed = false;
      
      EventSetTimer(PeriodSeconds(PERIOD_CURRENT)*15);
   } else if (rsi[0] > 70 && trade_ticket <= 0 && time_passed == true) { // Ventas
      double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
      
      trade.Sell(0.1, _Symbol, Bid, Bid+40*_Point, Bid-80*_Point, NULL);
      trade_ticket = trade.ResultOrder();
      time_passed = false;
      
      EventSetTimer(PeriodSeconds(PERIOD_CURRENT)*15);
   }
}

void OnTimer() {
   time_passed = true;
}
#include <Trade/Trade.mqh>
CTrade trade;
ulong trade_ticket = 0;

void OnInit() {
   double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
      
   trade.Sell(1, _Symbol, Bid, Bid+100000*_Point, Bid-100000*_Point);
   trade_ticket = trade.ResultOrder();
}

void OnTick() {
   if (trade_ticket != 0) {
      trade.PositionClosePartial(trade_ticket, 0.2);
      trade_ticket = 0;
   }
}
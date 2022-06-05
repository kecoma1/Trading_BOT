#include <Trade/Trade.mqh>
CTrade trade;
ulong trade_ticket = 0;

MqlRates candles[];

bool time_flag = true;

int multiplier = 1;

double get_lotage() {

   HistorySelect(TimeCurrent()-(12*60*60), TimeCurrent());
   
   ulong prev_trade_ticket = HistoryDealGetTicket(HistoryDealsTotal()-1);
   double profit = HistoryDealGetDouble(prev_trade_ticket, DEAL_PROFIT);
   
   if (profit < 0) multiplier *= 5; 
   else multiplier = 1;

   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double lotage = NormalizeDouble((balance/1000)*0.01*multiplier, 2);
   return lotage <= 50 ? lotage : 50;
}

void OnInit() {
   ArraySetAsSeries(candles, true);
}

bool alcista(int pos, double len=0) {
   return candles[pos].close-candles[pos].open > len;
}

void OnTick() {
   CopyRates(_Symbol, _Period, 0, 3, candles);
   
   if (PositionSelectByTicket(trade_ticket) == false) trade_ticket = 0;
   
   if (alcista(1) && !alcista(0) && trade_ticket <= 0) {
   
      double bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
   
      trade.Sell(get_lotage(), _Symbol, bid, bid+2000*_Point, bid-2000*_Point);
      trade_ticket = trade.ResultOrder();
   }
}
#include <Trade/Trade.mqh>
CTrade trade;

/* Moving average handlers */
int ma_15_h = 0;
int ma_9_h = 0;

ulong trade_ticket = 0;
bool time_passed = true;

double ma_15_array[];
double ma_9_array[];

int OnInit() {

   ma_15_h = iMA(_Symbol, _Period, 15, 0, MODE_SMA, PRICE_CLOSE);
   ma_9_h = iMA(_Symbol, _Period, 9, 0, MODE_SMA, PRICE_CLOSE);

   return(INIT_SUCCEEDED);
}

  
 
void OnTick() {
   CopyBuffer(ma_15_h, 0, 1, 3, ma_15_array);
   CopyBuffer(ma_9_h, 0, 1, 3, ma_9_array);
   
   if (PositionSelectByTicket(trade_ticket) == false) {
      trade_ticket = false;
   }
   
   if (trade_ticket <= 0 && ma_9_array[1] > ma_15_array[1] && ma_9_array[0] < ma_15_array[0] && time_passed == true) {
      double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);   
      
      trade.Buy(0.01, _Symbol, Ask, Ask-20*_Point, Ask+60*_Point, NULL);
      trade_ticket = trade.ResultOrder();
      time_passed = false;
      
      EventSetTimer(60*30*5);   
   } else if (trade_ticket <= 0 && ma_9_array[1] < ma_15_array[1] && ma_9_array[0] > ma_15_array[0] && time_passed == true) {
      double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
      
      trade.Sell(0.01, _Symbol, Bid, Bid+20*_Point, Bid-60*_Point, NULL);
      trade_ticket = trade.ResultOrder();
      time_passed = false;
      
      EventSetTimer(60*30*5);
   }
}

void OnTimer() {
   time_passed = true;
}
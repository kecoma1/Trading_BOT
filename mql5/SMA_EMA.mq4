#include <Trade/Trade.mqh>

int ema_h;
int ma_h;

double ema_array[];
double ma_array[];

double price_flag = 0;
ulong trade_ticket;

bool operacion_abierta = false;

int time_passed = 1;

CTrade trade;

/* TS and TP */
int TS = 530; // Trailing stop
int MARGIN = 30; // Margin
int TP = 600; // Take profit
int SL = 200; // Stop loss

void handle_trade(ulong t_ticket) {
   ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
   
   double new_sl = 0, new_tp = 0;
   double cur_price = PositionGetDouble(POSITION_PRICE_CURRENT);
  
   /* Modifying the stop loss during the ticks */
   if (type == POSITION_TYPE_BUY && cur_price > price_flag) {
      price_flag += 20*_Point;
      new_tp = cur_price+MARGIN*_Point;
      new_sl = cur_price-MARGIN*_Point*3;
      trade.PositionModify(trade_ticket, new_sl, new_tp);
   } else if (type == POSITION_TYPE_SELL && cur_price < price_flag) {
      price_flag -= 20*_Point;
      new_tp = cur_price-MARGIN*_Point;
      new_sl = cur_price+MARGIN*_Point*3;
      trade.PositionModify(trade_ticket, new_sl, new_tp);
   }
}

int OnInit() {

   ema_h = iMA(_Symbol, _Period, 9, 0, MODE_EMA, PRICE_CLOSE);
   ma_h = iMA(_Symbol, _Period, 18, 0, MODE_SMA, PRICE_CLOSE);
   
   return(INIT_SUCCEEDED);
}

bool up_trend(int handler) {
   double n = 0, array[];
   ArraySetAsSeries(array, true);
   CopyBuffer(handler, 0, 0, 35, array);

   for(int i=34;i>0;i--)
      n += array[i]-array[i-1];
   
   Print("up ", n);
   return n > 0.01;
}

bool down_trend(int handler) {
   double n = 0, array[];
   ArraySetAsSeries(array, true);
   CopyBuffer(handler, 0, 0, 35, array);

   for(int i=34;i>0;i--)
      n += array[i]-array[i-1];
   
   Print("down ", n);
   return n < -0.01;
}

void OnTick() {
   CopyBuffer(ema_h, 0, 0, 4, ema_array);
   CopyBuffer(ma_h, 0, 0, 4, ma_array);
   
   if (PositionSelectByTicket(trade_ticket) == false) {
      operacion_abierta = false;
   } else {
      //handle_trade(trade_ticket);
   }
   
   /* Compra? */
   if (ma_array[2] < ema_array[2] 
   && ma_array[1] > ema_array[1] 
   && operacion_abierta == false 
   && up_trend(ma_h) == true) {
      /* Current price */
      double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
      
      trade.Buy(3, _Symbol, Ask, Ask-200*_Point, Ask+600*_Point, NULL);
      trade_ticket = trade.ResultOrder();
      operacion_abierta = true;
      price_flag = Ask+450*_Point;
      
      EventSetTimer(60*60*4*3);
   } else if (ma_array[3] > ema_array[3] 
   && ma_array[2] < ema_array[2] 
   && operacion_abierta == false 
   && down_trend(ma_h) == true) {
      /* Current price */
      double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
      
      trade.Sell(3, _Symbol, Bid, Bid+200*_Point, Bid-600*_Point, NULL);
      trade_ticket = trade.ResultOrder();
      operacion_abierta = true;
      price_flag = Bid-450*_Point;
      
      EventSetTimer(60*60*4*3);
   }
}

void OnTimer() {
   time_passed = 1;
}
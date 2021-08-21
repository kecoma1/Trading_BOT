#include <Trade/Trade.mqh>

int ema_h;
int ma_h;

double ema_array[];
double ma_array[];

ulong compra_ticket;
ulong venta_ticket;

bool compra_abierta = false;
bool venta_abierta = false;

int time_passed = 1;

CTrade trade;

int OnInit() {

   ema_h = iMA(_Symbol, _Period, 9, 0, MODE_EMA, PRICE_CLOSE);
   ma_h = iMA(_Symbol, _Period, 18, 0, MODE_SMA, PRICE_CLOSE);
   
   return(INIT_SUCCEEDED);
}

void OnTick() {
   CopyBuffer(ema_h, 0, 0, 4, ema_array);
   CopyBuffer(ma_h, 0, 0, 4, ma_array);
   
   if (PositionSelectByTicket(compra_ticket) == false) {
      compra_abierta = false;
   }
   if (PositionSelectByTicket(venta_ticket) == false) {
      venta_abierta = false;
   }
   
   /* Compra? */
   if (ma_array[2] < ema_array[2] && ma_array[1] > ema_array[1] && compra_abierta == false) {
      //--- Abrir compra
      /* Current price */
      double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
      
      trade.Buy(1, _Symbol, Ask, Ask-200*_Point, Ask+600*_Point, NULL);
      compra_ticket = trade.ResultOrder();
      compra_abierta = true;
      time_passed = 0;
      EventSetTimer(60*60*4*10);
   } else if (ma_array[3] > ema_array[3] && ma_array[2] < ema_array[2] && venta_abierta == false) {
      /* Current price */
      double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
      
      trade.Sell(1, _Symbol, Bid, Bid+200*_Point, Bid-600*_Point, NULL);
      venta_ticket = trade.ResultOrder();
      venta_abierta = true;
      time_passed = 0;
      EventSetTimer(60*60*4*3);
   }
}

void OnTimer() {
   time_passed = 1;
}
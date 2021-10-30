/* sl: 100 points, tp: 150 points, period: 15 min, from 2017 to 2021 */
#include <Trade/Trade.mqh>

/* Manejadores */
int MACD_h;
int EMA_h;

/* Arrays con los datos */
double MACD[];
double SIGNAL[];
double EMA[];

/* Array con las velas */
MqlRates PriceInformation[];

/* Para el trailing stop */
int TS = 150;
int TS_MARGIN = 10;
double price_flag = 0;

/* Para operaciones */
CTrade trade;
ulong trade_ticket = 0;
bool time_passed = true;

void handle_trade(ulong t_ticket) {
   ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
   
   double new_sl = 0;
   double cur_price = PositionGetDouble(POSITION_PRICE_CURRENT);
  
   /* Modifying the stop loss during the ticks */
   if (type == POSITION_TYPE_BUY && cur_price > price_flag) {
      price_flag = cur_price + 1*_Point;
      new_sl = cur_price-TS_MARGIN*_Point;
      trade.PositionModify(trade_ticket, new_sl, 0);
   } else if (type == POSITION_TYPE_SELL && cur_price < price_flag) {
      price_flag = cur_price - 1*_Point;
      new_sl = cur_price+TS_MARGIN*_Point;
      trade.PositionModify(trade_ticket, new_sl, 0);
   }
}

int OnInit() {
   /* Inicializando los manejadores */
   MACD_h = iMACD(_Symbol, _Period, 12, 26, 9, PRICE_CLOSE);
   EMA_h = iMA(_Symbol, _Period, 100, 0, MODE_EMA, PRICE_CLOSE);
   
   ArraySetAsSeries(MACD, true);
   ArraySetAsSeries(SIGNAL, true);
   ArraySetAsSeries(EMA, true);

   return(INIT_SUCCEEDED);
}


void OnTick() {
   /* Guardamos los datos de los indicadores */
   CopyBuffer(MACD_h, 0, 0, 4, MACD);
   CopyBuffer(MACD_h, 1, 0, 4, SIGNAL);
   CopyBuffer(EMA_h, 0, 0, 4, EMA);
   
   /* Velas */
   CopyRates(_Symbol, _Period, 0, 4, PriceInformation);
   
   /* Checking if there's an open operation */
   if (PositionSelectByTicket(trade_ticket) == true) {
      handle_trade(trade_ticket);
   } else {
      // Reseting the trade flags
      trade_ticket = 0;
      price_flag = 0;
   }
   
   
   if ( // compra
      MACD[2] < SIGNAL[2] && MACD[1] > SIGNAL[1]      // Se cruzan MACD y SIGNAL
      && MACD[0] < 0 && SIGNAL[0] < 0                 // MACD and SIGNAL son < 0
      && PriceInformation[0].close > EMA[0]           // El precio está por encima de la EMA  
      && trade_ticket <= 0 && time_passed == true
      ) {
      /* Precio actual */
      double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
      
      //--- Abrir compra
      trade.Buy(0.1, _Symbol, Ask, Ask-100*_Point, 0, NULL);
      trade_ticket = trade.ResultOrder();

      price_flag = Ask+TS*_Point; // Trailing stop
      time_passed = false;
      
      EventSetTimer(60*60*2*4);
      
   } else if ( // venta
   MACD[2] > SIGNAL[2] && MACD[1] <  SIGNAL[1]      // Se cruzan MACD y SIGNAL
   && MACD[0] > 0 && SIGNAL[0] > 0                 // MACD and SIGNAL son > 0
   && PriceInformation[0].close < EMA[0]           // El precio está por debajo de la EMA  
   && trade_ticket <= 0 && time_passed == true
   ) {
      /* Precio actual */
      double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
      
      //--- Abrir venta      
      trade.Sell(0.1, _Symbol, Bid, Bid+100*_Point, 0, NULL);
      trade_ticket = trade.ResultOrder();
      
      price_flag = Bid-TS*_Point; // Trailing stop
      time_passed = false;
      
      EventSetTimer(60*60*2*4);
   }
}

void OnTimer() {
   time_passed = true;
}


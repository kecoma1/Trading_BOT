#include <Trade/Trade.mqh>


/******** Index: 0 Current value, 1 previous value, 2... ********/


/* Moving averages variables */
int smoothed_MA_200_h;
int smoothed_MA_50_h;
int smoothed_MA_21_h;
double smoothed_MA_200_array[];
double smoothed_MA_50_array[];
double smoothed_MA_21_array[];

/* RSI variables */
int RSI_h;
double RSI_array[];

/* Fractals variables */
int Fractals_h;
double upper_fractals_array[];
double lower_fractals_array[];

/* Variables for handling trades */
CTrade trade;
ulong trade_ticket = 0;
bool time_passed = true;
double price_flag = false;
int TS_MARGIN = 10;
double first_sl = 0;

/* Array with the close price of the previous candles */
MqlRates PriceInformation[];

/* TS and TP */
int TS = 75; // Trailing stop
int S_TS = 50; // Seconds trailing stop
int TP = 100; // Take profit
int S_SL = 30; // Second stop loss (after setting the trailing stop)


void handle_trade(ulong t_ticket) {
   ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
   
   double new_sl = 0, new_tp = 0;
   double cur_price = PositionGetDouble(POSITION_PRICE_CURRENT);
  
   /* Modifying the stop loss during the ticks */
   if (type == POSITION_TYPE_BUY && cur_price > price_flag) {
      price_flag += TS*_Point;
      new_tp = cur_price+S_TS*_Point;
      new_sl = cur_price-S_SL*_Point;
      trade.PositionModify(trade_ticket, new_sl, new_tp);
      first_sl = new_sl;
   } else if (type == POSITION_TYPE_SELL && cur_price < price_flag) {
      price_flag -= TS*_Point;
      new_tp = cur_price-S_TS*_Point;
      new_sl = cur_price+S_TS*_Point;
      trade.PositionModify(trade_ticket, new_sl, new_tp);
      first_sl = new_sl;
   }
}


int OnInit() {
   /* Setting the moving averages handlers */
   smoothed_MA_200_h = iMA(_Symbol, _Period, 200, 0, MODE_SMMA, PRICE_CLOSE);
   smoothed_MA_50_h = iMA(_Symbol, _Period, 50, 0, MODE_SMMA, PRICE_CLOSE);
   smoothed_MA_21_h = iMA(_Symbol, _Period, 21, 0, MODE_SMMA, PRICE_CLOSE);
   
   /* Setting the RSI handler */
   RSI_h = iRSI(_Symbol, _Period, 14, PRICE_CLOSE);
   
   /* Setting the Fractals handler */
   Fractals_h = iFractals(_Symbol, _Period);
   
   /* Setting the arrays */
   ArraySetAsSeries(smoothed_MA_200_array, true);
   ArraySetAsSeries(smoothed_MA_50_array, true);
   ArraySetAsSeries(smoothed_MA_21_array, true);
   ArraySetAsSeries(upper_fractals_array, true);
   ArraySetAsSeries(lower_fractals_array, true);
   ArraySetAsSeries(RSI_array, true);
   
   /* Setting the array with the close price of the previous candles */
   ArraySetAsSeries(PriceInformation, true);
   
   return(INIT_SUCCEEDED);
}

void OnTick() {
   /* Storing the value of the averages */
   CopyBuffer(smoothed_MA_200_h, 0, 0, 3, smoothed_MA_200_array);
   CopyBuffer(smoothed_MA_50_h, 0, 0, 3, smoothed_MA_50_array);
   CopyBuffer(smoothed_MA_21_h, 0, 0, 3, smoothed_MA_21_array);

   /* Storing the value of the RSI */
   CopyBuffer(RSI_h, 0, 0, 3, RSI_array);
   
   /* Storing the values of the Fractals */
   CopyBuffer(Fractals_h, UPPER_LINE, 0, 3, upper_fractals_array);
   CopyBuffer(Fractals_h, LOWER_LINE, 0, 3, lower_fractals_array);
   
   /* Storing the close prices */
   CopyRates(_Symbol, _Period, 0, 3, PriceInformation);
   
   if (upper_fractals_array[1] == EMPTY_VALUE) upper_fractals_array[1] = 0;
   if (lower_fractals_array[1] == EMPTY_VALUE) lower_fractals_array[1] = 0;
   
   /* Checking if there's an open operation */
   if (PositionSelectByTicket(trade_ticket) == true) {
      handle_trade(trade_ticket);
   } else {
      // Reseting the trade flags
      trade_ticket = 0;
      price_flag = 0;
   }
   
   /* Buy? */
   if (lower_fractals_array[1] != 0                               // We have a fractal signal
       && RSI_array[1] > 50                                       // RSI Bigger than 50
       && smoothed_MA_200_array[1] < smoothed_MA_50_array[1]      // 200 SMMA below 50 SMMA
       && smoothed_MA_50_array[1] < smoothed_MA_21_array[1]) {    // 50 SMMA below 21 SMMA
      
      /* Current price */
      double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
      
      //--- Open Buy
      first_sl = PriceInformation[1].low - 10*_Point;
      
      trade.Buy(0.1, _Symbol, Ask, first_sl, Ask+100*_Point, NULL);
      trade_ticket = trade.ResultOrder();
      price_flag = Ask+TS*_Point; // Trailing stop
 
      time_passed = false;
      EventSetTimer(60*180);
   } /* Sell? */ else if (upper_fractals_array[1] != 0            // We have a fractal signal
       && RSI_array[1] < 50                                       // RSI Bigger than 50
       && smoothed_MA_200_array[1] > smoothed_MA_50_array[1]      // 200 SMMA below 50 SMMA
       && smoothed_MA_50_array[1] > smoothed_MA_21_array[1]) {    // 50 SMMA below 21 SMMA
       
      /* Current price */
      double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
      
      //--- Open Sell
      first_sl = PriceInformation[1].high + 10*_Point;
      
      trade.Sell(0.1, _Symbol, Bid, first_sl, Bid-100*_Point, NULL);
      trade_ticket = trade.ResultOrder();
      price_flag = Bid-TS*_Point; // Trailing stop
      
      time_passed = false;
      EventSetTimer(60*180);
   }
}

void OnTimer() {
   if (PositionSelectByTicket(trade_ticket) == false) {
      // Reseting the trade flags
      time_passed = 1;
      price_flag = 0;
   }
}

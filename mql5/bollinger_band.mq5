#include <Trade/Trade.mqh>

int BBHandle; // Bollinger bands handler
int SMAHandle; // Simple moving average handler
int SMA200Handle; // Simple moving average handler

/* Variables for handling trades */
CTrade trade;
ulong trade_ticket = 0;
bool time_passed = true;
double price_flag = false;
int TS_MARGIN = 10;
double first_sl = 0;

/* Index: 0 Current value, 1 previous value, 2... */
/* Arrays for the values of the bollinger bands */
double upperBandArray[];
double lowerBandArray[];
double bbMa[];

/* Array for the values of the SMA */
double smaArray[];
double sma200Array[];

/* Index: 0 Current value, 1 previous value, 2... */
/* Array with the close price of the previous candles */
MqlRates PriceInformation[];


void handle_trade(ulong t_ticket) {
   ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
   
   double new_sl = 0, new_tp = 0;
   double cur_price = PositionGetDouble(POSITION_PRICE_CURRENT);
  
   /* Modifying the stop loss during the ticks */
   if (type == POSITION_TYPE_BUY && cur_price > price_flag) {
      price_flag += 1*_Point;
      new_tp = cur_price+TS_MARGIN*_Point;
      new_sl = cur_price-TS_MARGIN*_Point;
      trade.PositionModify(trade_ticket, new_sl, new_tp);
      first_sl = new_sl;
   } else if (type == POSITION_TYPE_SELL && cur_price < price_flag) {
      price_flag -= 1*_Point;
      new_tp = cur_price - TS_MARGIN*_Point;
      new_sl = cur_price+TS_MARGIN*_Point;
      trade.PositionModify(trade_ticket, new_sl, new_tp);
      first_sl = new_sl;
   }
}


int OnInit() {
   /* Setting the Bollinger band handler */
   BBHandle = iBands(_Symbol, _Period, 20, 0, 2, PRICE_CLOSE);
   
   /* Setting the SMA handler */
   SMAHandle = iMA(_Symbol, _Period, 9, 0, MODE_SMA, PRICE_CLOSE);
   SMA200Handle = iMA(_Symbol, _Period, 200, 0, MODE_SMA, PRICE_CLOSE);
   
   /* Setting the arrays of the bands */
   ArraySetAsSeries(upperBandArray, true);
   ArraySetAsSeries(lowerBandArray, true);
   ArraySetAsSeries(bbMa, true);
   
   /* Setting the array with the close price of the previous candles */
   ArraySetAsSeries(PriceInformation, true);
   
   return(INIT_SUCCEEDED);
}

void OnTick() {
   /* Storing the value of the bollinger band */
   CopyBuffer(BBHandle, 0, 0, 3, bbMa);
   CopyBuffer(BBHandle, 1, 0, 3, upperBandArray);
   CopyBuffer(BBHandle, 2, 0, 3, lowerBandArray);

   /* Storing the value of the SMA */
   CopyBuffer(SMAHandle, 0, 0, 3, smaArray);
   CopyBuffer(SMA200Handle, 0, 0, 3, sma200Array);
   
   /* Storing the close prices */
   CopyRates(_Symbol, _Period, 0, 3, PriceInformation);
   
   /* Checking if there's an open operation */
   if (PositionSelectByTicket(trade_ticket) == true) {
      handle_trade(trade_ticket);
   } else {
      // Reseting the trade flags
      trade_ticket = 0;
      price_flag = 0;
   }
   
   /* Buy? */
   if (PriceInformation[2].close < lowerBandArray[2] // Second last close under the lower BB
       && PriceInformation[1].open < lowerBandArray[1] // Last open was below the lower BB 
       && PriceInformation[1].close > lowerBandArray[1] // Last close over the lower BB
       && sma200Array[0] < bbMa[0] && bbMa[0] > smaArray[0] // SMA 200 under the BB MA and BB MA under SMA 9
       && trade_ticket <= 0 && time_passed == true  // No trades open
       && PriceInformation[1].high < smaArray[1]  // The highest of the last candle didn't touch the SMA
       && upperBandArray[0]-lowerBandArray[0] > 200*_Point // The distance between the bands is big enough
       && PriceInformation[2].open > PriceInformation[2].close && PriceInformation[1].open < PriceInformation[1].close) { // Up down candles (in that order)
      
      /* Current price */
      double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
      
      //--- Open Buy
      first_sl = PriceInformation[1].low;
      
      trade.Buy(0.1, _Symbol, Ask, first_sl, smaArray[0], NULL);
      trade_ticket = trade.ResultOrder();
      price_flag = Ask+(smaArray[0]-Ask)*0.95; // Trailing stop at 80%  
      //price_flag = Ask+30*_Point;
 
      time_passed = false;
      EventSetTimer(60*180);
   } 
   /* Sell? */
   else if (PriceInformation[2].close > upperBandArray[2] // Second last close over the higher BB
              && PriceInformation[1].open > upperBandArray[1] // Last open was above the higher BB
              && PriceInformation[1].close < upperBandArray[1] // Last close under the upper BB
              && sma200Array[0] > bbMa[0] && bbMa[0] < smaArray[0] // SMA 200 above the BB MA and BB MA above SMA 9
              && trade_ticket <= 0 && time_passed == true // No trades open
              && PriceInformation[1].low > smaArray[1] // The lowest of the last candle didn't touch the SMA
              && upperBandArray[0]-lowerBandArray[0] > 200*_Point // The distance between the bands is big enough
              && PriceInformation[2].open < PriceInformation[2].close && PriceInformation[1].open > PriceInformation[1].close) { // down up candles (in that order)
      /* Current price */
      double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
      
      //--- Open Sell
      first_sl = PriceInformation[1].high;
      
      trade.Sell(0.1, _Symbol, Bid, first_sl, smaArray[0], NULL);
      trade_ticket = trade.ResultOrder();
      price_flag = Bid-(Bid-smaArray[0])*0.95; // Trailing stop at 80%
      //price_flag = Bid-30*_Point;
      
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

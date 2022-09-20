#include <Trade/Trade.mqh>
CTrade trade;
ulong trade_ticket;

input double initial_lotage = 0.01; // Lotaje inicial
double lotage = initial_lotage;

int initial_bars;
bool time_passed = false;

/* For the custom indicator */
int dp_h;

double buy_signal[];
double buy_signal2[];
double sell_signal[];
double sell_signal2[];

double tp1 = 0;
double tp2 = 0;
double tp3 = 0;

double sl1 = 0;
double sl2 = 0;

MqlRates candles[];

double break_even_trigger;
bool modified;

enum OpType {
   BUY, SELL
};
OpType op_type;

bool signal() { return buy_signal[0] > 0.1 || buy_signal2[0] > 0.1 || sell_signal[0] > 0.1 || sell_signal2[0] > 0.1; }

bool Buy_signal() { return buy_signal[0] > 0.1 || buy_signal2[0] > 0.1; }
bool Sell_signal() { return sell_signal[0] > 0.1 || sell_signal2[0] > 0.1; }


void break_even() {
   if (((op_type == BUY && candles[0].close > break_even_trigger) 
   || (op_type == SELL && candles[0].close < break_even_trigger))
   && !modified) {
      modified = trade.PositionModify(trade_ticket, tp2, tp3); 
   }
}

bool prev_operation_success() {
   HistorySelect(TimeCurrent()-(12*60*60), TimeCurrent());
   ulong prev_ticket = HistoryDealGetTicket(HistoryDealsTotal()-1);
   double profit = HistoryDealGetDouble(prev_ticket, DEAL_PROFIT);
   
   return profit > 0;
}

double get_lotage() {
   if (!prev_operation_success()) lotage *= 2;
   else lotage = initial_lotage;
   
   return lotage;
}


void OnInit() {
   dp_h = iCustom(_Symbol, _Period, "Market/Dark Point MT5");
   
   ArraySetAsSeries(buy_signal, true);
   ArraySetAsSeries(buy_signal2, true);
   ArraySetAsSeries(sell_signal, true);
   ArraySetAsSeries(sell_signal2, true);
   ArraySetAsSeries(candles, true);
   
   EventSetTimer(PeriodSeconds()+1);
}

void OnTick() {
   CopyBuffer(dp_h, 0, 1, 1, buy_signal);
   CopyBuffer(dp_h, 1, 1, 1, sell_signal);
   CopyBuffer(dp_h, 2, 1, 1, buy_signal2);
   CopyBuffer(dp_h, 3, 1, 1, sell_signal2);
   CopyRates(_Symbol, _Period, 0, 1, candles);
   
   break_even();
   
   if (PositionSelectByTicket(trade_ticket) == false) {
      trade_ticket = 0;
      modified = false;
   }
   
   if (signal() && time_passed && trade_ticket == 0) {
      string cur_time = IntegerToString(iTime(_Symbol, _Period, 1));
      tp1 = ObjectGetDouble(0, "DP_TP_Line_1"+cur_time, OBJPROP_PRICE);
      tp2 = ObjectGetDouble(0, "DP_TP_Line_2"+cur_time, OBJPROP_PRICE);
      tp3 = ObjectGetDouble(0, "DP_TP_Line_3"+cur_time, OBJPROP_PRICE);
      
      sl1 = ObjectGetDouble(0, "DP_SL_Line_1"+cur_time, OBJPROP_PRICE);
      sl2 = ObjectGetDouble(0, "DP_SL_Line_2"+cur_time, OBJPROP_PRICE);
      
      if (Buy_signal() && sl1 != 0 && tp3 != 0) {
         double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
      
         trade.Buy(get_lotage(), _Symbol, Ask, sl1, tp3, NULL);
         trade_ticket = trade.ResultOrder();
         op_type = BUY;
      } else if (Sell_signal() && sl1 != 0 && tp3 != 0) {
         double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
      
         trade.Sell(get_lotage(), _Symbol, Bid, sl1, tp3, NULL);
         trade_ticket = trade.ResultOrder();
         op_type = SELL;
      }
      
      break_even_trigger = tp2;
      
      time_passed = false;
      EventSetTimer(PeriodSeconds());
   }
}

void OnTimer() {
   time_passed = true;
   EventKillTimer();
}
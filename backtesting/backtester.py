import sys
import MetaTrader5 as mt5
sys.path.append('../')
import src.MACD as MACD, src.RSI as RSI, src.slope_abs_rel as slope_abs_rel, src.statistic as st

# File to load and save
FILENAME = sys.argv[1]
SAVEFILE = sys.argv[2]
TIME_PERIOD = int(sys.argv[3])*60
MARKET = sys.argv[4]

mt5.initialize()
point = mt5.symbol_info(MARKET).point
PROFIT = 20 * point
TAKE_PROFIT = 100 * point
STOP_LOSS = 100 * point
mt5.shutdown()

def get_buy_result(FILENAME, n, open_price):
    f = open(FILENAME, "r")

    profit = 0
    profit_price = open_price+PROFIT
    fail_price = STOP_LOSS-open_price
    goal_price = TAKE_PROFIT+open_price
    for i, line in enumerate(f):
        if i < n: continue
        
        price = float(line.split('\t')[1])
        
        # Checking if we reached the profit
        if profit_price <= price and profit == 0:
            profit = 1
        
        if price >= goal_price:
            return {"operation": "buy", "profit": profit, "success": 1}
        elif price <= fail_price:
            return {"operation": "buy", "profit": profit, "success": 0}
    f.close()


def get_sell_result(FILENAME, n, open_price):
    f = open(FILENAME, "r")

    profit = 0
    profit_price = open_price-PROFIT
    fail_price = STOP_LOSS+open_price
    goal_price = TAKE_PROFIT-open_price
    for i, line in enumerate(f):
        if i < n: continue
        
        price = float(line.split('\t')[1])
        
        # Checking if we reached the profit
        if profit_price >= price and profit == 0:
            profit = 1
        
        if price <= goal_price:
            return {"operation": "sell", "profit": profit, "success": 1}
        elif price >= fail_price:
            return {"operation": "sell", "profit": profit, "success": 0}
    f.close()


def check_buy(indicators, CUR_MACD, PREV_MACD, CUR_SIGNAL, PREV_SIGNAL):
    return indicators['RSI'] >= 60 and PREV_SIGNAL >= PREV_MACD and CUR_SIGNAL <= CUR_MACD


def check_sell(indicators, CUR_MACD, PREV_MACD, CUR_SIGNAL, PREV_SIGNAL):
    return indicators['RSI'] <= 40 and PREV_SIGNAL <= PREV_MACD and CUR_SIGNAL >= CUR_MACD


# Auxiliar values
CUR_MACD = 0.0
PREV_MACD = 0.0
CUR_SIGNAL = 0.0
PREV_SIGNAL = 0.0

trading_data = {
	"time_period": 15*60,
}
indicators = {
    "MACD": {"MACD": 0.0, "SIGNAL": 0.0},
    "RSI": 0.0,
    "slope": 0.0,
    "absolute_max": {"time": 0.0, "difference": 0.0},
    "absolute_min": {"time": 0.0, "difference": 0.0},
    "relative_min": {"time": 0.0, "difference": 0.0},
    "relative_max": {"time": 0.0, "difference": 0.0}
}
ticks = []
MACDs = []

# File to load and save
FILENAME = sys.argv[1]
SAVEFILE = sys.argv[2]
TIME_PERIOD = int(sys.argv[3])*60

# Opening the files
f1 = open(FILENAME, 'r')
f2 = open(SAVEFILE, 'w')

i = 0
n = 0
cur_second = 0

# Traversing the file
for line in f1:
    n+=1
    splitted = line.split('\t')
    second = float(splitted[0])
    price = float(splitted[1])

    # Loading the list
    if i < 200:
        if second + TIME_PERIOD >= cur_second:
            cur_second = second
            ticks.append(price)
            i += 1
            continue 
    
    # Updating the list of prices
    # Every time period we add a value to the list.
    # In any other case we just change the last value.
    if second + TIME_PERIOD >= cur_second:
        i += 1
        cur_second = second
        ticks.append(price)
        del ticks[0]

        # Computing the MACD and SIGNAL
        indicators["MACD"]["MACD"] = MACD.MACD(ticks)
        PREV_MACD = CUR_MACD
        CUR_MACD = indicators["MACD"]["MACD"]
        MACDs.append(indicators["MACD"]["MACD"])

        if len(MACDs) < 9:
            continue
        else:
            indicators["MACD"]["SIGNAL"] = MACD.SIGNAL(MACDs)
            PREV_SIGNAL = CUR_SIGNAL
            CUR_SIGNAL = indicators["MACD"]["SIGNAL"]
            del MACDs[0]

        # Computing the RSI
        indicators['RSI'] = RSI.RSI(ticks)
        
        # Computing the slope abs and max
        indicators["slope"] = st.pendienteY(ticks[-slope_abs_rel.N_FOR_SLOPE:])
        slope_abs_rel.get_absolutes(ticks, indicators)
        slope_abs_rel.get_relatives(ticks, indicators)
    else:
        ticks[-1] = price
        # Computing the MACD and SIGNAL
        indicators["MACD"]["MACD"] = MACD.MACD(ticks)
        PREV_MACD = CUR_MACD
        CUR_MACD = indicators["MACD"]["MACD"]
        MACDs[-1] = CUR_MACD

        if len(MACDs) < 9:
            continue
        else:
            indicators["MACD"]["SIGNAL"] = MACD.SIGNAL(MACDs)
            PREV_SIGNAL = CUR_SIGNAL
            CUR_SIGNAL = indicators["MACD"]["SIGNAL"]

        # Computing the RSI
        indicators["RSI"] = RSI.RSI(ticks)
        
        # Computing the slope abs and max
        indicators["slope"] = st.pendienteY(ticks[-slope_abs_rel.N_FOR_SLOPE:])
        slope_abs_rel.get_absolutes(ticks, indicators)
        slope_abs_rel.get_relatives(ticks, indicators)
    
    # Checking the if we can open an operations
    if check_buy(indicators, CUR_MACD, PREV_MACD, CUR_SIGNAL, PREV_SIGNAL):
        buy = get_buy_result(FILENAME, n, price)
        if buy is not None:
            buy['slope'] = indicators['slope']
            buy['time_from_abs_min'] = indicators['absolute_min']['time']
            buy['time_from_rel_min'] = indicators['relative_min']['time']
            buy['diff_from_abs_min'] = indicators['absolute_min']['difference']
            buy['diff_from_rel_min'] = indicators['relative_min']['difference']
        f2.write(str(buy)+"\n")
    elif check_sell(indicators, CUR_MACD, PREV_MACD, CUR_SIGNAL, PREV_SIGNAL):
        sell = get_sell_result(FILENAME, n, price)
        if sell is not None:
            sell['slope'] = indicators['slope']
            sell['time_from_abs_max'] = indicators['absolute_max']['time']
            sell['time_from_rel_max'] = indicators['relative_max']['time']
            sell['diff_from_abs_max'] = indicators['absolute_max']['difference']
            sell['diff_from_rel_max'] = indicators['relative_max']['difference']
        f2.write(str(sell)+"\n")

f1.close()
f2.close()
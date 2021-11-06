import MetaTrader5 as mt5
import datetime

RSI_BUY_THRESHOLD = 70
RSI_SELL_THRESHOLD = 30
CANDLES_BETWEEN_OPERATIONS = 3

STOPLOSS = 10
TAKEPROFIT = 20

def open_position(market, lotage, type_op):
    """Function to open a position.

    Args:
        market (string)
        lotage (float)
        type_op (string): Type of the operation
    """
    point = mt5.symbol_info(market).point
    price = mt5.symbol_info_tick(market).ask
    
    if type_op == "buy":
        sl = price-STOPLOSS*point
        tp = price+TAKEPROFIT*point
    else:
        sl = price+STOPLOSS*point
        tp = price-TAKEPROFIT*point

    deviation = 20
    operation = {
        "action": mt5.TRADE_ACTION_DEAL,
        "symbol": market,
        "volume": lotage,
        "type": mt5.ORDER_TYPE_BUY if type_op == "buy" else mt5.ORDER_TYPE_SELL,
        "price": price,
        "sl": sl,
        "tp": tp,
        "deviation": deviation,
        "magic": 234000,
        "comment": "python script open",
        "type_time": mt5.ORDER_TIME_GTC,
        "type_filling": mt5.ORDER_FILLING_IOC,
    }

    # Sending the buy
    result = mt5.order_send(operation)
    print("[Thread - orders] 1. order_send(): by {} {} lots at {} with deviation={} points".format(market,lotage,price,deviation))
    if result.retcode != mt5.TRADE_RETCODE_DONE:
        print("[Thread - orders] Failed operation: retcode={}".format(result.retcode))
        return None    

def thread_orders(stop_event, data, trading_data):
    """Function executed by a thread. It checks if the conditions to open orders
    are okay.

    Args:
        stop_event (thread.Event): Event to stop the thread.
        data (dict): Dictionary with candles and the indicator.
        trading_data (dict): Dictionary with the lotage and the market.
    """
    last_operation_time = 0
    ep = datetime.datetime(1970,1,1,0,0,0)
    
    while not data["rsi_ready"]:
        pass
    
    while not stop_event.wait(10):
        cur_time = int((datetime.datetime.utcnow()- ep).total_seconds())
        if data["RSI"][0] > RSI_BUY_THRESHOLD and cur_time > last_operation_time+trading_data["time_period"]*CANDLES_BETWEEN_OPERATIONS: # Open buy
            last_operation_time = cur_time
            open_position(trading_data["market"], trading_data["lotage"], "buy")
        elif data["RSI"][0] < RSI_SELL_THRESHOLD and cur_time > last_operation_time+trading_data["time_period"]*CANDLES_BETWEEN_OPERATIONS: # Open sell
            last_operation_time = cur_time
            open_position(trading_data["market"], trading_data["lotage"], "sell")
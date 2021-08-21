import MACD, RSI, time
import datetime as date
import MetaTrader5 as mt5


# Global variables
THRESHOLD = 20
MARGIN = 10
TIME_BETWEEN_OPERATIONS = 15*60*10
STOPLOSS = 100
TAKEPROFIT = 100


def handle_buy(buy, market):
    """Function to handle a buy operation.

    Args:
        buy : Buy operation.
        market (str): Market where the operation was openned.
    """
    position=mt5.positions_get(symbol=market)[-1].ticket
    point = mt5.symbol_info(market).point
    GOAL = buy['price']+point*THRESHOLD
    while True:
        tick = mt5.symbol_info_tick(market)
        if tick.ask >= GOAL:
            # Modifying the stop loss
            request = {
                "action": mt5.TRADE_ACTION_SLTP,
                "symbol": market,
                "sl": tick.ask - MARGIN * point,
                "tp": tick.ask + MARGIN * point,
                "deviation": 20,
                "magic": 234000,
                "comment": "python script open",
                "type_time": mt5.ORDER_TIME_GTC,
                "type_filling": mt5.ORDER_FILLING_RETURN,
                "position": position
            }
            GOAL = tick.ask + 1 * point
            mt5.order_send(request)
        # We check if the operation has been closed in order to leave the function
        if len(mt5.positions_get(ticket=position)) == 0:
            return
        time.sleep(0.1)


def handle_sell(sell, market: str):
    """Function to handle a sell operation.

    Args:
        sell : Sell operation.
        market (str): Market where the operation was openned.
    """
    position=mt5.positions_get(symbol=market)[-1].ticket
    point = mt5.symbol_info(market).point
    GOAL = sell['price']-point*THRESHOLD
    while True:
        tick = mt5.symbol_info_tick(market)
        if tick.bid <= GOAL:
            # Modifying the stop loss
            request = {
                "action": mt5.TRADE_ACTION_SLTP,
                "symbol": market,
                "sl": tick.bid + MARGIN * point,
                "tp": tick.bid - MARGIN * point,
                "deviation": 20,
                "magic": 234000,
                "comment": "python script open",
                "type_time": mt5.ORDER_TIME_GTC,
                "type_filling": mt5.ORDER_FILLING_RETURN,
                "position": position
            }
            GOAL = tick.bid - 1 * point
            mt5.order_send(request)
        # We check if the operation has been closed in order to leave the function
        if len(mt5.positions_get(ticket=position)) == 0:
            return
        time.sleep(0.1)


def open_buy(trading_data: dict):
    """Function to open a buy operation.

    Args:
        trading_data (dict): Dictionary with all the needed data.

    Returns:
        A buy.
    """
    symbol_info = mt5.symbol_info(trading_data['market'])
    if symbol_info is None:
        print("[Thread - orders]", trading_data['market'], "not found, can not call order_check()")
        return None
    
    counter = 0
    # We only open the operation if the spread is 0
    # we check the spread 300000 times
    while symbol_info.spread > 0 and counter < 300000:
        counter += 1
        symbol_info = mt5.symbol_info(trading_data['market'])

    # If the spread wasn't 0 then we do not open the operation 
    if counter == 300000:
        now = date.datetime.now()
        dt_string = now.strftime("%d-%m-%Y %H:%M:%S")
        print("[Thread - orders]", dt_string, "- Spread too high. Spread =", symbol_info.spread)
        return None

    # If the symbol is not available in the MarketWatch, we add it
    if not symbol_info.visible:
        print("[Thread - orders]", trading_data['market'], "is not visible, trying to switch on")
        if not mt5.symbol_select(trading_data['market'], True):
            print("[Thread - orders] symbol_select({}) failed, exit",trading_data['market'])
            return None

    point = mt5.symbol_info(trading_data['market']).point
    price = mt5.symbol_info_tick(trading_data['market']).ask
    deviation = 20
    buy = {
        "action": mt5.TRADE_ACTION_DEAL,
        "symbol": trading_data['market'],
        "volume": trading_data['lotage'],
        "type": mt5.ORDER_TYPE_BUY,
        "price": price,
        "sl": price - STOPLOSS * point,
        "tp": price + TAKEPROFIT * point,
        "deviation": deviation,
        "magic": 234000,
        "comment": "python script open",
        "type_time": mt5.ORDER_TIME_GTC,
        "type_filling": mt5.ORDER_FILLING_IOC,
    }

    # Sending the buy
    result = mt5.order_send(buy)
    print("[Thread - orders] 1. order_send(): by {} {} lots at {} with deviation={} points".format(trading_data['market'],trading_data['lotage'],price,deviation))
    if result.retcode != mt5.TRADE_RETCODE_DONE:
        print("[Thread - orders] Failed buy: retcode={}".format(result.retcode))
        return None
    return buy


def open_sell(trading_data: dict):
    """Function to open a sell operation.

    Args:
        trading_data (dict): Dictionary with all the needed data.

    Returns:
        A sell.
    """
    symbol_info = mt5.symbol_info(trading_data['market'])
    if symbol_info is None:
        print("[Thread - orders]", trading_data['market'], "not found, can not call order_check()")
        return None
    
    counter = 0
    # We only open the operation if the spread is 0
    # we check the spread 300000 times
    while symbol_info.spread > 0 and counter < 300000:
        counter += 1
        symbol_info = mt5.symbol_info(trading_data['market'])

    # If the spread wasn't 0 then we do not open the operation 
    if counter == 300000:
        now = date.datetime.now()
        dt_string = now.strftime("%d-%m-%Y %H:%M:%S")
        print("[Thread - orders]",dt_string, "- Spread too high. Spread =", symbol_info.spread)
        return None

    # si el símbolo no está disponible en MarketWatch, lo añadimos
    if not symbol_info.visible:
        print("[Thread - orders]", trading_data['market'], "is not visible, trying to switch on")
        if not mt5.symbol_select(trading_data['market'], True):
            print("[Thread - orders] symbol_select({}) failed, exit",trading_data['market'])
            return None
    
    point = mt5.symbol_info(trading_data['market']).point
    price = mt5.symbol_info_tick(trading_data['market']).bid
    deviation = 20
    sell = {
        "action": mt5.TRADE_ACTION_DEAL,
        "symbol": trading_data['market'],
        "volume": trading_data['lotage'],
        "type": mt5.ORDER_TYPE_SELL,
        "price": price,
        "sl": price + STOPLOSS * point,
        "tp": price - TAKEPROFIT * point,
        "deviation": deviation,
        "magic": 234000,
        "comment": "python script open",
        "type_time": mt5.ORDER_TIME_GTC,
        "type_filling": mt5.ORDER_FILLING_IOC,
    }

    # Sending the sell
    result = mt5.order_send(sell)
    print("[Thread - orders] 1. order_send(): by {} {} lots at {} with deviation={} points".format(trading_data['market'],trading_data['lotage'],price,deviation))
    if result.retcode != mt5.TRADE_RETCODE_DONE:
        print("[Thread - orders] failed sell: {}".format(result.retcode))
        return None
    return sell


def check_buy() -> bool:
    """Function to check if we can open a buy.

    Returns:
        bool: True if we can, false if not.
    """
    return MACD.check_buy() and RSI.check_buy()


def check_sell() -> bool:
    """Function to check if we can open a sell.

    Returns:
        bool: True if we can, false if not.
    """
    return MACD.check_sell() and RSI.check_sell()


def thread_orders(pill2kill, trading_data: dict):
    """Function executed by a thread. It opens and handles operations.

    Args:
        pill2kill (Threading.Event): Event to stop the thread's execution.
        trading_data (dict): Dictionary with all the needed data 
        for opening operations.
    """
    print("[THREAD - orders] - Working")
    
    last_operation = 0
    print("[THREAD - orders] - Checking operations")
    while not pill2kill.wait(0.1):
        if check_buy() and last_operation > TIME_BETWEEN_OPERATIONS:
            buy = open_buy(trading_data)
            last_operation = 0
            if buy is not None:
                now = date.datetime.now()
                dt_string = now.strftime("%d-%m-%Y %H:%M:%S")
                print("[Thread - orders] Buy open -", dt_string)
                handle_buy(buy, trading_data['market'])
                buy = None
               
        if check_sell() and last_operation > TIME_BETWEEN_OPERATIONS:
            sell = open_sell(trading_data)
            last_operation = 0
            if sell is not None:
                now = date.datetime.now()
                dt_string = now.strftime("%d-%m-%Y %H:%M:%S")
                print("[Thread - orders] Sell open -", dt_string)
                handle_sell(sell, trading_data['market'])
                sell = None
        last_operation += 1
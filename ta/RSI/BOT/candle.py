from to_candle import Candle
import MetaTrader5 as mt5
import datetime
import pytz

MAX_CANDLES = 50

def load_previous_candles(market: str, period: int, candles: list):
    """Function to load the previos candles given
    a market.

    Args:
        market (str): Market to check.
        period (int): Period to check in seconds.
        candles (list): List where the candles are stored.
    """
    today = datetime.datetime.utcnow().date()
    if today.weekday() >= 5 or today.weekday() == 0: 
        yesterday = today - datetime.timedelta(days=3)
    else:
        yesterday = today - datetime.timedelta(days=1)

    # Loading data
    print("[Thread CANDLE] - Asking for previous prices...")
    timezone = pytz.timezone("Etc/UTC")
    utc_from = datetime.datetime(int(yesterday.year), int(yesterday.month), int(yesterday.day), tzinfo=timezone)
    loaded_ticks = mt5.copy_ticks_from(market, utc_from, 300000, mt5.COPY_TICKS_ALL)
    if loaded_ticks is None:
        print("Error loading the ticks")
        return
    # Columns:
    # time - bid - ask - ...
    candles.append(Candle())
    open_price = loaded_ticks[0]["ask"]
    open_time = loaded_ticks[0]["time"]
    candles[0].set_open(open_price, open_time)
    last_tick_time = loaded_ticks[0]["time"]
    print("[Thread CANDLE] - Processing ticks...")
    for tick in loaded_ticks:

        # New candle every period
        if tick["time"]%period == 0 and last_tick_time < tick["time"]:
            last_tick_time = tick["time"]
            candles.append(Candle())
            candles[-1].set_open(candles[-2].close, last_tick_time)
            
        # Updating close
        candles[-1].tick(tick["bid"])
    
    # Removing not needed candles
    while len(candles) > MAX_CANDLES:
        del candles[0]

def thread_candle(pill2kill, data: dict, trading_data: dict):
    """Function executed by a thread. It fills the list of candles.

    Args:
        pill2kill (Threading.Event): Event to stop the execution of the thread.
        data (dict): Dictionary with the data of the bot. Here we store the candles.
        trading_data (dict): Trading data needed for loading candles.
    """
    load_previous_candles(trading_data["market"], trading_data["time_period"], data["candles"])

    data["candles_ready"] = True
    last_tick_time = data["candles"][-1].open_time
    ep = datetime.datetime(1970,1,1,0,0,0)
    
    while not pill2kill.wait(0.1):
        time_sec = int((datetime.datetime.utcnow()- ep).total_seconds())
        # Every trading_data['time_period'] seconds we add a tick to the list
        if time_sec%trading_data['time_period'] == 0 and time_sec > last_tick_time:
            last_tick_time = time_sec
            data["candles"].append(Candle())
            data["candles"][-1].set_open(data["candles"][-2].close, last_tick_time)
            
            # Deleting candles, we do not need a lot
            if len(data["candles"]) > MAX_CANDLES:
                del data["candles"][0]
                
        # The last tick is going to be changed all the time with the actual one
        bid = mt5.symbol_info_tick(trading_data['market']).bid
        data["candles"][-1].tick(bid)
        

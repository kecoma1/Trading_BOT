import MetaTrader5 as mt5
import datetime
import pytz

# Global variables
MAX_TICKS_LEN = 200
MAX_LEN_SPREAD = 20
spread_list = []


def store_tick(ticks: list, market: str):
    """Function that stores a tick into the given list,
    and also it checks if the list is full to remove a value.

    Args:
        ticks (list): List to be filled
        market (str): Market to be taken
    """
    tick = mt5.symbol_info_tick(market)
    ticks.append(tick.ask)
    
    # If the list is full (MAX_TICKS_LEN), 
    # we delete the first value
    if len(ticks) >= MAX_TICKS_LEN:
        del ticks[0]


def load_ticks(ticks: list, market: str, time_period: int):
    """Function to load into a list, previous ticks.

    Args:
        ticks (list): List where to load ticks.
        market (str): Market from which we have to take ticks.
        time_period (int): Time period in which we want to operate.
        1 minute, 15 minutes... (in seconds)
    """
    # Checking if we are on the weekend (we include the friday),
    # if so, we take ticks from an earlier date.
    today = datetime.datetime.utcnow().date()
    if today.weekday() >= 5 or today.weekday() == 0: 
        yesterday = today - datetime.timedelta(days=3)
    else:
        yesterday = today - datetime.timedelta(days=1)

    # Loading data
    timezone = pytz.timezone("Etc/UTC")
    utc_from = datetime.datetime(int(yesterday.year), int(yesterday.month), int(yesterday.day), tzinfo=timezone)
    loaded_ticks = mt5.copy_ticks_from(market, utc_from, 300000, mt5.COPY_TICKS_ALL)
    if loaded_ticks is None:
        print("Error loading the ticks")
        return -1

    # Filling the list
    second_to_include = loaded_ticks[0][0]
    for tick in loaded_ticks:
        # Every X seconds we add a value to the list
        if tick[0] > second_to_include+time_period:
            ticks.append(tick[2])
            second_to_include = tick[0]
    
    # Removing the ticks that we do not need
    not_needed_ticks = len(ticks) - MAX_TICKS_LEN
    if not_needed_ticks > 0:
        for i in range(not_needed_ticks):
            del ticks[0]


def thread_tick_reader(pill2kill, ticks: list, trading_data: dict):
    """Function executed by a thread. It fills the list of ticks and
    it also computes the average spread.

    Args:
        pill2kill (Threading.Event): Event to stop the execution of the thread.
        ticks (list): List of ticks to fill.
        trading_data (dict): Trading data needed for loading ticks.
    """
    global spread_list

    print("[THREAD - tick_reader] - Working")

    # Filling the list with previos ticks
    load_ticks(ticks, trading_data['market'], trading_data['time_period'])
    
    print("[THREAD - tick_reader] - Ticks loaded")
   
    # Filling the list with actual ticks
    print("[THREAD - tick_reader] - Taking ticks")
    i = 1
    while not pill2kill.wait(1):
        
        # Every trading_data['time_period'] seconds we add a tick to the list
        if i % trading_data['time_period'] == 0:
            store_tick(ticks, trading_data['market'])
            i = 0
        
        # Computing the average spread
        spread_list.append(mt5.symbol_info(trading_data['market']).spread)
        if len(spread_list) >= MAX_LEN_SPREAD:
            trading_data['avg_spread'] = sum(spread_list) / len(spread_list)
            del spread_list[0]
                
        # The last tick is going to be changed all the time with the actual one
        ticks[-1] = mt5.symbol_info_tick(trading_data['market']).ask
        i += 1

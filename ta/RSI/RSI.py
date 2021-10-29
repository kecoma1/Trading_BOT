import pandas as pd
from to_candle import from_list_to_df, Candle
from ta.momentum import RSIIndicator
import time
import datetime

def thread_rsi(pill2kill, candles: list, rsi: list, time_period: int):
    """Function executed by a thread that loads the rsi values.

    Args:
        pill2kill (Threading.Event): Event to stop the execution of the thread.
        candles (list): List of candles to fill.
        rsi (list): List where the rsi values are going to be stored.
        (Only 2 are stored, the last one and the previous one)
        time_period (int): Time period of the bot.
    """
    # Waiting until the candle thread loads data
    while len(candles) == 0:
        pass
    
    # Creating the dataframe of candles
    candle_df = from_list_to_df(candles)
    last_tick_time = 0
    
    # Indicator object
    rsi_object = RSIIndicator(candle_df["CLOSE"], window=14, fillna=True)
    rsi_series = rsi_object.rsi()
    rsi = [rsi_series.iloc[-1], rsi_series.iloc[-2]]

    while not pill2kill.wait(1):
        ep = datetime.datetime(1970,1,1,0,0,0)
        time_sec = int((datetime.datetime.utcnow()- ep).total_seconds())
        
        len_df = candle_df.shape[0]
        
        # Every time_period seconds we add a tick to the list
        if time_sec%time_period == 0 and time_sec != last_tick_time:
            # Waiting so the data is loaded
            time.sleep(1)

            # Updating the df
            last_tick_time = time_sec
            # candle_df = from_list_to_df(candles) # Inefficient
            candle_df[len_df+1] = candles[-1].get_info()
            del candle_df[0]
        
        # Updating the last value in the candles dataframe
        candle_df.loc[len_df] = candles[-1].get_info()
        
        rsi_object = RSIIndicator(candle_df["CLOSE"], window=14, fillna=True)
        rsi_series = rsi_object.rsi()
        rsi = [rsi_series.iloc[-1], rsi_series.iloc[-2]]
            
            
        
import pandas as pd
from to_candle import from_list_to_df, Candle
from ta.momentum import RSIIndicator
import time
import datetime

def thread_rsi(pill2kill, data: dict, time_period: int):
    """Function executed by a thread that loads the rsi values.

    Args:
        pill2kill (Threading.Event): Event to stop the execution of the thread.
        data (dict): Dictionary with the data of the bot. Here we store the candles.
        (Only 2 are stored, the last one and the previous one)
        time_period (int): Time period of the bot.
    """
    # Waiting until the candle thread loads data
    print('[Thread RSI] - Waiting for candles...')
    while not data["candles_ready"]:
        time.sleep(1)
    
    # Indicator object
    candle_df = from_list_to_df(data["candles"])
    rsi_object = RSIIndicator(candle_df["CLOSE"], window=14, fillna=True)
    rsi_series = rsi_object.rsi()
    data["RSI"] = [rsi_series.iloc[-2], rsi_series.iloc[-3]]
    data["rsi_ready"] = True

    # For sinchronizing
    print("[Thread RSI] - Sinchronizing...")
    ep = datetime.datetime(1970,1,1,0,0,0)
    time_sec = 1
    while time_sec % time_period != 0 and not pill2kill.wait(0.5):
        time.sleep(0.1)
        time_sec = int((datetime.datetime.utcnow()- ep).total_seconds())

    print('[Thread RSI] - Loading RSI...')
    while not pill2kill.wait(time_period):
        candle_df = from_list_to_df(data["candles"])

        # Indicator object
        rsi_object = RSIIndicator(candle_df["CLOSE"], window=14, fillna=True)
        rsi_series = rsi_object.rsi()
        data["RSI"] = [rsi_series.iloc[-2], rsi_series.iloc[-3]]
        

import pandas as pd
from datetime import datetime   


class Candle:
    def __init__(self):
        self.open_time = 0
        self.open = 0
        self.close = 0
        self.high = 0
        self.low = 9223372036854775807
    
    def tick(self, tick, tick_type):
        if self.close == 0:
            self.close = tick
            self.set_high(tick)
            self.set_low(tick)
        elif self.close < self.open and tick_type == "ask":
            self.close = tick
            self.set_high(tick)
            self.set_low(tick)
        elif self.close > self.open and tick_type == "bid":
            self.close = tick
            self.set_high(tick)
            self.set_low(tick)

    def set_open(self, tick, time):
        if self.open == 0:
            self.open = tick
            self.open_time = time

    def set_low(self, new_low):
        self.low = new_low if new_low<self.low else self.low

    def set_high(self, new_high):
        self.high = new_high if new_high>self.high else self.high

    def get_info(self):
        return [self.open_time, self.open, self.close, self.high, self.low]
    
def from_list_to_df(candles):
    """Function that given a list of candles, it 
    returns a pandas dataframe with all those candles.

    Args:
        candles (list): List of candles.

    Returns:
        pandas.dataframe: Dataframe with all the candles.
    """
    candle_df = pd.DataFrame(columns=["TIME-UTC", 
                                        "OPEN", 
                                        "CLOSE", 
                                        "HIGH", 
                                        "LOW"])
    for i, candle in enumerate(candles):
        candle_df.loc[i] = candle.get_info()
    return candle_df


def from_tick_to_candle(filename, timeframe:int):
    """Function that generates a candle dataframe.

    Args:
        filename: filename of the csv with the ticks.
        timeframe (int): Candle timeframe in seconds.
    
    Return:
        Pandas dataframe that contains columns such as:
            TIME-UTC, OPEN, CLOSE, HIGH, LOW
    """
    tick_df = pd.read_csv(filename, sep='\t')

    # Creating a new dataframe
    candle_df = pd.DataFrame(columns=["TIME-UTC", 
                                        "OPEN", 
                                        "CLOSE", 
                                        "HIGH", 
                                        "LOW"])

    # First candle, setting the open and the first time
    candle = Candle()
    prev_time = datetime.strptime(tick_df.iloc[0]["<DATE>"]+" 00:00:00.000", "%Y.%m.%d %H:%M:%S.%f").timestamp()
    candle.open = tick_df.iloc[0]["<BID>"]
    candle.open_time = prev_time
    num_candles = 0

    # Iterating through the tick dataframe
    for row in tick_df.iterrows():
        # Getting the attributes of the ticks
        cur_time = datetime.strptime(row[1]["<DATE>"]+" "+row[1]["<TIME>"], "%Y.%m.%d %H:%M:%S.%f").timestamp()
        bid = row[1]["<BID>"]
        ask = row[1]["<ASK>"]
        last_val = ask if ask>0 else bid
        
        candle.set_high(bid)
        candle.set_low(ask)

        # If we are in a new candle timeframe, we create
        # a new one, set the close of the one before and
        # we set a new time goal
        if prev_time+timeframe < cur_time:
            # Setting the close of the candle
            if bid > 0 and ask > 0:
                candle.close = bid if ask>candle.open else ask
            elif bid > 0:
                candle.close = bid
            elif ask > 0:
                candle.close = ask
            else:
                candle.close = last_val
                
            prev_close = candle.close

            # Adding a row in the dataframe
            candle_df.loc[num_candles] = candle.get_info()
            num_candles += 1
            
            # Creating a new candle
            candle = Candle()
            prev_time = prev_time+timeframe
            candle.open = prev_close
            candle.open_time = prev_time
    return candle_df

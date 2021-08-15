import time

# Global variables
MACDs = []
PREV_MACD = 0.0
PREV_SIGNAL = 0.0
CUR_MACD = 0.0
CUR_SIGNAL = 0.0

PREV_EMA9 = None
PREV_EMA12 = None
PREV_EMA26 = None

def K(n):
    """Function for calculating k

    Args:
        n (int): Lenght
    
    Returns:
        float: valor
    """
    return 2/(n+1)


def SMA(ticks):
    """Function that computes the Simple Moving Average.

    Args:
        ticks (list): List with prices.

    Returns:
        float: valor
    """
    return sum(ticks)/len(ticks)


def EMA(ticks: list, n: int):
    """Function that computes the Exponential Moving Average.   

    Args:
        ticks (list): List of prices.
        n (int): Number of values to take into account.
        n can only be 12, 9 or 26.

    Returns:
        float: Value of the EMA
    """
    global PREV_EMA12, PREV_EMA26, PREV_EMA9
    
    if n != 12 or n != 26:
        print("EMA function: N must be 12 or 26")
    
    # Not enough ticks in the list
    if n > len(ticks): return None
    
    k = K(n)
    
    # Checking if the previous EMA has been calculated
    prev_ema = 0
    if n == 12:
        if PREV_EMA12 is None: 
            prev_ema = SMA(ticks)
        else:
            prev_ema = PREV_EMA12
        ema = (ticks[-1] - prev_ema)*k + prev_ema
        PREV_EMA12 = ema 
    elif n == 26:
        if PREV_EMA26 is None: 
            prev_ema = SMA(ticks)
        else:
            prev_ema = PREV_EMA26
        ema = (ticks[-1] - prev_ema)*k + prev_ema
        PREV_EMA26 = ema 
    else:
        if PREV_EMA9 is None: 
            prev_ema = SMA(ticks)
        else:
            prev_ema = PREV_EMA9
        ema = (ticks[-1] - prev_ema)*k + prev_ema
        PREV_EMA9 = ema 
    
    return ema
    
def MACD(ticks):
    """Function that computes the MACD.

    Args:
        ticks (list): List with prices of the ticks

    Returns:
        float: Value of the MACD
    """
    return EMA(ticks[-12:], 12) - EMA(ticks[-26:], 26)

def SIGNAL():
    """Function that computes the SIGNAL.

    Returns:
        float: Value of the SIGNAL
    """
    return EMA(MACDs[-9:], 9)

def thread_macd(pill2kill, ticks: list):
    global MACDs
    
    # Wait if there are not enough elements
    while len(ticks) < 35:
        time.sleep(1.5)
    
    # First we need to calculate the previous MACDs and SIGNALs
    i = 26
    while i < len(ticks):
        # Computing the MACD
        PREV_MACD = CUR_MACD
        CUR_MACD = MACD(ticks[:i])
        MACDs.append(CUR_MACD)
        
        i+=1
        
        # Computing the SIGNAL
        if len(MACDs) < 9:
            continue
        else:
            PREV_SIGNAL = CUR_SIGNAL
            CUR_SIGNAL = SIGNAL(MACDs)

    # Main thread loop
    while not pill2kill.wait(1):
        # Computing the MACD
        PREV_MACD = CUR_MACD
        CUR_MACD = MACD(ticks[:i])
        MACDs.append(CUR_MACD)
        
        # Computing the SIGNAL
        PREV_SIGNAL = CUR_SIGNAL
        CUR_SIGNAL = SIGNAL(MACDs)
            
# Global variables
MACDs = []
PREV_MACD = None
PREV_SIGNAL = None
CUR_MACD = None
CUR_SIGNAL = None

PREV_EMA9 = None
PREV_EMA12 = None
PREV_EMA26 = None

MAX_LEN = 9


def check_buy() -> bool:
    """Function to check if the MACD indicator
    allows a buy operation.

    Returns:
        bool: True if it is a buy oportunity, false if not
    """
    if CUR_SIGNAL == None or CUR_MACD == None \
        or PREV_SIGNAL == None or PREV_MACD == None:
        return False
    if PREV_SIGNAL >= PREV_MACD:
        if CUR_SIGNAL <= CUR_MACD:
            return True
    return False


def check_sell() -> bool:
    """Function to check if the MACD indicator
    allows a buy operation.

    Returns:
        bool: True if it is a buy oportunity, false if not
    """
    if CUR_SIGNAL == None or CUR_MACD == None \
        or PREV_SIGNAL == None or PREV_MACD == None:
        return False
    if PREV_SIGNAL <= PREV_MACD:
        if CUR_SIGNAL >= CUR_MACD:
            return True
    return False


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
    
    if n != 12 and n != 26 and n != 9:
        print("EMA function: N must be 12 or 26 or 9")
    
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
        float: Value of the MACD.
    """
    return EMA(ticks[-12:], 12) - EMA(ticks[-26:], 26)


def SIGNAL(values_list):
    """Function that computes the SIGNAL.

    Args:
        values_list (list): List with which we have to compute the values.

    Returns:
        float: Value of the SIGNAL.
    """
    return EMA(values_list[-9:], 9)


def thread_macd(pill2kill, ticks: list, indicators: dict, trading_data: dict):
    """Function executed by a thread that calculates
    the MACD and the SIGNAL.

    Args:
        pill2kill (Threading.Event): Event for stopping the thread's execution.
        ticks (list): List with prices.
        indicators (dict): Dictionary where the data is going to be stored.
        trading_data (dict): Dictionary where the data about our bot is stored.
    """
    global MACDs, CUR_SIGNAL, CUR_MACD, PREV_SIGNAL, PREV_MACD
    
    # Wait if there are not enough elements
    while len(ticks) < 35 and not pill2kill.wait(1.5):
        print("[THREAD - MACD] - Waiting for ticks")
    
    print("[THREAD - MACD] - Loading values")
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
        
        if len(MACDs) > 9:
            del MACDs[0]

    # Main thread loop
    print("[THREAD - MACD] - Computing values")
    i = 0
    while not pill2kill.wait(1):
        # Computing the MACD
        PREV_MACD = CUR_MACD
        CUR_MACD = MACD(ticks[-26:])
        
        # Only append a MACD value every time period
        if i >= trading_data['time_period']:
            MACDs.append(CUR_MACD)
            i = 0
        else:
            MACDs[-1] = CUR_MACD
        i+=1
        
        # Computing the SIGNAL
        PREV_SIGNAL = CUR_SIGNAL
        CUR_SIGNAL = SIGNAL(MACDs)
        
        # Updating the dictionary
        indicators['MACD']['MACD'] = CUR_MACD
        indicators['MACD']['SIGNAL'] = CUR_SIGNAL

        if len(MACDs) > 9:
            del MACDs[0]

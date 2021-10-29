import statistic as st

# Global variables
N_FOR_SLOPE = 5


def get_absolutes(ticks: list, indicators: dict):
    """Function to get the absolute points (maximum and minimum)
    of the already stored ticks in the list.

    Args:
        ticks (list): List of where ticks are stored.
        indicators (dict): Dictionary where the info is stored.
    """
    # Not enough values in the list
    if len(ticks) == 0: return
    
    # Storing the difference between the current price
    # and the max and min values
    current_price = ticks[-1]
    abs_min = min(ticks)
    abs_max = max(ticks)
    indicators['absolute_min']['difference'] = current_price-abs_min
    indicators['absolute_max']['difference'] = abs_max-current_price

    # Flags
    minimo_found = False
    maximo_found = False
    
    # Looking for the number of periods since the absolutes
    # by traversing the list of ticks backwards. The periods
    # can be of 1, 5, 15 minutes...
    i = 0
    for valor in ticks[::-1]:
        if valor == abs_min and not minimo_found:
            indicators['absolute_min']['time'] = i
            minimo_found = True
        if valor == abs_max and not maximo_found:
            indicators['absolute_max']['time'] = i
            maximo_found = True
        i+=1
        if minimo_found and maximo_found:
            break


def get_relatives(ticks: list, indicators: dict):
    """Function to get the last relatives points stored in our 
    list of ticks. For that, we traverse the list backwards and
    in each iteration we compute the slope, if the slope has a 
    different sign than before, then we found a relative.

    Args:
        ticks (list): List where all the ticks are stored.
        indicators (dict): Dictionary where the data is going to
        be stored.
    """
    i = len(ticks)
    # Not enough values in the list
    if i < 2: return
    
    cur_price = ticks[-1]
    
    # Flags
    min_found = False
    max_found = False
    
    # Variables to find relatives. If the sign of the
    # slopes are different then we are in a relative.
    # +/- relative max, -/+ relative min
    prev_slope = 0
    cur_slope = 0
    
    # Iterating through the list backwards, storing the difference
    # between the current price and the price at the relative, and also
    # storing the number of periods since that relative
    while i > 2:
        cur_slope = st.pendienteY(ticks[i-2:i])
        # Min?
        if prev_slope < 0 and cur_slope > 0 and not min_found:
            indicators['relative_min']['time'] = len(ticks) - i
            indicators['relative_min']['difference'] = cur_price-ticks[i]
            min_found = True
        # Max?
        if prev_slope > 0 and cur_slope < 0 and not max_found:
            indicators['relative_max']['time'] = len(ticks) - i
            indicators['relative_max']['difference'] = ticks[i]-cur_price
            max_found = True
        # If both relatives found, we go out
        if min_found and max_found:
            break
        prev_slope = cur_slope
        i-=1


def thread_slope_abs_rel(pill2kill, ticks: list, indicators: dict):
    """Function executed by a thread. It computes the actual slope and,
    the absolutes and relative points.

    Args:
        pill2kill (Threading.Event): Event to finish the thread's execution.
        ticks (list): List where the ticks are stored.
        indicators (dict): Dictionary where the computed data has to be stored.
    """
    print("[THREAD - slope_abs_rel] - Working")
    
    # Waiting until the list is ready
    while len(ticks) < N_FOR_SLOPE and not pill2kill.wait(1.5): 
        print("[THREAD - slope_abs_rel] - Waiting for ticks")

    print("[THREAD - slope_abs_rel] - Computing values")
    while not pill2kill.wait(1):
        # Getting the slope
        indicators['slope'] = st.pendienteY(ticks[-N_FOR_SLOPE:])
        
        # Getting the absolute points
        get_absolutes(ticks, indicators)
        
        # Getting the relative points
        get_relatives(ticks, indicators)
        
        
        
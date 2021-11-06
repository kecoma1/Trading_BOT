import MetaTrader5 as mt5
import candle, RSI, threading, orders

class Bot:
    
    def __init__(self, lotage: float, time_period: int, market: str):
        """Constructor of the bot. It justs fills the needed informartion for the bot.
        
        Args:
            lotage (float): Lotage to be used by the bot.
            time_period (int): Time period of the bot, 1 minute, 15 minutes... (in seconds)
            market (str): Market to operate in.
        """
        self.threads = []
        self.data = {'candles': [], 'RSI': [], 'candles_ready': False, 'rsi_ready': False}
        self.pill2kill = threading.Event()
        self.trading_data = {}
        self.trading_data['lotage'] = lotage
        self.trading_data['time_period'] = time_period
        self.trading_data['market'] = market

    def thread_candle(self):
        """Function to launch the candle thread.
        """
        t = threading.Thread(target=candle.thread_candle, 
                             args=(self.pill2kill, self.data, self.trading_data))
        self.threads.append(t)
        t.start()
        print('Thread - CANDLE. LAUNCHED')
    
    def thread_RSI(self):
        """Function to launch the thread for calculating the RSI.
        """
        t = threading.Thread(target=RSI.thread_rsi, 
                             args=(self.pill2kill, self.data, self.trading_data['time_period']))
        self.threads.append(t)
        t.start()
        print('Thread - RSI. LAUNCHED')

    def thread_orders(self):
        """Function to launch the thread for sending orders.
        """
        t = threading.Thread(target=orders.thread_orders, 
                             args=(self.pill2kill, self.data, self.trading_data))
        self.threads.append(t)
        t.start()
        print('Thread - ORDERS. LAUNCHED')

    """def mt5_login(self, usr: int, server: str, password: str) -> bool:
        """"""Function to initialize the metatrader 5 aplication
        and login wiht our account details.

        Args:
            usr (int): User ID.
            server (str): Server.
            password (str): Password.

        Returns:
            bool: True if everything is OK, False if not
        """"""
        # Initialize mt5 (if not already)
        if not mt5.initialize(login=usr, server=server,password=password):
            print("initialize() failed, error code =",mt5.last_error())
            return False
        return True"""
    
    def kill_threads(self):
        """Function to kill all the loaded threads.
        """
        print('Threads - Stopping threads')
        self.pill2kill.set()
        for thread in self.threads:
            thread.join()
    
    def wait(self):
        """Function to make the thread wait.
        """
        # Input para detener a los hilos
        print('\nPress ENTER to stop the bot\n')
        input()
        self.kill_threads()
        mt5.shutdown()
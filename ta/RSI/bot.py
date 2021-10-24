import threading
import MetaTrader5 as mt5

class Bot:
    
    def __init__(self, lotage: float, time_period: int, market: str):
        """Constructor of the bot. It justs fills the needed informartion for the bot.
        
        Args:
            lotage (float): Lotage to be used by the bot.
            time_period (int): Time period of the bot, 1 minute, 15 minutes... (in seconds)
            market (str): Market to operate in.
        """
        self.threads = []
        candles = []
        pill2kill = threading.Event()
        self.trading_data = {}
        self.RSI = None
        self.trading_data['lotage'] = lotage
        self.trading_data['time_period'] = time_period
        self.trading_data['market'] = market

    def thread_candle(self):
        """Function to launch the candle thread.
        """
        pass
    
    def thread_RSI(self):
        """Function to launch the thread for calculating the RSI.
        """
        pass

    def thread_orders(self):
        """Function to launch the thread for sending orders.
        """
        pass

    def mt5_login(self, usr: int, password: str) -> bool:
        """Function to initialize the metatrader 5 aplication
        and login wiht our account details.

        Args:
            usr (int): User ID.
            password (str): Password

        Returns:
            bool: True if everything is OK, False if not
        """
        # Initialize mt5 (if not already)
        if not mt5.initialize():
            print("initialize() failed, error code =",mt5.last_error())
            return False
        
        # Login into mt5
        authorized=mt5.login(usr, password)
        if not authorized:
            print("failed to connect at account #{}, error code: {}".format(usr, mt5.last_error()))
            return False
        return True
    
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
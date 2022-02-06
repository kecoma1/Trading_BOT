from bot import Bot
import MetaTrader5 as mt5


mt5.initialize()

macd_bot = Bot(0.01, 60, "BTCEUR")

macd_bot.start()
macd_bot.wait()
from bot import Bot
import MetaTrader5 as mt5

#
mt5.initialize()

macd_bot = Bot(0.1, 60, "Boom 300 Index")

macd_bot.start()
macd_bot.wait()
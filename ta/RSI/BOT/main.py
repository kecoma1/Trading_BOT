import bot
import MetaTrader5 as mt5

# Creating a bot
b = bot.Bot(0.01, 60*15, "EURUSD")

# Login into mt5
mt5.initialize(login=50708418, server='ICMarketsEU-Demo',password='Yyaexkks')

b.thread_candle()
b.thread_RSI()
b.thread_orders()
b.wait()
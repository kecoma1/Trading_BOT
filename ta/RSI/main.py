
import bot

# Creating a bot
b = bot.Bot(0.01, 15*60, "EURUSD")

with open("login_data.txt", 'r') as f:
    lines = f.readlines()
    usr = int(lines[0])
    password = lines[1]

# Login into mt5
if not b.mt5_login(usr, password):
    quit()
b.thread_candle()
b.thread_RSI()
b.thread_orders()
b.wait()
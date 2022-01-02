import json
from to_candle import Candle
from websocket import WebSocketApp

candles = [Candle()]

def on_message(ws, m):
    tick = json.loads(m)
    print(tick["k"]["c"])
    if tick["k"]["x"]:
        print("hety")
        candles.append(Candle())
    candles[-1].tick(tick["k"]["c"])

ws = WebSocketApp("wss://stream.binance.com:9443/ws/btcusdt@kline_1m",
                            on_message=on_message)
ws.run_forever()
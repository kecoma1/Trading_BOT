from websocket import WebSocketApp
import json

def on_message(ws, msg):
    tick = json.loads(msg)
    if tick['k']['x']:
        print("NUEVA VEL")
    print(tick['k']['c'])


ws = WebSocketApp("wss://stream.binance.com:9443/ws/btcusdt@kline_1m", on_message=on_message)
ws.run_forever()
import signal

# DOCUMENTATION!
# https://docs.python.org/3/library/signal.html


def signal_handler(signum, frame):
    """Handler"""
    print("En vez de cerrarme voy a printear esto.")


# Setting the handler
signal.signal(signal.SIGINT, signal_handler)

# Infinite loop
while True:
    pass

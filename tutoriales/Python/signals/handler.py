import signal


def signal_handler(signum, frame):
    """Handler"""
    print("Signal Number:", signum, " Frame: ", frame)
    print("Instead of closing my self I will continue executing")


# Setting the handler
signal.signal(signal.SIGINT, signal_handler)

# Infinite loop
while True:
    pass

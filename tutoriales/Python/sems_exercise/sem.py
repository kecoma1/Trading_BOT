import threading
from random import randint
from time import sleep

NUM_KIDS = 10
AVAILABLE_PIECES = 3

mutex = threading.Semaphore(1)


def call_mum_for_cakes():
    global AVAILABLE_PIECES

    sleep(5)
    AVAILABLE_PIECES = 3
    print("I'm mum, and I have brought a new cake")

def kid(n):
    global AVAILABLE_PIECES

    sleep(randint(1, 9))

    for _ in range(randint(1, 4)):
        # Go to the queue
        mutex.acquire()

        # If there are no pieces every one waits until there's a new cake
        if AVAILABLE_PIECES <= 0:
            call_mum_for_cakes()

        # Since we are taking a piece we must delete one
        AVAILABLE_PIECES -= 1

        # Kid N is takes his piece of cake
        print("I'm the kid", n, "and I'm taking my peace of cake. There are", AVAILABLE_PIECES, "left")
        sleep(randint(1, 3))

        # Kid got his food
        mutex.release()

        # Kid N is going to eat
        print("I'm the kid", n, "and I'm eating")
        sleep(randint(3, 6))


threads = []
for i in range(NUM_KIDS):
    threads.append(threading.Thread(target=kid, args=(i+1,)))
    threads[-1].start()

for t in threads:
    t.join()
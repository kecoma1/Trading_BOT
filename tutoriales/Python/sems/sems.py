import threading

sem1 = threading.Semaphore(0)
sem2 = threading.Semaphore(0)

def fun_1():
    print(1)
    sem1.release()
    sem2.acquire()
    sem1.release()
    print(3)

def fun_2():
    print(2)
    sem1.acquire()
    sem2.release()
    sem1.acquire()
    print(4)

threading.Thread(target=fun_1).start()
threading.Thread(target=fun_2).start()
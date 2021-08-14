import bot
import matplotlib.pyplot as plt

# Creating a bot
b = bot.Bot(0.01, 15*60, "EURUSD")

usr = int(input("Introduce the user: "))
password = input("Introduce the password: ")
print("Hiding things xd ;)\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n")

# Login into mt5
b.mt5_login(usr, password)
b.thread_tick_reader()
b.wait()

# Haciendo una gráfica de los datos
lista_segundos = b.get_ticks()
xAxis = []
yAxis = []
i = 1
if len(lista_segundos) < 10000:
    for element in b.get_ticks():
        xAxis.append(i)
        yAxis.append(element)
        i += 1

plt.plot(xAxis, yAxis)
plt.show()

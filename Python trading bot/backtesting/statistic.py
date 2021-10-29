def sumatorio(lista_valores):
    """Función que dada una lista de valores calcula el sumatorio

    Args:
        lista_valores (list): Lista con los valores

    Returns:
        int-float: Valor del sumatorio
    """
    acumulador = 0
    for valor in lista_valores:
        acumulador += valor
    return acumulador


def sumatorio2(lista_valores):
    """Función que dada una lista de valores calcula el sumatorio
    de todos los valores al cuadrado

    Args:
        lista_valores (list): Lista con los valores

    Returns:
        int-float: Valor del sumatorio
    """
    acumulador = 0
    for valor in lista_valores:
        acumulador += valor*valor
    return acumulador


def media(lista_valores):
    """Función que dada una lista de valores calcula la media.

    Args:
        lista_valores (list): Lista con los valores

    Returns:
        int-float: Media
    """
    return sumatorio(lista_valores)/len(lista_valores)


def covarianza(lista_x, lista_y):
    """Función que calcula la covarianza dadas dos listas

    Args:
        lista_x (list): Lista con los valores de X
        lista_y (list): Lista con los valores de Y

    Returns:
        int-float: Covarianza
    """
    acumulador = 0
    i = 0
    for valor in lista_x:
        acumulador += valor*lista_y[i]
        i+=1
    return (acumulador/len(lista_x))-(media(lista_x)*media(lista_y))


def varianza(lista_valores):
    """Función que devuelve la varianza dada una lista de valores

    Args:
        lista_valores (list): Lista con los valores

    Returns:
        int-float: Varianza
    """
    return sumatorio2(lista_valores)/len(lista_valores)-media(lista_valores)**2

   
def pendiente(lista_x, lista_y):
    """Función que dadas dos listas, devuelve la pendiente de la 
    recta de regresión. Ambas listas deben tener la misma longitud

    Args:
        lista_x (list): Valores de X
        lista_y (list): Valores de Y

    Returns:
        int-float: Pendiente de la recta
    """
    return covarianza(lista_x, lista_y)/varianza(lista_x)


def pendienteY(lista_y):
    """Función que dada una lista, devuelve la pendiente de la 
    recta de regresión. Hacen falta dos listas, la lista X se 
    rellena con 1, 2, 3... hasta el número de elementos en la lista Y
    Ambas listas deben tener la misma longitud

    Args:
        lista_y (list): Valores de Y

    Returns:
        int-float: Pendiente de la recta
    """
    lista_x = []
    for i in range( len(lista_y) ):
        lista_x.append(i+1)
    return covarianza(lista_x, lista_y)/varianza(lista_x)
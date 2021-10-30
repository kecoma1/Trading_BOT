import datetime 
import matplotlib.pyplot as plt
import sys

# Parser from metatrader 5 csv format to our format
# Getting the information
FILENAME = sys.argv[1]
SAVEFILE = sys.argv[2]

# Opening the file
f = open(FILENAME, 'r')

# Opening saving file
f2 = open(SAVEFILE, 'w')

# Calculando epoch
epoch = datetime.datetime.utcfromtimestamp(0)

# Moving through the lines
i = 0
for line in f:
    if i == 0:
        i+=1
        continue
    # Removing comas and splitting the line
    splitted = line.replace(',', '').split('\t')
    if splitted[2] == '':
        continue
    
    # Adding the right date
    time = splitted[0].split('.')
    hour = splitted[1].split(':')
    date = datetime.datetime(int(time[0]), # Year 
                             int(time[1]), # Month
                             int(time[2]), # Day
                             int(hour[0]), # Hour
                             int(hour[1]), # Minute
                             int(float(hour[2])), # second 
                             int( ( float(hour[2])-int(float(hour[2])) )*1000000 ) ) # Microsecond
    date = date.timestamp()
    f2.write(str(date)+'\t'+str(splitted[2])+'\n')

# Closing the files
f2.close()
f.close()
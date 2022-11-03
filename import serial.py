import serial 
import matplotlib.pyplot as plt

ser = serial.Serial(
    port='/dev/ttyUSB1',
    baudrate=115200,
    parity=serial.PARITY_NONE,
    stopbits=serial.STOPBITS_ONE,
    bytesize=serial.EIGHTBITS,
    timeout = None
)


def dec_to_bin(x):
    return int(bin(x)[2:])

def binaryTodecimal(n):
    decimal = 0
    power = 1
    while n>0:
        rem = n%10
        n = n//10
        decimal += rem*power
        power = power*2
        
    return decimal

def full_Byte(x):
    string = str(x)
    string_out = "0"*(8-len(string)) +string
    return string_out

counter = 0
aux = []

x = []
y = []
while True:
    
    hexData= ser.read()
    val = int.from_bytes(hexData, "big")


    aux.append(str(full_Byte(dec_to_bin(val))))


    if len(aux) == 2 :    
        print(aux[0]+aux[1])
        print(binaryTodecimal(int(aux[0]+aux[1])))
        print(binaryTodecimal(int(aux[0]+aux[1])))

        decimal = binaryTodecimal(int((aux[0]+aux[1])[0:12]))
        print(decimal/(2**12))

        y.append(decimal/(2**12))
        aux     = []
        counter = 0

        
        plt.plot(y)
        plt.pause(1e-5)
        plt.title(f'Serial_read / Measure: { decimal/(2**12)}')
        plt.xlabel("time (*2s)")
        plt.ylabel("bits")




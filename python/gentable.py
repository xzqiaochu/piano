import math
import struct

amp = [1, 0.340, 0.102, 0.085, 0.070, 0.065, 0.028, 0.085,
       0.011, 0.030, 0.010, 0.014, 0.012, 0.013, 0.004]

s = sum(amp)
amp = [(item / s) for item in amp] # 归一化

THETA_WIDTH = 8
AM_WIDTH = 8
PI = 3.14159

wave = []
for theta in range(1 << THETA_WIDTH):
    a = 0
    for i in range(len(amp)):
        a += math.sin(2 * math.pi * (i + 1) * (theta / (1 << THETA_WIDTH))) * amp[i]
    wave.append(a)

x = (max(wave) - min(wave)) / ((1 << AM_WIDTH) - 2)
wave = [(round(item / x)) for item in wave]
        
with open("./src/dds.mem", "w") as f:
    for item in wave:
        data = struct.pack("b", item)
        f.write("%02X\n" % ord(data))
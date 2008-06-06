#! /usr/bin/python
from TOSSIM import *
from SecureKeyMsg import *
import sys

t = Tossim([])
m = t.mac();
r = t.radio()

t.addChannel("RadioCountToLedsC", sys.stdout)
t.addChannel("Boot", sys.stdout)

for i in range(0, 3):
  m = t.getNode(i);
  m.bootAtTime(12312221);  #(31 + t.ticksPerSecond() / 10) * i + 1);


f = open("../topo.txt", "r")
lines = f.readlines()
for line in lines:
  s = line.split()
  if (len(s) > 0):
    print " ", s[0], " ", s[1], " ", s[2];
    r.add(int(s[0]), int(s[1]), float(s[2]))


noise = open("../meyer-heavy.txt", "r")
lines = noise.readlines()
for line in lines:
  str = line.strip()
  if (str != ""):
    val = int(str)
    for i in range(0, 3):
      t.getNode(i).addNoiseTraceReading(val)

for i in range(0, 3):
  t.getNode(i).createNoiseModel()
  print "Creating noise model for ",i;
  

for i in range(0, 10):
  t.runNextEvent();

key = [0xb0,0x01,0x02,0x03,0x05,0x06,0x07,0x08,0x0A,0x0B,0x0C,0x0D,0x0F,0x10,0x11,0x12];
msg = SecureKeyMsg()
msg.set_crc(70);
msg.set_data(key);
pkt = t.newPacket();
pkt.setData(msg.data)
pkt.setType(msg.get_amType())
pkt.setDestination(0)
pkt.deliver(0, t.time())
msg.set_crc(40);
pkt = t.newPacket();
pkt.setData(msg.data)
pkt.setType(msg.get_amType())
pkt.setDestination(1)
pkt.deliver(1, t.time())


for i in range(0, 500):
  t.runNextEvent()

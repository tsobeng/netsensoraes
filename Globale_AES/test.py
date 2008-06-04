#! /usr/bin/python
from TOSSIM import *
from SecureKeyMsg import *
import sys

t = Tossim([])
r = t.radio()
f = open("../topo.txt", "r")
f_aes = open("aes.txt", "w")

lines = f.readlines()
for line in lines:
  s = line.split()
  if (len(s) > 0):
    print " ", s[0], " ", s[1], " ", s[2];
    r.add(int(s[0]), int(s[1]), float(s[2]))

t.addChannel("aes", sys.stdout); # f_aes)
t.addChannel("com", sys.stdout)
t.addChannel("sys", sys.stdout)

noise = open("../meyer-heavy.txt", "r")
lines = noise.readlines()
for line in lines:
  str = line.strip()
  if (str != ""):
    val = int(str)
    for i in range(1, 4):
      t.getNode(i).addNoiseTraceReading(val)

for i in range(1, 4):
  print "Creating noise model for ",i;
  t.getNode(i).createNoiseModel()

t.getNode(1).bootAtTime(100001);
t.getNode(2).bootAtTime(800008);
t.getNode(3).bootAtTime(1800009);

for i in range(0, 10):
  t.runNextEvent()

#Send the rigth key
key = [0x00,0x01,0x02,0x03,0x05,0x06,0x07,0x08,0x0A,0x0B,0x0C,0x0D,0x0F,0x10,0x11,0x12];
msg = SecureKeyMsg()
msg.set_key(key); 
pkt = t.newPacket();
pkt.setData(msg.data)
pkt.setType(msg.get_amType())
pkt.deliver(1, t.time() + 3)
pkt.deliver(2, t.time() + 3)

#Send a fake key
fake_key = [0x01,0x00,0x04,0x03,0x05,0x06,0x07,0x08,0x0A,0x0B,0x0C,0x0D,0x0F,0x10,0x11,0x12];
msg1 = SecureKeyMsg()
msg1.set_key(fake_key);
pkt1 = t.newPacket();
pkt1.setData(msg.data)
pkt1.setType(msg.get_amType())
pkt1.deliver(3, t.time() + 3)

for i in range(0, 300):
  t.runNextEvent()

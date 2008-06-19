#! /usr/bin/python
from TOSSIM import *
from SecureKeyMsg import *
import sys

t = Tossim([])
m = t.mac();
r = t.radio()

t.addChannel("aes", sys.stdout);
t.addChannel("com", sys.stdout)
t.addChannel("sys", sys.stdout)


for i in range(1, 4):
  m = t.getNode(i);
  m.bootAtTime(12312221)

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
    for i in range(1, 4):
      t.getNode(i).addNoiseTraceReading(val)

for i in range(1, 4):
  t.getNode(i).createNoiseModel()
  print "Creating noise model for ",i;


for i in range(0, 10):
  t.runNextEvent();

#Send the rigth key to the first two nodes
key = [0x00,0x01,0x02,0x03,0x05,0x06,0x07,0x08,0x0A,0x0B,0x0C,0x0D,0x0F,0x10,0x11,0x12];
msg = SecureKeyMsg()
msg.set_nodeid(0);
msg.set_IV(0);
msg.set_data(key); 
msg.set_crc(0);
pkt = t.newPacket();
pkt.setData(msg.data)
pkt.setType(msg.get_amType())
pkt.setDestination(1)
pkt.deliver(1, t.time()+1)
pkt = t.newPacket();
pkt.setData(msg.data)
pkt.setType(msg.get_amType())
pkt.setDestination(2)
pkt.deliver(2, t.time()+1)

#Send the wrong key to the thirth nodes (the man in the middle)
fake_key = [0xdd,0xa1,0x02,0x04,0x05,0xff,0x07,0x08,0x0A,0x0B,0x0C,0x0D,0x0F,0x10,0x11,0x12];
msg1 = SecureKeyMsg()
msg1.set_nodeid(0);
msg1.set_IV(999);
msg1.set_data(fake_key); 
msg1.set_crc(0);
pkt1 = t.newPacket();
pkt1.setData(msg1.data)
pkt1.setType(msg1.get_amType())
pkt1.setDestination(3)
pkt1.deliver(3, t.time()+1)

for i in range(0, 100):
  t.runNextEvent()


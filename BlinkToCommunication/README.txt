$Id: README.txt,v 1.4 2006/5/13  Exp $

README for Blink

Author/Contact:

  tinyos-help@millennium.berkeley.edu
Modified version:
  Roberto
  
Description:
	Application file for the BlinkToCommunicationHash application.  A counter is
	incremented and a radio message is sent whenever a timer fires.
	The counter is hashed and the hash value is transmitted with the message.
	Whenever a radio message is received, the hash is verified and the three least significant
	bits of the counter in the message payload are displayed on the
	LEDs.  Program two motes with this application.  As long as they
	are both within range of each other, the LEDs on both will keep
	changing.  If the LEDs on one (or both) of the nodes stops changing
	and hold steady, then that node is no longer receiving any messages
	from the other node.
	This application is derived from an initial code provided for the BlinkToRadio application.
	  
Tools:

  None

Known bugs/limitations:

  None.

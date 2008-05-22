#include <Timer.h>
#include "BlinkToCommunicationHash.h"
#include "aes.h"


module BlinkToCommunicationHashC {
  uses interface Boot;
  uses interface Leds;
  uses interface Timer<TMilli> as Timer0;
  uses interface Packet;
  uses interface AMPacket;
  uses interface AMSend;
  uses interface Receive;
  uses interface SplitControl as AMControl; // this is used to control the ActiveMessageC component

  uses interface AES;
}
implementation {

  uint16_t counter;
  uint8_t Isha[20];
  uint8_t tmp[20];
  uint8_t buf[2];
  uint8_t j;

  message_t pkt; // initialization of the packet 
  bool busy = FALSE; // variable used to control whether the channel si busy

  void setLeds(uint16_t val) {
    if (val & 0x01)
      call Leds.led0On();
    else 
      call Leds.led0Off();
    if (val & 0x02)
      call Leds.led1On();
    else
      call Leds.led1Off();
    if (val & 0x04)
      call Leds.led2On();
    else
      call Leds.led2Off();
  }

  event void Boot.booted() {
  	dbg("aes","Boot of the Application\n");
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) { // used to control weather the radio has been started successfully
      dbg("aes","Start the sending operation\n");
      call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
    }
    else {
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {
  }

  event void Timer0.fired() { // this code refers to the action that should be accomplished when the timer expires
    counter++;
    if (!busy) {
      BlinkToCommunicationAesMsg* btcpkt = 
	(BlinkToCommunicationAesMsg*)(call Packet.getPayload(&pkt, sizeof(BlinkToCommunicationAesMsg)));
      if (btcpkt == NULL) {
	return;
      }
      btcpkt->nodeid = TOS_NODE_ID;
      btcpkt->counter = counter;
      btcpkt->aesdata[0] = 22;
      btcpkt->aesdata[1] = 23;
      dbg("aes","Create the packet and set the data\n");

      if (call AMSend.send(AM_BROADCAST_ADDR, 
          &pkt, sizeof(BlinkToCommunicationAesMsg)) == SUCCESS) {
          dbg("aes","Sending packet\n");
        busy = TRUE;
      }
    }
  }

  event void AMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) { // used to verify that the intended message has been sent
      dbg("aes","Packet sent\n");
      busy = FALSE;
    }
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
    if (len == sizeof(BlinkToCommunicationAesMsg)) {
      BlinkToCommunicationAesMsg* btcpkt = (BlinkToCommunicationAesMsg*)payload;
      dbg("aes","Massage receive, value= %d - %d\n",btcpkt->aesdata[0],btcpkt->aesdata[1]);
    }
    return msg;
  }
}

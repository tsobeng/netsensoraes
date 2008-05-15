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
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) { // used to control weather the radio has been started successfully
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

      BlinkToCommunicationHashMsg* btcpkt = 
	(BlinkToCommunicationHashMsg*)(call Packet.getPayload(&pkt, sizeof(BlinkToCommunicationHashMsg)));
      if (btcpkt == NULL) {
	return;
      }
      btcpkt->nodeid = TOS_NODE_ID;
      btcpkt->counter = counter;

      if (call AMSend.send(AM_BROADCAST_ADDR, 
          &pkt, sizeof(BlinkToCommunicationHashMsg)) == SUCCESS) {
        busy = TRUE;
      }
    }
  }

  event void AMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) { // used to verify that the intended message has been sent
      busy = FALSE;
    }
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
    if (len == sizeof(BlinkToCommunicationHashMsg)) {
      BlinkToCommunicationHashMsg* btcpkt = (BlinkToCommunicationHashMsg*)payload;
    }
    return msg;
  }
}

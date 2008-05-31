#include <Timer.h>
#include "SecureComunication.h"
#include "aes.h"

module SecureComunicationC {
    uses interface Boot;
    uses interface Leds;
    uses interface Timer<TMilli> as Timer0;
    uses interface Packet;
    uses interface AMPacket;
    uses interface AMSend;
    uses interface Receive;
    uses interface SplitControl as AMControl;
    uses interface AES;
}
implementation {

  message_t packet;
  uint8_t k0,k1;

  bool locked;
  uint16_t counter = 0;
  
  event void Boot.booted() {
    call AMControl.start();
    dbg("sys","Boot of the Application\n");
  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      call Timer0.startPeriodic(250);
    }
    else {
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {
    // do nothing
  }
  
  event void Timer0.fired() {
    counter++;
    dbg("sys", "SecureComunicationC: timer fired, counter is %hu.\n", counter);
    if (locked) {
	dbg("sys","locket set to true, skip step\n");
      return;
    }
    else {
      SecureComunicationAesMsg* rcm = (SecureComunicationAesMsg*)call Packet.getPayload(&packet, sizeof(SecureComunicationAesMsg));
      if (rcm == NULL) {
	return;
      }
      //----------------------------------------
      //Section of packet encripting and setting
	
	  rcm->nodeid = TOS_NODE_ID;
      rcm->counter = counter;
      for(k0=0;k0<10;k0++){
		  rcm->data[k0]=k0*6; 
	  }
      
      //----------------------------------------
      if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(SecureComunicationAesMsg)) == SUCCESS) {
		dbg("com", "SecureComunicationC: packet sent.\n", counter);	
	locked = TRUE;
      }
    }
  }

  event message_t* Receive.receive(message_t* bufPtr, 
				   void* payload, uint8_t len) {
    dbg("com", "Received packet of length %hhu.\n", len);
    if (len != sizeof(SecureComunicationAesMsg)) {return bufPtr;}
    else {
      SecureComunicationAesMsg* rcm = (SecureComunicationAesMsg*)payload;

      dbg("com"," Receive %d \n", rcm->counter);
      //----------------------------------------
      //Section of packet dencripting and Extractions
      for(k1=0;k1<10;k1++)
      	dbg("aes", "Rec Value %d\n", rcm->data[k1]);

      
      //----------------------------------------
      return bufPtr;
    }
  }

  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
    if (&packet == bufPtr) {
      locked = FALSE;
      dbg("com", "Packet sent done\n");
    }
  }

}





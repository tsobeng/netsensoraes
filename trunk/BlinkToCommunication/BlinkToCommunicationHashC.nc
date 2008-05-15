// $Id: BlinkToCommunicationHashC.nc,v 1.5 2008/05/13 Exp $

/*
 * "Copyright (c) 2000-2006 The Regents of the University  of California.  
 * All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement is
 * hereby granted, provided that the above copyright notice, the following
 * two paragraphs and the author appear in all copies of this software.
 * 
 * IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
 * OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY OF
 * CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS."
 *
 */

/**
 * Application file for the BlinkToCommunicationHash application.  A counter is
 * incremented and a radio message is sent whenever a timer fires. 
 * The counter is hashed and the hash value is transmitted with the message.
 * Whenever a radio message is received, the hash is verified and the three least significant
 * bits of the counter in the message payload are displayed on the
 * LEDs.  Program two motes with this application.  As long as they
 * are both within range of each other, the LEDs on both will keep
 * changing.  If the LEDs on one (or both) of the nodes stops changing
 * and hold steady, then that node is no longer receiving any messages
 * from the other node.
 * This application is derived from an initial code provided for the BlinkToRadio application.
 *
 * @author Prabal Dutta
 * @modification Roberto Cascella
 * @date   May 13, 2008
 */
#include <Timer.h>
#include "BlinkToCommunicationHash.h"
#include "sha1.h"


module BlinkToCommunicationHashC {
  uses interface Boot;
  uses interface Leds;
  uses interface Timer<TMilli> as Timer0;
  uses interface Packet;
  uses interface AMPacket;
  uses interface AMSend;
  uses interface Receive;
  uses interface SplitControl as AMControl; // this is used to control the ActiveMessageC component

  uses interface SHA1;
}
implementation {

  uint16_t counter;
  uint8_t Isha[20];
  uint8_t tmp[20];
  uint8_t buf[2];
  uint8_t j;
  SHA1Context ctx; // definition of the SHA1 result

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

  void verifyLeds (uint16_t cnt,uint8_t h[20]) {
// initialization of the HASH function

    if( call SHA1.reset(&ctx) != 0) {
      return;
    }
    buf[0] = cnt & 0xf0;
    buf[1] = cnt & 0x1f;
    call SHA1.update(&ctx, buf, 2);

    if( call SHA1.digest(&ctx, Isha) !=0) {
      return;
    }
    for (j=0; j<20; j++){
        if (Isha[j]!=h[j]){
          return;
        }
     }

    setLeds(cnt);
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

// initialization of the HASH function
      
      if( call SHA1.reset(&ctx) != 0) {
         return;
      }
      buf[0] = counter & 0xf0;
      buf[1] = counter & 0x0f;
      call SHA1.update(&ctx, buf, 2);
    
      if( call SHA1.digest(&ctx, Isha) !=0) {
         return;
      }
      for (j=0; j<20; j++){
         btcpkt->hsha1[j] = Isha[j];
      }
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
      for (j=0; j<20; j++){
         tmp[j] = btcpkt->hsha1[j];
      }
      verifyLeds(btcpkt->counter, tmp);
    }
    return msg;
  }
}

/*
  Title: WSN - Secure comunications with AES algoritms
  Company: University of Trento - Faculty of Computer Science
  @author Nicola Manica (128851 - nicola.manica@gmail.com), 
          Matteo Saloni (130196 - matteo.saloni@gmail.com), 
          Toldo Paolo (128723 - paolo.toldo@gmail.com - www.paolotoldo.it)
*/
#include <Timer.h>
#include "SecureComunication.h"
#include "aes.h"

configuration SecureComunicationAppC {}
implementation {
  components MainC;
  components LedsC;
  components SecureComunicationC as App;
  components new TimerMilliC() as Timer0;
  components ActiveMessageC;
  components new AMSenderC(AM_SECUREKEYMSG_MSG);
  components new AMReceiverC(AM_SECUREKEYMSG_MSG);
  components AESM;

  //we wire here the used interfaces to the providing components
  App.Boot -> MainC;
  App.Leds -> LedsC;
  App.Timer0 -> Timer0;
  App.Packet -> AMSenderC;
  App.AMPacket -> AMSenderC;
  App.AMControl -> ActiveMessageC;
  App.AMSend -> AMSenderC;
  App.Receive -> AMReceiverC;
  App.AES -> AESM.AES;
}



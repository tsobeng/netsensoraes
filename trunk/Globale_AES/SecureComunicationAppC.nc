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
  components new AMSenderC(AM_SECURERADIO);
  components new AMReceiverC(AM_SECURERADIO);
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



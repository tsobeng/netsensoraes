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
  
  //Variable for the cryptography part
  //should use 1 buffer for saving memory
  unsigned char input[16]= {0x50,0x68,0x12,0xA4,0x5F,0x08,0xC8,0x89,0xB9,0x7F,0x59,0x80,0x03,0x8B,0x83,0x59};
  unsigned char output[16];
  int expandedKeySize,i;
  int size;
  unsigned char key[16] = {0x00,0x01,0x02,0x03,0x05,0x06,0x07,0x08,0x0A,0x0B,0x0C,0x0D,0x0F,0x10,0x11,0x12};
  unsigned char key_fake[16] = {0x02,0x02,0x02,0x03,0x04,0x06,0x07,0x08,0x0A,0x1B,0x0C,0x0D,0x0F,0x10,0x11,0x12};
  unsigned char expandedKey[176];
  unsigned char IV[16];
  int IV_i;
  int IV_size;
  uint16_t crc;
  
  

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
      rcm->IV = counter;
      
      //Stert the criptograpy part
       memset(input,0,16);
	   memset(output,0,16);
	   expandedKeySize = 176;
		input[0]=3;
	    input[1]=2;
    	input[2]=3;
	    input[3]=0xA4;
    	input[4]=0x5F;
	    input[5]=0x08;
    	input[6]=0xC8;
	    input[7]=0x89;
    	input[8]=0xB9;
	    input[9]=0x7F;
    	input[10]=0x59;
	    input[11]=0x80;
    	input[12]=0x03;
	    input[13]=0x8B;
    	input[14]=0x83;
   		input[15]=0x59;
   		
   		//Compute a sort of check sum
   		crc=0;
   		for(k0=0;k0<16;k0++){
   			crc = crc+input[k0];
   		}
   		rcm->crc = crc; //Set the check sum of the packet
   		//dbg("aes","Checksum... (%d - %d)\n",crc,rcm->crc);	
   		
   		/* the cipher key size */
   		 size = 16;

	    call AES.expandKey(expandedKey, key, size, expandedKeySize);
   		
        call AES.aes_encrypt(input, output, key, size);
   		
	  for(k0=0;k0<16;k0++){
		  rcm->data[k0]=output[k0]; 
	  }
	  
	  dbg("aes","Crypted Data:   ");
	  for(k0=0;k0<16;k0++){
      	printf("%3d ",rcm->data[k0]);
      }
      printf("\n");
      
      dbg("aes","Original:       ");
      for(k0=0;k0<16;k0++){
      	printf("%3d ",input[k0]);	
      }
      printf("\n");
      
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

      dbg("com","Receive %d \n", rcm->IV);
      //----------------------------------------
      //Section of packet dencripting and Extractions
      memset(input,0,16);
      memset(output,0,16);
      
      for(k0=0;k0<16;k0++){
		input[k0]=rcm->data[k0];
	  }
      
	  dbg("aes","From net:       ");
      for(k0=0;k0<16;k0++){
      	printf("%3d ",input[k0]);	
      }
      printf("\n");
      
   	  call AES.aes_decrypt(input, output, key, size);
      dbg("aes","Decrypted Data: ");
      
      for(k0=0;k0<16;k0++){
      	printf("%3d ",output[k0]);
      }
      printf("\n");
      //Compute the check sum of the decrypted data
      crc=0;
      for(k0=0;k0<16;k0++){
   			crc = crc+output[k0];
   	  }
   	  if(crc==rcm->crc){
	    dbg("aes","Correct decription");	
   	  	call Leds.led2On();
   	  	call Leds.led0Off();   	  	
   	  }else{
   	  	dbg("aes","Error in the decription (%d - %d)\n",crc,rcm->crc);	
   	  	call Leds.led0On();
   	  	call Leds.led2Off();
   	  }
   	  	
      
      printf("\n");
      
      
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





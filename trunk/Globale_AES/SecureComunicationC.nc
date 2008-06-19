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
  uint8_t comunication=0;
  uint8_t man_in_the_midle=0;
  
  //Variable for the cryptography part
  
  unsigned char IVbox[256] =   {
	  //0     1    2      3     4    5     6     7      8    9     A      B    C     D     E     F
	  0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08, //B
	  0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84, //4
	  0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76, //0
	  0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0, //1
	  0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15, //2
	  0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb, //9
	  0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a, //C
	  0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf, //5
	  0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75, //3
	  0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8, //6
	  0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf, //E
	  0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73, //8
	  0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79, //A
	  0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e, //D
	  0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2, //7
	  0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16 }; //F
  
  //should use 1 buffer for saving memory
  unsigned char input[16]= {0x50,0x68,0x12,0xA4,0x5F,0x08,0xC8,0x89,0xB9,0x7F,0x59,0x80,0x03,0x8B,0x83,0x59};
  unsigned char output[16];
  int expandedKeySize,i;
  int size = 16;
  unsigned char key[16]; // = {0x00,0x01,0x02,0x03,0x05,0x06,0x07,0x08,0x0A,0x0B,0x0C,0x0D,0x0F,0x10,0x11,0x12};
  unsigned char key_tmp[16];
  unsigned char IV[16];
  uint8_t IV_i;
  uint8_t pos;
  int IV_size;
  uint16_t crc;
  bool locked;
  uint16_t counter = 0;
  
  /* update key with value from IVbox */
  void updateKey(unsigned char *key1,unsigned char *key_temp,uint8_t iv) {
    pos=(iv % 16);
    key_temp[pos]=key1[pos]+IVbox[pos];
  }

  
  event void Boot.booted() {
    call AMControl.start();
    dbg("sys","Boot of the Application %d \n",TOS_NODE_ID);
  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
	  memset(key,0,16);
	  dbg("sys","Wating for the key\n");
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
  	if(comunication==0){ //If the key is not set return and tried the next time
  		dbg("aes","Key not set yet\n");
  		return;
  	}
  	if(man_in_the_midle==1)
  		return; //If is a man in the middle attack not able to send packet
    
    counter++;
    dbg("sys", "SecureComunicationC: timer fired, counter is %hu.\n", counter);
    if (locked) {
	dbg("sys","locket set to true, skip step\n");
      return;
    }
    else {
      sec_com_aes_msg_t* rcm = (sec_com_aes_msg_t*)call Packet.getPayload(&packet, sizeof(sec_com_aes_msg_t));
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
	   
	  //Input data to send to the other nodes
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
   		
   		//Compute the checksum
   		crc=0;
   		for(k0=0;k0<16;k0++){
   			crc = crc+input[k0];
   		}
   		rcm->crc = crc; //Set the check sum of the packet
   		//dbg("aes","Checksum... (%d - %d)\n",crc,rcm->crc);	
   		
   		/* the cipher key size */
   		size = 16;
   		 
   		/* use IV_i to change key */
	    IV_i=counter;
    	updateKey(key,key_tmp,IV_i);
    	
        call AES.aes_encrypt(input, output, key_tmp, size);
   		
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
      if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(sec_com_aes_msg_t)) == SUCCESS) {
		dbg("com", "SecureComunicationC: packet sent.\n", counter);	
	locked = TRUE;
      }
    }
  }

  event message_t* Receive.receive(message_t* bufPtr, 
				   void* payload, uint8_t len) {
    dbg("com", "Received packet of length %hhu.\n", len);
    
    //Setting the key for the comunication
    
    
    if (len != sizeof(sec_com_aes_msg_t)) {return bufPtr;}
    else {
      sec_com_aes_msg_t* rcm = (sec_com_aes_msg_t*)payload;
      
      if(rcm->crc == 0){ //If the node receive a packet with crc=0 that mean the packet contein the information of the key
    	dbg("aes","Key set: ");
    	for(k0=0;k0<16;k0++){
			key[k0]=rcm->data[k0];
	    }
	    for(k0=0;k0<16;k0++){
      	  printf("%3d ",key[k0]);	
        }
        printf("\n");
        if(rcm->IV==999) //If the IV is set to 999, that mean the receiver is a maninthemiddle (In that way, that node not transmit)
        	man_in_the_midle = 1;
	    comunication=1;
    	return bufPtr;
      }
      
      if(comunication!=1){
      	dbg("aes","Key not set yet: unable to decrypt the data\n");
      	return bufPtr;
      }
      

      dbg("com","Receive %d \n", rcm->nodeid);
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
      
      IV_i=rcm->IV;
      //printf("IV string:%i\n",IV_i);
      updateKey(key,key_tmp,IV_i);
      
   	  call AES.aes_decrypt(input, output, key_tmp, size);
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





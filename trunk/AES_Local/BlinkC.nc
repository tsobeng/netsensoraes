// $Id: BlinkC.nc,v 1.4 2006/12/12 18:22:48 vlahan Exp $

/*									tab:4
 * "Copyright (c) 2000-2005 The Regents of the University  of California.  
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
 * Copyright (c) 2002-2003 Intel Corporation
 * All rights reserved.
 *
 * This file is distributed under the terms in the attached INTEL-LICENSE     
 * file. If you do not find these files, copies can be found by writing to
 * Intel Research Berkeley, 2150 Shattuck Avenue, Suite 1300, Berkeley, CA, 
 * 94704.  Attention:  Intel License Inquiry.
 */

/**
 * Implementation for Blink application.  Toggle the red LED when a
 * Timer fires.
 **/

#include "Timer.h"
#include "aes.h"

module BlinkC
{
  uses interface Timer<TMilli> as Timer0;
  uses interface Leds;
  uses interface Boot;
  uses interface AES;
}
implementation
{
  //should use 1 buffer for saving memory
  unsigned char input[16]= {0x50,0x68,0x12,0xA4,0x5F,0x08,0xC8,0x89,0xB9,0x7F,0x59,0x80,0x03,0x8B,0x83,0x59};
  unsigned char output[16];
  int expandedKeySize,i;
  int size;
  unsigned char key[16] = {0x00,0x01,0x02,0x03,0x05,0x06,0x07,0x08,0x0A,0x0B,0x0C,0x0D,0x0F,0x10,0x11,0x12};
  unsigned char expandedKey[176];
  unsigned char IV[16];
  int IV_i;
  int IV_size;

  event void Boot.booted()
  {
    dbg("aes","Boot of the Application\n");
    //////////////////////////
     //TEST AND DEBUG
      
    
     // key should be inizialized..	
     memset(key,0,16);
     memset(input,0,16);
     memset(output,0,16);
     
    /* the expanded keySize */
    expandedKeySize = 176;



    /* the cipher key */
    //key = {0x00,0x01,0x02,0x03,0x05,0x06,0x07,0x08,0x0A,0x0B,0x0C,0x0D,0x0F,0x10,0x11,0x12};
    /* test string */
    //input = {0x50,0x68,0x12,0xA4,0x5F,0x08,0xC8,0x89,0xB9,0x7F,0x59,0x80,0x03,0x8B,0x83,0x59};
    //output = {0};

    key[0]=0x00;
    key[1]=0x01;
    key[2]=0x02;
    key[3]=0x03;
    key[4]=0x05;
    key[5]=0x06;
    key[6]=0x07;
    key[7]=0x08;
    key[8]=0x0A;
    key[9]=0x0B;
    key[10]=0x0C;
    key[11]=0x0D;
    key[12]=0x0F;
    key[13]=0x10;
    key[14]=0x11;
    key[15]=0x12;

    input[0]=0x50;
    input[1]=0x68;
    input[2]=0x12;
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

    /* the cipher key size */
    size = 16;

    call AES.expandKey(expandedKey, key, size, expandedKeySize);

    dbg("aes","Expanded Key:\n");
    for (i = 0; i < expandedKeySize; i++)
    {
            dbg("aes","%02x ", expandedKey[i]);
    }
    dbg("aes","\n");

    /* use IV_i to change key */
    memset(IV,0,16);
    IV_i=24591;
    IV_size = sprintf(IV, "%x", IV_i);
    /* add to key */
    for(i=0; i< IV_size; i++) {
	key[i]=key[i]+IV[i];
    }
    dbg("aes","IV string:%s\n",IV);

    /* the cipher key size */
    size = 16;

    call AES.expandKey(expandedKey, key, size, expandedKeySize);

    dbg("aes","Expanded Key:\n");
    for (i = 0; i < expandedKeySize; i++)
    {
            dbg("aes","%02x ", expandedKey[i]);
    }
    dbg("aes","\n");
   
    dbg("aes","Clean Data:\n");
    for (i = 0; i < 16; i++)
    {
            dbg("aes","%02x ", input[i]);
    }
    dbg("aes","\n");

    call AES.aes_encrypt(input, output, key, size);

    dbg("aes","Crypted Data:\n");
    for (i = 0; i < 16; i++)
    {
            dbg("aes","%02x ", output[i]);
    }
    dbg("aes","\n");
    memset(input,0,16);
    call AES.aes_decrypt(output, input, key, size);
    dbg("aes","Decrypted Data:\n");
    for (i = 0; i < 16; i++)
    {
            dbg("aes","%02x ", input[i]);
    }
    dbg("aes","\n");

     //TEST AND DEBUG
     ////////////////////////
     dbg("aes","AES test done.\n");
  }

  event void Timer0.fired()
  {
    dbg("BlinkC", "Timer 0 fired @ %s.\n", sim_time_string());
    call Leds.led0Toggle();

     
  }
  
}


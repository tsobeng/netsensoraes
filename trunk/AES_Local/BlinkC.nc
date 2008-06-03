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
  int size;
  unsigned char key[16] = {0x00,0x01,0x02,0x03,0x05,0x06,0x07,0x08,0x0A,0x0B,0x0C,0x0D,0x0F,0x10,0x11,0x12};
  unsigned char expandedKey[176];
  unsigned char IV[16];
  uint8_t IV_i;
  uint8_t pos;
  /* update key with value from IVbox */
  void updateKey(unsigned char *key,uint8_t iv) {
    pos=(iv % 16);
    key[pos]=key[pos]+IVbox[pos];
  }

  event void Boot.booted()
  {
    printf("Boot of the Application\n");
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

    printf("Expanded Key:\n");
    for (i = 0; i < expandedKeySize; i++)
    {
            printf("%02x ", expandedKey[i]);
    }
    printf("\n");

    /* use IV_i to change key */
    IV_i=17;
    printf("IV string:%i\n",IV_i);
    updateKey(key,IV_i);
    /* the cipher key size */
    size = 16;

    call AES.expandKey(expandedKey, key, size, expandedKeySize);

    printf("Expanded Key:\n");
    for (i = 0; i < expandedKeySize; i++)
    {
            printf("%02x ", expandedKey[i]);
    }
    printf("\n");
     /* use IV_i to change key */
    IV_i=33;
    printf("IV string:%i\n",IV_i);
    updateKey(key,IV_i);
    /* the cipher key size */
    size = 16;

    call AES.expandKey(expandedKey, key, size, expandedKeySize);

    printf("Expanded Key:\n");
    for (i = 0; i < expandedKeySize; i++)
    {
            printf("%02x ", expandedKey[i]);
    }
    printf("\n");
 /* use IV_i to change key */
    IV_i=49;
    printf("IV string:%i\n",IV_i);
    updateKey(key,IV_i);
    /* the cipher key size */
    size = 16;

    call AES.expandKey(expandedKey, key, size, expandedKeySize);

    printf("Expanded Key:\n");
    for (i = 0; i < expandedKeySize; i++)
    {
            printf("%02x ", expandedKey[i]);
    }
    printf("\n");
 /* use IV_i to change key */
    IV_i=65;
    printf("IV string:%i\n",IV_i);
    updateKey(key,IV_i);
    /* the cipher key size */
    size = 16;

    call AES.expandKey(expandedKey, key, size, expandedKeySize);

    printf("Expanded Key:\n");
    for (i = 0; i < expandedKeySize; i++)
    {
            printf("%02x ", expandedKey[i]);
    }
    printf("\n");  
    printf("Clean Data:\n");
    for (i = 0; i < 16; i++)
    {
            printf("%02x ", input[i]);
    }
    printf("\n");

    call AES.aes_encrypt(input, output, key, size);

    printf("Crypted Data:\n");
    for (i = 0; i < 16; i++)
    {
            printf("%02x ", output[i]);
    }
    printf("\n");
    memset(input,0,16);
    call AES.aes_decrypt(output, input, key, size);
    printf("Decrypted Data:\n");
    for (i = 0; i < 16; i++)
    {
            printf("%02x ", input[i]);
    }
    printf("\n");

     //TEST AND DEBUG
     ////////////////////////
     printf("AES test done.\n");
  }

  event void Timer0.fired()
  {
    dbg("BlinkC", "Timer 0 fired @ %s.\n", sim_time_string());
    call Leds.led0Toggle();

     
  }
  
}


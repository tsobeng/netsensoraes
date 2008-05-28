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
  aes_context context;
  unsigned char key[128];
  //should use 1 buffer for saving memory
  unsigned char buffer_crypt[16];
  unsigned char buffer_decrypt[16];
  event void Boot.booted()
  {
    dbg("aes","Boot of the Application\n");
    //////////////////////////
     //TEST AND DEBUG
      
    
     // key should be inizialized..	
     memset(key,0,128);
     //use static key c4c3cd5eeaf44520609947503a7aa9ed1cffe019426ec40cdfd0d328bfa6b48c8e1985aa9f52b0f6e5ffb110ae641701beb466c9d713a995aad65b595ee5d988
     strncpy(key,"c4c3cd5eeaf44520609947503a7aa9ed1cffe019426ec40cdfd0d328bfa6b48c8e1985aa9f52b0f6e5ffb110ae641701beb466c9d713a995aad65b595ee5d988",128);
     call AES.aes_set_key_enc(&context,key,128);
     call AES.aes_set_key_dec(&context,key,128);
     //crypt to buffer_crypt input
     call AES.aes_enc(&context,"test_data_16char",buffer_crypt);
     //decrypt to buffer_decrypt
     call AES.aes_dec(&context,buffer_crypt,buffer_decrypt);
     dbg("aes","Decrypted string is : %s\n",buffer_decrypt);
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


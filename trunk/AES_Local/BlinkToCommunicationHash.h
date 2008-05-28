// $Id: BlinkToCommunicationHash.h,v 1.0 2008/05/13 Exp $

#ifndef BLINKTOCOMMUNICATIONHASH_H
#define BLINKTOCOMMUNICATIONHASH_H

enum {
  AM_BLINKTORADIO = 6,
  AM_BLINKTOHASH = 11,
  TIMER_PERIOD_MILLI = 250
};


typedef nx_struct BlinkToCommunicationAesMsg {
  nx_uint16_t nodeid;
  nx_uint16_t counter;
  nx_uint8_t aesdata[20]; 
} BlinkToCommunicationAesMsg;

// the nx_ means that these are external types
#endif

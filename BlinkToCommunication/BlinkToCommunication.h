// $Id: BlinkToRadio.h,v 1.4 2006/12/12 18:22:52 vlahan Exp $

#ifndef BLINKTOCOMMUNICATION_H
#define BLINKTOCOMMUNICATION_H

enum {
  AM_BLINKTORADIO = 6,
  TIMER_PERIOD_MILLI = 250
};

typedef nx_struct BlinkToCommunicationMsg {
  nx_uint16_t nodeid;
  nx_uint16_t counter;
} BlinkToCommunicationMsg;


#endif

// the nx_ means that these are external types
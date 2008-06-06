#ifndef SECURECOMUNICATION_H
#define SECURECOMUNICATION_H

typedef nx_struct securekeymsg_msg{
  nx_uint16_t nodeid;
  nx_uint16_t IV;
  nx_uint8_t data[16];
  nx_uint16_t crc;
} sec_com_aes_msg_t;

enum {
  AM_BLINKTORADIO = 6,
  AM_SECUREKEYMSG_MSG = 11,
  TIMER_PERIOD_MILLI = 250
};

#endif

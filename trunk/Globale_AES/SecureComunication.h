#ifndef SECURECOMUNICATION_H
#define SECURECOMUNICATION_H

typedef nx_struct SecureComunicationAesMsg{
  nx_uint16_t nodeid;
  nx_uint16_t IV;
  nx_uint8_t data[16];
  nx_uint16_t crc;
  //nx_uint8_t data1[8];
} SecureComunicationAesMsg;


enum {
  AM_BLINKTORADIO = 6,
  AM_SECURERADIO = 11,
  TIMER_PERIOD_MILLI = 250
};

#endif

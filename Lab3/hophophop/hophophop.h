#ifndef HOPHOPHOP_H
#define HOPHOPHOP_H

enum {
  AM_BLINKTORADIO = 6,
  TIMER_PERIOD_MILLI = 250
};

typedef nx_struct hophophopMsg {
  nx_uint16_t nodeid;
  nx_uint16_t counter;
} hophophopMsg;

#endif

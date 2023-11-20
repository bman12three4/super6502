#ifndef _RTC_H
#define _RTC_H

#include <stdint.h>

#define RTC_CMD_ADDR    0xeffe
#define RTC_DAT_ADDR    0xefff

/* initialize RTC with default values */
void init_rtc(void);

/* handle RTC interrupts */
void handle_rtc(void);


#endif
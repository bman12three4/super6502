#ifndef _RTC_H
#define _RTC_H

#include <stdint.h>

#define RTC_CMD_ADDR    0xeffe
#define RTC_DAT_ADDR    0xefff

#define RTC_THRESHOLD       0x00
#define RTC_INCREMENT       0x10
#define RTC_IRQ_THRESHOLD   0x20
#define RTC_OUTPUT          0x30
#define RTC_CONTROL         0x30

/* initialize RTC with default values */
void init_rtc(void);

/* handle RTC interrupts */
void handle_rtc(void);


void rtc_set(uint32_t val, uint8_t idx);


#endif
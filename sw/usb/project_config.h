/* Project name project configuration file	*/

#ifndef _project_config_h_
#define _project_config_h_

#include "GenericMacros.h"
#include "GenericTypeDefs.h"
#include "HID.h"
#include "MAX3421E.h"
#include "transfer.h"
#include "usb_ch9.h"
#include "USB.h"

/* USB constants */
/* time in milliseconds */
#define USB_SETTLE_TIME 					200         //USB settle after reset
#define USB_XFER_TIMEOUT					5000        //USB transfer timeout

#define USB_NAK_LIMIT 2
#define USB_RETRY_LIMIT 3

#endif // _project_config_h

#include <conio.h>

#include "sd_print.h"
#include "sd_card.h"

/*
void SD_printR1(uint8_t res)
{
    if(res == 0xFF)
        { cputs("\tNo response\r\n"); return; }
    if(res & 0x80)
        { cputs("\tError: MSB = 1\r\n"); return; }
    if(res == 0)
        { cputs("\tCard Ready\r\n"); return; }
    if(PARAM_ERROR(res))
        cputs("\tParameter Error\r\n");
    if(ADDR_ERROR(res))
        cputs("\tAddress Error\r\n");
    if(ERASE_SEQ_ERROR(res))
        cputs("\tErase Sequence Error\r\n");
    if(CRC_ERROR(res))
        cputs("\tCRC Error\r\n");
    if(ILLEGAL_CMD(res))
        cputs("\tIllegal Command\r\n");
    if(ERASE_RESET(res))
        cputs("\tErase Reset Error\r\n");
    if(IN_IDLE(res))
        cputs("\tIn Idle State\r\n");
}
*/

/*
void SD_printR2(uint8_t *res)
{
    SD_printR1(res[0]);

    if(res[0] == 0xFF) return;

    if(res[1] == 0x00)
        cputs("\tNo R2 Error\r\n");
    if(OUT_OF_RANGE(res[1]))
        cputs("\tOut of Range\r\n");
    if(ERASE_PARAM(res[1]))
        cputs("\tErase Parameter\r\n");
    if(WP_VIOLATION(res[1]))
        cputs("\tWP Violation\r\n");
    if(CARD_ECC_FAILED(res[1]))
        cputs("\tECC Failed\r\n");
    if(CC_ERROR(res[1]))
        cputs("\tCC Error\r\n");
    if(ERROR(res[1]))
        cputs("\tError\r\n");
    if(WP_ERASE_SKIP(res[1]))
        cputs("\tWP Erase Skip\r\n");
    if(CARD_LOCKED(res[1]))
        cputs("\tCard Locked\r\n");
}
*/

/*
void SD_printR3(uint8_t *res)
{
    SD_printR1(res[0]);

    if(res[0] > 1) return;

    cputs("\tCard Power Up Status: ");
    if(POWER_UP_STATUS(res[1]))
    {
        cputs("READY\r\n");
        cputs("\tCCS Status: ");
        if(CCS_VAL(res[1])){ cputs("1\r\n"); }
        else cputs("0\r\n");
    }
    else
    {
        cputs("BUSY\r\n");
    }

    cputs("\tVDD Window: ");
    if(VDD_2728(res[3])) cputs("2.7-2.8, ");
    if(VDD_2829(res[2])) cputs("2.8-2.9, ");
    if(VDD_2930(res[2])) cputs("2.9-3.0, ");
    if(VDD_3031(res[2])) cputs("3.0-3.1, ");
    if(VDD_3132(res[2])) cputs("3.1-3.2, ");
    if(VDD_3233(res[2])) cputs("3.2-3.3, ");
    if(VDD_3334(res[2])) cputs("3.3-3.4, ");
    if(VDD_3435(res[2])) cputs("3.4-3.5, ");
    if(VDD_3536(res[2])) cputs("3.5-3.6");
    cputs("\r\n");
}
*/

/*
void SD_printR7(uint8_t *res)
{
    SD_printR1(res[0]);

    if(res[0] > 1) return;

    cputs("\tCommand Version: ");
    cprintf("%x", CMD_VER(res[1]));
    cputs("\r\n");

    cputs("\tVoltage Accepted: ");
    if(VOL_ACC(res[3]) == VOLTAGE_ACC_27_33) {
        cputs("2.7-3.6V\r\n");
    } else if(VOL_ACC(res[3]) == VOLTAGE_ACC_LOW) {
        cputs("LOW VOLTAGE\r\n");
    } else if(VOL_ACC(res[3]) == VOLTAGE_ACC_RES1) {
        cputs("RESERVED\r\n");
	} else if(VOL_ACC(res[3]) == VOLTAGE_ACC_RES2) {
        cputs("RESERVED\r\n");
	} else {
        cputs("NOT DEFINED\r\n");
	}

    cputs("\tEcho: ");
    cprintf("%x", res[4]);
    cputs("\r\n");
}
*/

/*
void SD_printCSD(uint8_t *buf)
{
    cputs("CSD:\r\n");

    cputs("\tCSD Structure: ");
    cprintf("%x", (buf[0] & 0b11000000) >> 6);
    cputs("\r\n");

    cputs("\tTAAC: ");
    cprintf("%x", buf[1]);
    cputs("\r\n");

    cputs("\tNSAC: ");
    cprintf("%x", buf[2]);
    cputs("\r\n");

    cputs("\tTRAN_SPEED: ");
    cprintf("%x", buf[3]);
    cputs("\r\n");

    cputs("\tDevice Size: ");
    cprintf("%x", buf[7] & 0b00111111);
    cprintf("%x", buf[8]);
    cprintf("%x", buf[9]);
    cputs("\r\n");
}
*/

void SD_printBuf(uint8_t *buf)
{
    uint8_t colCount = 0;
    uint16_t i;
    for(i = 0; i < SD_BLOCK_LEN; i++)
    {
        cprintf("%2x", *buf++);
        if(colCount == 19)
        {
            cputs("\r\n");
            colCount = 0;
        }
        else
        {
            cputc(' ');
            colCount++;
        }
    }
    cputs("\r\n");
}

/*
void SD_printDataErrToken(uint8_t token)
{
    if(token & 0xF0)
        cputs("\tNot Error token\r\n");
    if(SD_TOKEN_OOR(token))
        cputs("\tData out of range\r\n");
    if(SD_TOKEN_CECC(token))
        cputs("\tCard ECC failed\r\n");
    if(SD_TOKEN_CC(token))
        cputs("\tCC Error\r\n");
    if(SD_TOKEN_ERROR(token))
        cputs("\tError\r\n");
}
*/
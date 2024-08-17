/**************************************************************************
*
*    File Name:  sdr.v  
*      Version:  2.2
*         Date:  October 12th, 2010
*        Model:  BUS Functional
*    Simulator:  Model Technology
*
* Dependencies:  None
*
*        Email:  modelsupport@micron.com
*      Company:  Micron Technology, Inc.
*
*  Description:  Micron SDRAM Verilog model
*
*   Limitation:  - Doesn't check for refresh timing
*
*         Note:  - Set simulator resolution to "ps" accuracy
*                - Set Debug = 0 to disable $display messages
*
*   Disclaimer:  THESE DESIGNS ARE PROVIDED "AS IS" WITH NO WARRANTY 
*                WHATSOEVER AND MICRON SPECIFICALLY DISCLAIMS ANY 
*                IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR
*                A PARTICULAR PURPOSE, OR AGAINST INFRINGEMENT.
*
*                Copyright � 2001 Micron Semiconductor Products, Inc.
*                All rights researved
*
* Rev  Author          Date        Changes
* ---  --------------------------  ---------------------------------------
* 2.3  SH              05/12/2016  - Update tAC, tHZ timing
*      Micron Technology Inc.
*
* 2.2  SH              10/12/2010  - Combine all parts into sdr_parameters.vh
*      Micron Technology Inc.
*
* 2.1  SH              06/06/2002  - Typo in bank multiplex
*      Micron Technology Inc.
*
* 2.0  SH              04/30/2002  - Second release
*      Micron Technology Inc.
*
**************************************************************************/

`timescale 1ns / 1ps
`define x8
`define CLK_200
`define SYS_CLK_100

module generic_sdr (Dq, Addr, Ba, Clk, Cke, Cs_n, Ras_n, Cas_n, We_n, Dqm);
	
`include "include/sdram_controller_define.vh"

parameter tCK              =     1000/fCK_MHz; // tCK    ns    Nominal Clock Cycle Time
`ifdef CLK_200
    parameter real tAC3             =     4.5; // tAC3   ns    Access time from CLK (pos edge) CL = 3
    parameter real tAC2             =     4.5; // tAC2   ns    Access time from CLK (pos edge) CL = 2
    parameter real tAC1             =     4.5; // tAC1   ns    Parameter definition for compilation - CL = 1 illegal for sg75
`elsif CLK_166
    parameter real tAC3             =     5.4; // tAC3   ns    Access time from CLK (pos edge) CL = 3
    parameter real tAC2             =     5.4; // tAC2   ns    Access time from CLK (pos edge) CL = 2
    parameter real tAC1             =     5.4; // tAC1   ns    Parameter definition for compilation - CL = 1 illegal for sg75
`elsif CLK_133
    parameter real tAC3             =     6.0; // tAC3   ns    Access time from CLK (pos edge) CL = 3
    parameter real tAC2             =     6.0; // tAC2   ns    Access time from CLK (pos edge) CL = 2
    parameter real tAC1             =     6.0; // tAC1   ns    Parameter definition for compilation - CL = 1 illegal for sg75
`endif    
    
`ifdef CLK_200
    parameter real tHZ3             =     4.5; // tHZ3   ns    Data Out High Z time - CL = 3
    parameter real tHZ2             =     4.5; // tHZ2   ns    Data Out High Z time - CL = 2
    parameter real tHZ1             =     4.5; // tHZ1   ns    Parameter definition for compilation - CL = 1 illegal for sg75
`elsif CLK_166
    parameter real tHZ3             =     5.4; // tHZ3   ns    Data Out High Z time - CL = 3
    parameter real tHZ2             =     5.4; // tHZ2   ns    Data Out High Z time - CL = 2
    parameter real tHZ1             =     5.4; // tHZ1   ns    Parameter definition for compilation - CL = 1 illegal for sg75
`elsif CLK_133
    parameter real tHZ3             =     6.0; // tHZ3   ns    Data Out High Z time - CL = 3
    parameter real tHZ2             =     6.0; // tHZ2   ns    Data Out High Z time - CL = 2
    parameter real tHZ1             =     6.0; // tHZ1   ns    Parameter definition for compilation - CL = 1 illegal for sg75
`endif

parameter tOH              =     2.7; // tOH    ns    Data Out Hold time
parameter tRRD             =     2.0; // tRRD   tCK   Active bank a to Active bank b command time (2 * tCK)
parameter tWRa             =     tCK; // tWR    ns    Write recovery time (auto-precharge mode - must add 1 CLK)
parameter tWRm             =   2*tCK; // tWR    ns    Write recovery time	
parameter ADDR_BITS        = ROW_WIDTH; // Set this parameter to control how many Address bits are used
parameter ROW_BITS         = ROW_WIDTH; // Set this parameter to control how many Row bits are used
parameter COL_BITS         = COL_WIDTH; // Set this parameter to control how many Column bits are used
parameter DQ_BITS          = DQ_WIDTH; // Set this parameter to control how many Data bits are used
parameter DM_BITS          = 1; // Set this parameter to control how many DM bits are used
parameter BA_BITS          = BA_WIDTH; // Bank bits
parameter mem_sizes        = 2**(ROW_BITS+COL_BITS) - 1;

    input                         Clk;
    input                         Cke;
    input                         Cs_n;
    input                         Ras_n;
    input                         Cas_n;
    input                         We_n;
    input     [ADDR_BITS - 1 : 0] Addr;
    input       [BA_BITS - 1 : 0] Ba;
    inout       [DQ_BITS - 1 : 0] Dq;
    input       [DM_BITS - 1 : 0] Dqm;

endmodule

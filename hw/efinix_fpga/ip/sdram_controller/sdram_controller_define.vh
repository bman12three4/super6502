// =============================================================================
// Generated by efx_ipmgr
// Version: 2023.1.150
// IP Version: 5.0
// =============================================================================

////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2023 Efinix Inc. All rights reserved.              
//
// This   document  contains  proprietary information  which   is        
// protected by  copyright. All rights  are reserved.  This notice       
// refers to original work by Efinix, Inc. which may be derivitive       
// of other work distributed under license of the authors.  In the       
// case of derivative work, nothing in this notice overrides the         
// original author's license agreement.  Where applicable, the           
// original license agreement is included in it's original               
// unmodified form immediately below this header.                        
//                                                                       
// WARRANTY DISCLAIMER.                                                  
//     THE  DESIGN, CODE, OR INFORMATION ARE PROVIDED “AS IS” AND        
//     EFINIX MAKES NO WARRANTIES, EXPRESS OR IMPLIED WITH               
//     RESPECT THERETO, AND EXPRESSLY DISCLAIMS ANY IMPLIED WARRANTIES,  
//     INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF          
//     MERCHANTABILITY, NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR    
//     PURPOSE.  SOME STATES DO NOT ALLOW EXCLUSIONS OF AN IMPLIED       
//     WARRANTY, SO THIS DISCLAIMER MAY NOT APPLY TO LICENSEE.           
//                                                                       
// LIMITATION OF LIABILITY.                                              
//     NOTWITHSTANDING ANYTHING TO THE CONTRARY, EXCEPT FOR BODILY       
//     INJURY, EFINIX SHALL NOT BE LIABLE WITH RESPECT TO ANY SUBJECT    
//     MATTER OF THIS AGREEMENT UNDER TORT, CONTRACT, STRICT LIABILITY   
//     OR ANY OTHER LEGAL OR EQUITABLE THEORY (I) FOR ANY INDIRECT,      
//     SPECIAL, INCIDENTAL, EXEMPLARY OR CONSEQUENTIAL DAMAGES OF ANY    
//     CHARACTER INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF      
//     GOODWILL, DATA OR PROFIT, WORK STOPPAGE, OR COMPUTER FAILURE OR   
//     MALFUNCTION, OR IN ANY EVENT (II) FOR ANY AMOUNT IN EXCESS, IN    
//     THE AGGREGATE, OF THE FEE PAID BY LICENSEE TO EFINIX HEREUNDER    
//     (OR, IF THE FEE HAS BEEN WAIVED, $100), EVEN IF EFINIX SHALL HAVE 
//     BEEN INFORMED OF THE POSSIBILITY OF SUCH DAMAGES.  SOME STATES DO 
//     NOT ALLOW THE EXCLUSION OR LIMITATION OF INCIDENTAL OR            
//     CONSEQUENTIAL DAMAGES, SO THIS LIMITATION AND EXCLUSION MAY NOT   
//     APPLY TO LICENSEE.                                                
//
////////////////////////////////////////////////////////////////////////////////

localparam fSYS_MHz = 100;
localparam fCK_MHz = 200;
localparam tIORT_u = 2;
localparam CL = 3;
localparam BL = 1;
localparam DDIO_TYPE = "SOFT";
localparam DQ_WIDTH = 8;
localparam DQ_GROUP = 2;
localparam BA_WIDTH = 2;
localparam ROW_WIDTH = 13;
localparam COL_WIDTH = 9;
localparam tPWRUP = 200000;
localparam tRAS = 44;
localparam tRAS_MAX = 120000;
localparam tRC = 66;
localparam tRCD = 20;
localparam tREF = 64000000;
localparam tRFC = 66;
localparam tRP = 20;
localparam tWR = 2;
localparam tMRD = 2;
localparam SDRAM_MODE = "Native";
localparam DATA_RATE = 2;
localparam AXI_AWADDR_WIDTH = 24;
localparam AXI_WDATA_WIDTH = 32;
localparam AXI_ARADDR_WIDTH = 24;
localparam AXI_RDATA_WIDTH = 32;
localparam AXI_AWID_WIDTH = 4;
localparam AXI_AWUSER_WIDTH = 2;
localparam AXI_WUSER_WIDTH = 2;
localparam AXI_BID_WIDTH = 4;
localparam AXI_BUSER_WIDTH = 2;
localparam AXI_ARID_WIDTH = 4;
localparam AXI_ARUSER_WIDTH = 3;
localparam AXI_RUSER_WIDTH = 3;

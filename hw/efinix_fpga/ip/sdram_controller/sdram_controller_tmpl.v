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

sdram_controller u_sdram_controller(
.i_we ( i_we ),
.i_sysclk ( i_sysclk ),
.i_arst ( i_arst ),
.i_sdrclk ( i_sdrclk ),
.i_tACclk ( i_tACclk ),
.i_pll_locked ( i_pll_locked ),
.i_re ( i_re ),
.i_last ( i_last ),
.o_dbg_tRTW_done ( o_dbg_tRTW_done ),
.o_dbg_ref_req ( o_dbg_ref_req ),
.o_dbg_wr_ack ( o_dbg_wr_ack ),
.o_dbg_rd_ack ( o_dbg_rd_ack ),
.o_dbg_n_CS ( o_dbg_n_CS ),
.o_dbg_n_RAS ( o_dbg_n_RAS ),
.o_dbg_n_CAS ( o_dbg_n_CAS ),
.o_dbg_n_WE ( o_dbg_n_WE ),
.o_dbg_BA ( o_dbg_BA ),
.o_dbg_ADDR ( o_dbg_ADDR ),
.o_dbg_DATA_out ( o_dbg_DATA_out ),
.o_dbg_DATA_in ( o_dbg_DATA_in ),
.i_addr ( i_addr ),
.i_din ( i_din ),
.i_dm ( i_dm ),
.o_dout ( o_dout ),
.o_sdr_state ( o_sdr_state ),
.o_sdr_init_done ( o_sdr_init_done ),
.o_wr_ack ( o_wr_ack ),
.o_rd_ack ( o_rd_ack ),
.o_ref_req ( o_ref_req ),
.o_rd_valid ( o_rd_valid ),
.o_sdr_CKE ( o_sdr_CKE ),
.o_sdr_n_CS ( o_sdr_n_CS ),
.o_sdr_n_RAS ( o_sdr_n_RAS ),
.o_sdr_n_CAS ( o_sdr_n_CAS ),
.o_sdr_n_WE ( o_sdr_n_WE ),
.o_sdr_BA ( o_sdr_BA ),
.o_sdr_ADDR ( o_sdr_ADDR ),
.o_sdr_DATA ( o_sdr_DATA ),
.o_sdr_DATA_oe ( o_sdr_DATA_oe ),
.i_sdr_DATA ( i_sdr_DATA ),
.o_sdr_DQM ( o_sdr_DQM ),
.o_dbg_dly_cnt_b ( o_dbg_dly_cnt_b ),
.o_dbg_tRCD_done ( o_dbg_tRCD_done )
);

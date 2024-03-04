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
.i_aresetn ( i_aresetn ),
.i_AXI4_AWADDR ( i_AXI4_AWADDR ),
.i_sysclk ( i_sysclk ),
.i_sdrclk ( i_sdrclk ),
.i_tACclk ( i_tACclk ),
.i_pll_locked ( i_pll_locked ),
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
.o_pll_reset ( o_pll_reset ),
.o_AXI4_AWREADY ( o_AXI4_AWREADY ),
.i_AXI4_AWVALID ( i_AXI4_AWVALID ),
.o_AXI4_WREADY ( o_AXI4_WREADY ),
.i_AXI4_WDATA ( i_AXI4_WDATA ),
.i_AXI4_WSTRB ( i_AXI4_WSTRB ),
.i_AXI4_WLAST ( i_AXI4_WLAST ),
.i_AXI4_WVALID ( i_AXI4_WVALID ),
.o_AXI4_BVALID ( o_AXI4_BVALID ),
.i_AXI4_BREADY ( i_AXI4_BREADY ),
.o_AXI4_ARREADY ( o_AXI4_ARREADY ),
.i_AXI4_ARADDR ( i_AXI4_ARADDR ),
.i_AXI4_RREADY ( i_AXI4_RREADY ),
.o_AXI4_RDATA ( o_AXI4_RDATA ),
.o_AXI4_RLAST ( o_AXI4_RLAST ),
.o_AXI4_RVALID ( o_AXI4_RVALID ),
.i_AXI4_AWID ( i_AXI4_AWID ),
.i_AXI4_AWSIZE ( i_AXI4_AWSIZE ),
.i_AXI4_ARVALID ( i_AXI4_ARVALID ),
.i_AXI4_ARID ( i_AXI4_ARID ),
.i_AXI4_ARLEN ( i_AXI4_ARLEN ),
.i_AXI4_ARSIZE ( i_AXI4_ARSIZE ),
.i_AXI4_ARBURST ( i_AXI4_ARBURST ),
.i_AXI4_AWLEN ( i_AXI4_AWLEN ),
.o_AXI4_RID ( o_AXI4_RID ),
.o_dbg_we ( o_dbg_we ),
.o_dbg_last ( o_dbg_last ),
.o_dbg_addr ( o_dbg_addr ),
.o_dbg_din ( o_dbg_din ),
.o_axi4_wrstate ( o_axi4_wrstate ),
.o_fifo_wr ( o_fifo_wr ),
.o_fifo_full ( o_fifo_full ),
.o_fifo_empty ( o_fifo_empty ),
.o_dbg_fifo_waddr ( o_dbg_fifo_waddr ),
.o_dbg_fifo_re ( o_dbg_fifo_re ),
.o_dbg_fifo_raddr ( o_dbg_fifo_raddr ),
.o_dbg_fifo_we ( o_dbg_fifo_we ),
.o_dbg_axi4_wlast ( o_dbg_axi4_wlast ),
.o_shift_cnt ( o_shift_cnt ),
.o_re_lock ( o_re_lock ),
.o_axi4_rastate ( o_axi4_rastate ),
.o_axi4_nwr ( o_axi4_nwr ),
.o_axi4_arlen ( o_axi4_arlen ),
.o_axi4_rdstate ( o_axi4_rdstate ),
.o_sdr_rd_valid ( o_sdr_rd_valid ),
.o_sdr_dout ( o_sdr_dout ),
.o_dbg_re ( o_dbg_re ),
.o_AXI4_BID ( o_AXI4_BID ),
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
.o_sdr_DQM ( o_sdr_DQM )
);

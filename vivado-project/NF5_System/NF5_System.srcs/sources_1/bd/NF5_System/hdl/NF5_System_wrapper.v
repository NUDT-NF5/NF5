//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.2 (lin64) Build 2258646 Thu Jun 14 20:02:38 MDT 2018
//Date        : Sat Jan 30 22:23:51 2021
//Host        : ubuntu running 64-bit Ubuntu 16.04.7 LTS
//Command     : generate_target NF5_System_wrapper.bd
//Design      : NF5_System_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module NF5_System_wrapper
   (clk_0,
    rst_n_0);
  input clk_0;
  input rst_n_0;

  wire clk_0;
  wire rst_n_0;

  NF5_System NF5_System_i
       (.clk_0(clk_0),
        .rst_n_0(rst_n_0));
endmodule

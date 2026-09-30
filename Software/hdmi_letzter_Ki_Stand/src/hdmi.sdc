//Copyright (C)2014-2021 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//GOWIN Version: 1.9.8
//Created Time: 2021-11-11 12:48:43
create_clock -name clk_osc -period 37.037 -waveform {0 18.518} [get_ports {clk}]
create_clock -name rgb_pclk -period 41.667 -waveform {0 20.833} [get_ports {rgb_pclk}]
// output clocks from the 24 MHz reference: 180 MHz serial, 36 MHz pixel clock
create_clock -name clk_ref24 -period 41.667 -waveform {0 20.833} [get_pins {u_pll_test/rpll_inst/CLKOUTD3}]
create_clock -name clk_p5 -period 5.556 -waveform {0 2.778} [get_pins {u_pll/rpll_inst/CLKOUT}]
create_generated_clock -name clk_p -source [get_pins {u_pll/rpll_inst/CLKOUT}] -master_clock clk_p5 -divide_by 5 [get_pins {u_div_5/clkdiv_inst/CLKOUT}]

// all domain crossings are synchronized in the design
set_clock_groups -asynchronous -group [get_clocks {clk_osc}] -group [get_clocks {rgb_pclk}] -group [get_clocks {clk_ref24}] -group [get_clocks {clk_p5 clk_p}]

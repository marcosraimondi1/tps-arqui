## Constraints for basys 3 FPGA

## Clock
set_property -dict { PACKAGE_PIN W5	IOSTANDARD LVCMOS33 } [get_ports { i_clk }];

## Reset
set_property -dict { PACKAGE_PIN T18	IOSTANDARD LVCMOS33 } [get_ports { i_reset }];

## Leds
set_property -dict { PACKAGE_PIN U16 	IOSTANDARD LVCMOS33 } [get_ports { o_led[0] }];
set_property -dict { PACKAGE_PIN E19 	IOSTANDARD LVCMOS33 } [get_ports { o_led[1] }];
set_property -dict { PACKAGE_PIN U19 	IOSTANDARD LVCMOS33 } [get_ports { o_led[2] }];
set_property -dict { PACKAGE_PIN V19 	IOSTANDARD LVCMOS33 } [get_ports { o_led[3] }];
set_property -dict { PACKAGE_PIN W18 	IOSTANDARD LVCMOS33 } [get_ports { o_led[4] }];
set_property -dict { PACKAGE_PIN U15 	IOSTANDARD LVCMOS33 } [get_ports { o_led[5] }];
set_property -dict { PACKAGE_PIN U14 	IOSTANDARD LVCMOS33 } [get_ports { o_led[6] }];
set_property -dict { PACKAGE_PIN V14	IOSTANDARD LVCMOS33 } [get_ports { o_led[7] }];

## Buttons
set_property -dict { PACKAGE_PIN W19 	IOSTANDARD LVCMOS33 } [get_ports { i_btn[0] }]
set_property -dict { PACKAGE_PIN U18 	IOSTANDARD LVCMOS33 } [get_ports { i_btn[1] }]
set_property -dict { PACKAGE_PIN T17	IOSTANDARD LVCMOS33 } [get_ports { i_btn[2] }]

## Switches
set_property -dict { PACKAGE_PIN V17	IOSTANDARD LVCMOS33 } [get_ports { i_sw[0] }]
set_property -dict { PACKAGE_PIN V16 	IOSTANDARD LVCMOS33 } [get_ports { i_sw[1] }]
set_property -dict { PACKAGE_PIN W16 	IOSTANDARD LVCMOS33 } [get_ports { i_sw[2] }]
set_property -dict { PACKAGE_PIN W17 	IOSTANDARD LVCMOS33 } [get_ports { i_sw[3] }]
set_property -dict { PACKAGE_PIN W15 	IOSTANDARD LVCMOS33 } [get_ports { i_sw[4] }]
set_property -dict { PACKAGE_PIN V15 	IOSTANDARD LVCMOS33 } [get_ports { i_sw[5] }]
set_property -dict { PACKAGE_PIN W14 	IOSTANDARD LVCMOS33 } [get_ports { i_sw[6] }]
set_property -dict { PACKAGE_PIN W13 	IOSTANDARD LVCMOS33 } [get_ports { i_sw[7] }]


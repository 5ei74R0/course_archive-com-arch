set search_path [concat "/home/cad/lib/osu_stdcells/lib/tsmc018/lib/" $search_path]
set LIB_MAX_FILE {osu018_stdcells.db  }

set link_library $LIB_MAX_FILE
set target_library $LIB_MAX_FILE

read_verilog alu.v
read_verilog rfile.v
read_verilog rv32i.v
current_design "rv32i"
create_clock -period 4.45 clk 
set_input_delay 2.0 -clock clk [find port "readdata*"]
set_output_delay 2.0 -clock clk [find port "adr*"]
set_output_delay 2.0 -clock clk [find port "writedata*"]
set_output_delay 2.0 -clock clk [find port "we"]

set_max_fanout 12 [current_design]

set_max_area 0

compile -map_effort high -area_effort medium

redirect -tee -file timing.rpt {report_timing -max_paths 1 }

redirect -tee -file area.rpt {report_area}

redirect -tee -file power.rpt {report_power}

write -hier -format verilog -output rv32i.vnet
write -hier -format ddc -output rv32i.ddc

quit

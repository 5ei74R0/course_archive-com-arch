test: clean test_rv32i.v rv32i.v alu.v rfile.v dmem.v imem.v
	iverilog test_rv32i.v rv32i.v alu.v rfile.v dmem.v imem.v -o test
testall: test_rv32i.v rv32i.v alu.v rfile.v dmem.v imem.v
	iverilog -DREGALL test_rv32i.v rv32i.v alu.v rfile.v dmem.v imem.v -o testall
synth: rv32i.v alu.v rfile.v dmem.v imem.v rv32i.tcl
	dc_shell -xg -f rv32i.tcl | tee log
swap:
	./shapa swap.asm -o tmp.dat
	./convert.py
	ln -sf dmem-swap.dat dmem.dat
grade:
	./shapa grade.asm -o tmp.dat
	./convert.py
	ln -sf dmem-grade.dat dmem.dat
comp-swap:
	cmp result.dat answer-swap.dat
comp-grade:
	cmp result.dat answer-grade.dat
clean:
	rm -f test tmp.dat rv32i.vcd 
distclean:
	rm -f test tmp.dat rv32i.vcd imem.dat result.dat
%:
	./shapa $*.asm -o tmp.dat
	./convert.py

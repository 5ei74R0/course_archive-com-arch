	addi x4,x0,0
	addi x7,x0,100
loop: lw x5,x4,0
	lw x6,x4,400
	addi x7,x7,-1  // change the order of command
    addi x0,x0,0  // insert NOP to avoid stall
	sw x6,x4,0
	sw x5,x4,400
	addi x4,x4,4
	bne x7,x0,loop
	ecall x0,x0,x0
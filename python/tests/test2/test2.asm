J	5	  
ADDI	R3,R0,85
NOP
NOP
NOP
JAL 	8	
ADDI	R4,R0,95
NOP
ADDI	R5,R0,56
JR	R5	
NOP
ADDI	R2,R0,2	
NOP
NOP
ADDI	R6,R0,80
JALR	R30,R6	
ADDI	R1,R0,10
NOP
NOP
NOP
ADDI	R7,R0,15
ADDI	R8,R0,8	
ADDI	R8,R8,1	
SW	R7,0(8)
BNE	R8,R7,-3
NOP
BEQ	R8,R7,3	
NOP
ADDI	R9,R0,8	
ADDI	R10,R0,8
ADDI	R11,R0,8
HALT

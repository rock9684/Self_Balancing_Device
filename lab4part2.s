
.global main
main:
	#initialize the stack pointer
	movia sp, 0x03fffffc
/*check sensor 3 and 4 in sequence*/
	br CheckSensor
/*compare two results*/

/*branch to different reactions of motors and check it again*/	


#registers have been used:  r5, r8, r9, r10, r11, r12 

/*the case when wheel go forward*/
forward:
	movia  r12, 0x07f557ff        /* set direction for motors to all output */
	stwio  r12, 4(r8)
	movia  r12, 0xfffffffc        /* motor0 enabled (bit0=0), direction set to forward (bit1=0) */
	stwio  r12, 0(r8)
	/*call the timer to count the time*/
	addi sp, sp, -24
	stw r5, 0(sp)
	stw r8, 4(sp)
	stw r9, 8(sp)
	stw r10, 12(sp)
	stw r11, 16(sp)
	stw r12, 20(sp)
	call count_threshold
	ldw r12, 20(sp)
	ldw r11, 16(sp)
	ldw r10, 12(sp)
	ldw r9, 8(sp)
	ldw r8, 4(sp)
	ldw r5, 0(sp)
	addi sp, sp, 24
	br CheckSensor

/*the case when wheel go reverse*/
reverse:
	movia  r12, 0x07f557ff        /* set direction for motors to all output */
	stwio  r12, 4(r8)
	movia  r12, 0xfffffffe        /* motor0 enabled (bit0=0), direction set to reverse (bit1=1) */
	stwio  r12, 0(r8)
	
	/*call the timer to count the time*/
	addi sp, sp, -24
	stw r5, 0(sp)
	stw r8, 4(sp)
	stw r9, 8(sp)
	stw r10, 12(sp)
	stw r11, 16(sp)
	stw r12, 20(sp)
	call count_threshold
	ldw r12, 20(sp)
	ldw r11, 16(sp)
	ldw r10, 12(sp)
	ldw r9, 8(sp)
	ldw r8, 4(sp)
	ldw r5, 0(sp)
	addi sp, sp, 24
	br CheckSensor

/*the case when wheel turn off*/
turnoff:
	movia  r12, 0x07f557ff        /* set direction for motors to all output */
	stwio  r12, 4(r8)
	movia  r12, 0xffffffff        /* motor0 disabled */
	stwio  r12, 0(r8)
	
	/*call the timer to count the time*/
	addi sp, sp, -24
	stw r5, 0(sp)
	stw r8, 4(sp)
	stw r9, 8(sp)
	stw r10, 12(sp)
	stw r11, 16(sp)
	stw r12, 20(sp)
	call count_threshold
	ldw r12, 20(sp)
	ldw r11, 16(sp)
	ldw r10, 12(sp)
	ldw r9, 8(sp)
	ldw r8, 4(sp)
	ldw r5, 0(sp)
	addi sp, sp, 24
	br CheckSensor



/*Compare two results*/
CompareResult:
	bgt r9, r10, forward
	blt r9, r10, reverse
	beq r9, r10, turnoff


CheckSensor:
/*Check sensor 1 reponse, load the result into r10*/
	
	/*call the timer to count the time*/
	addi sp, sp, -24
	stw r5, 0(sp)
	stw r8, 4(sp)
	stw r9, 8(sp)
	stw r10, 12(sp)
	stw r11, 16(sp)
	stw r12, 20(sp)
	call count_threshold
	ldw r12, 20(sp)
	ldw r11, 16(sp)
	ldw r10, 12(sp)
	ldw r9, 8(sp)
	ldw r8, 4(sp)
	ldw r5, 0(sp)
	addi sp, sp, 24
    
	.equ ADDR_JP1, 0xff200060  /* address GPIO JP1*/
    movia  r8, ADDR_JP1
    movia  r10, 0x07f557ff      /* set direction for motors and sensors to output and sensor data register to inputs*/
    stwio  r10, 4(r8)
loop1:
    movia  r11, 0xfffeffff      /* enable sensor 3, disable all motors*/
    stwio  r11, 0(r8)
    ldwio  r5,  0(r8)           /* checking for valid data sensor 3*/
    srli   r5,  r5,17           /* bit 17 equals valid bit for sensor 3*/           
    andi   r5,  r5,0x1
    bne    r0,  r5,loop1        /* checking if low indicated polling data at sensor 3 is valid*/
good1:
    ldwio  r9, 0(r8)         /* read sensor3 value (into r10) */
    srli   r9, r9, 27       /* shift to the right by 27 bits so that 4-bit sensor value is in lower 4 bits */
    andi   r9, r9, 0x0f
	
/*Check sensor 2 reponse, load the result into r9*/
    movia  r8, ADDR_JP1
    movia  r10, 0x07f557ff      /* set direction for motors and sensors to output and sensor data register to inputs*/
    stwio  r10, 4(r8)
loop2:
    movia  r11, 0xfffbffff      /* enable sensor 4, disable all motors*/
    stwio  r11, 0(r8)
    ldwio  r5,  0(r8)           /* checking for valid data sensor 4*/
    srli   r5,  r5,19           /* bit 17 equals valid bit for sensor 4*/           
    andi   r5,  r5,0x1
    bne    r0,  r5,loop2        /* checking if low indicated polling data at sensor 4 is valid*/
good2:
    ldwio  r10, 0(r8)         /* read sensor3 value (into r10) */
    srli   r10, r10, 27       /* shift to the right by 27 bits so that 4-bit sensor value is in lower 4 bits */
    andi   r10, r10, 0x0f
	br CompareResult
	
	
	
	
	
	
	
count_threshold:
    mov r8, r0
    movia r7, 0xFF202000                   /* r7 contains the base address for the timer */
    movui r2, %lo(19666 * 5)
    stwio r2, 8(r7)                          /* Set the period to be 1000 clock cycles */
    movui r2, %hi(19666 * 5)
    stwio r2, 12(r7)
    movui r2, 4
    stwio r2, 4(r7)

loop:
    ldwio r23, 0(r7)
	andi r23, r23, 0x1
	beq r0, r23, loop
	stwio r0, 0(r7)

    ret

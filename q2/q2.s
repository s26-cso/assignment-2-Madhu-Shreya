.section .data
space:    .asciz " "
newline:  .asciz "\n"
fmt: .asciz "%d"

.section .text
.globl main
.extern malloc
.extern free
.extern printf

atoi:
    li t0, 0                #result
    li t1, 0                #sign

    atoi_loop:
    lbu t2, 0(a0)           #t2= current char in input
    beqz t2, atoi_done      #if(t2='\0')
    li t3, '-'              #t3='-'
    bne t2, t3, digit       #if t2 !='-' its a digit
    li t1, 1                #else sign=1
    addi a0, a0, 1          #move pointer to next char 
    beq x0,x0,atoi_loop     #loopback

    digit:
    li t3, '0'              #t3=0
    blt t2, t3, atoi_done   #if(digit<0) atoi done
    li t4,'9'               #t4=9
    bgt t2, t4, atoi_done   #if(digit>9) atoi done
    addi t2,t2,-48          #ascii(digit)-ascii(0)=digit
    li t5, 10               #t5=10
    mul t0, t0, t5          #n=n*10
    add t0, t0, t2          #n=n+digit
    addi a0, a0, 1          #move pointer to next char
    beq x0,x0,atoi_loop     #loopback

    atoi_done:
    beqz t1, ret_atoi       #if +ve sign ret n 
    li t5,-1                #t5=-1
    mul t0, t0,t5           #if -ve sign t0 = -t0
    
    ret_atoi:
    mv a0, t0               #a0=n       
    ret                     #return

main:
    addi sp, sp, -64        #moving the sp 
    sd x1, 0(sp)            #pushing return address
    sd s0, 8(sp)            #saved reg values pushed to sp
    sd s1, 16(sp)
    sd s2, 24(sp)
    sd s3, 32(sp)
    sd s4, 40(sp)
    sd s5, 48(sp)           #s5=stack_size (saved so it survives calls)
    sd s6, 56(sp)           #s6=loop index i (saved so it survives calls)

    mv s0, a0               #s0=argc count of arguments
    mv s1, a1               #s1=argv pointer to arguments
    addi s0, s0, -1         #n = argc - 1

    li t1, 4                #t1=4
    mul t2, s0, t1          #size = n * 4

    mv a0, t2               #a0=size
    call malloc
    mv s2, a0               #s2=pointer to allocated memory for arr
    li t1, 4                #t1=4 (t1,t2 are not saved, clobbered by malloc)
    mul t2, s0, t1          #size = n * 4
    mv a0, t2               #a0=size
    call malloc
    mv s3, a0               #s3=pointer to allocated memory for result
 
    li t1, 4                #t1=4 (t1,t2 are not saved, clobbered by malloc)
    mul t2, s0, t1          #size = n * 4
    mv a0, t2               #a0=size
    call malloc
    mv s4, a0               #s4=pointer to allocated memory for stack
    li s6, 0                #i=0

    read_loop:
    bge s6, s0, read_done   #if (i>=n) done
    addi t1, s6, 1          #t1=i+1
    slli t1, t1, 3          #t1*=8
    add t1, s1, t1          #t1 is pointer to argv[i+1] 
    ld a0, 0(t1)            #a0=argv[i+1]

    call atoi

    slli t2, s6, 2          #t2=i*4
    add t2, s2, t2          #t2=pointer to arr[i]
    sw a0, 0(t2)            #a0=arr[i]        
    addi s6, s6, 1          #i++
    beq x0,x0,read_loop     #loopback

    read_done:
    li s6,0                 #i=0

    init_loop:
    bge s6, s0, init_done   #if (i>=n) done
    slli t1, s6, 2          #t1=i*4
    add t1, s3, t1          #t1=pointer to result[i]
    li t2, -1               #t2=-1
    sw t2, 0(t1)            #result[i]=-1
    addi s6, s6, 1          #i++
    beq x0,x0,init_loop     #loopback

    init_done:
    li s5, 0                # stack size
    addi s6, s0, -1         # i = n-1

    nge_loop:
    blt s6,x0,nge_done      #if(i<0) done

    while_loop:
    beqz s5, while_end      #stack size=0 end while

    addi t2, s5, -1         #t2=stack size-1
    slli t2, t2, 2          #t2=t2*4
    add t3, s4, t2          #t3=pointer to stack[top]
    lw t4,0(t3)             #t4=stack[top]

    slli t5, t4, 2          #t5=stack[top]*4
    add t6, s2,t5           #t6=pointer to arr[stack[top]]
    lw t6, 0(t6)            #t6=arr[stack[top]]

    slli t5, s6, 2          #t5=i*4
    add t5, s2, t5          #t5=pointer to arr[i]
    lw t5, 0(t5)            #t5=arr[i]

    bgt t6, t5, while_end   #if(arr[stack[top]] > arr[i]) stop
    addi s5, s5, -1         #pop
    beq x0,x0,while_loop    #loopback

    while_end:
    beqz s5, skip           #if(stack empty) skip

    addi t2, s5, -1         #t2=stack size-1
    slli t2, t2, 2          #t2=t2*4
    add t3, s4, t2          #t3=pointer to stack[top]
    lw t4,0(t3)             #t4=stack[top]

    slli t5,s6,2            #t5=i*4
    add t5,s3,t5            #t5=pointer to result[i]
    sw t4, 0(t5)            #result[i]=stack[top]

    skip:
    slli t2, s5, 2          #t2=stacksize*4
    add t2, s4, t2          #t2=pointer to stack[stacksize]
    sw s6, 0(t2)            #stack[stacksize]= i
    addi s5, s5, 1          #stacksize++
    addi s6, s6, -1         #i--
    beq x0,x0,nge_loop

    nge_done:
    li s6, 0                #i=0

    print_loop:
    bge s6, s0, print_done  #if(i=n) done
    slli t1, s6, 2          #t1=i*4
    add t1, s3, t1          #t1=pointer to result[i]
    lw a1, 0(t1)            #a1=result[i]
    la a0, fmt              #a0="%d"
    call printf     
    la a0, space            #a0=" "
    call printf
    addi s6, s6, 1          #i++
    beq x0,x0,print_loop    #loopback

    print_done:
    la a0, newline          #a0="\n"
    call printf

    end:
    mv a0, s2               #free all dynamically allocated memory
    call free
    mv a0, s3
    call free
    mv a0, s4
    call free

    ld x1, 0(sp)            #return pointer
    ld s0, 8(sp)            #restore values in saved reg
    ld s1, 16(sp)
    ld s2, 24(sp)
    ld s3, 32(sp)
    ld s4, 40(sp)
    ld s5, 48(sp)
    ld s6, 56(sp)
    addi sp, sp, 64         #reset sp
    li a0, 0                #return 0
    ret
    

.section .data
filename: .asciz "input.txt"
yes: .asciz "Yes\n"
no: .asciz "No\n"

.section .bss
lchar: .space 1
rchar: .space 1

.section .text
.global main
main:                     
    addi sp, sp, -16        # create stack space for saving registers
    sd s0, 0(sp)            
    sd s1, 8(sp)            

    li a7,56                #a7=56 syscall no. for open file 
    la a0,filename          #a0=file name
    li a1,0                 #a1=0 read only
    ecall                   
    mv s0,a0                #s0=file descriptor

    li a7,62                #a7=62 syscall no. for lseek
    mv a0,s0                #a0=file descriptor
    li a1,0                 #a1=0 offset=0
    li a2,2                 #a2=2 reference point = end
    ecall
    mv s1,a0                #s1=size

    addi s1,s1,-1           #s1=last index 
    add t0,x0,x0            #t0=0 start left
    mv t1,s1                #t1=last index right

checkpal:
    bge t0,t1,pal           #if whole string checked its a palindrome

    li a7,62                #a7=62 syscall no. for lseek
    mv a0,s0                #a0=file descriptor
    mv a1,t0                #a1=left offset=left index
    li a2,0                 #a2=0 reference point start
    ecall

    li a7,63                #a7=63 syscall no. for read
    mv a0,s0                #a0=file descriptor
    la a1,lchar             #a1=address of lchar
    li a2,1                 #a2=1 read one byte
    ecall

    li a7,62                #a7=62 syscall no. for lseek
    mv a0,s0                #a0=file descriptor
    mv a1,t1                #a1=right offset=right index
    li a2,0                 #a2=0 reference point start
    ecall

    li a7,63                #a7=63 syscall no. for read
    mv a0,s0                #a0=file descriptor
    la a1,rchar             #a1=address of rchar
    li a2,1                 #a2=1 read one byte
    ecall

    la t4,lchar
    lb t2,0(t4)             #t2 = left char
    la t5,rchar
    lb t3,0(t5)             #t3 = right char
    bne t2,t3,notpal        #if not equal → not palindrome

    addi t0,t0,1            #start++
    addi t1,t1,-1           #lastidx--
    beq x0,x0,checkpal      #loop back

notpal:
    li a7,64                #a7=64 syscall no. for write
    li a0,1                 #a0=1 write through stdout
    la a1,no                #a1=no no is the address of string to print
    li a2,3                 #a2=3 write 3 bytes
    ecall
    beq x0,x0, exit

pal:
    li a7,64                #a7=64 syscall no. for write
    li a0,1                 #a0=1 write through stdout
    la a1,yes               #a1=yes yes is the address of string to print
    li a2,4                 #a2=4 write 4 bytes
    ecall

exit:
    ld s0, 0(sp)            
    ld s1, 8(sp)            
    addi sp, sp, 16         # restore stack pointer

    li a0,0                 #a0=0
    ret

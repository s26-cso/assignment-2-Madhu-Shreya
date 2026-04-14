.globl make_node
make_node:
    addi sp, sp, -16        #moving the sp 
    sd x1, 8(sp)            #pushing return address
    sd a0, 0(sp)            #pushing val

    li a0, 24               #we need to malloc array of size 24 for struct 
    call malloc             #struct pointer in a0

    ld t1, 0(sp)            #loading val to t1
    sw t1, 0(a0)            #Node->val=val;
    sd x0, 8(a0)            #Node->left=NULL;
    sd x0, 16(a0)           #Node->right=NULL;

    ld x1, 8(sp)            #return pointer
    addi sp,sp,16           #reset sp
    ret

.globl insert
insert:
    addi sp, sp, -16        #moving the sp 
    sd x1, 8(sp)            #pushing return address
    sd a0, 0(sp)            #pushing root
    beq a0, x0, root_null   #if root==NULL 

    lw t0, 0(a0)            #t0=root->val
    blt a1, t0, go_left     #if(val < root->val) go left

    go_right:
    ld t1, 16(a0)           #t1=root->right
    mv a0, t1
    call insert             #returns root of updated subtree in a0

    ld t2, 0(sp)            #t2=org root of tree
    sd a0,16(t2)            #root->right= updated root stored in a0

    mv a0, t2               #updated root in a0
    beq x0,x0,insert_done   #go to insert insert_done

    go_left:
    ld t1, 8(a0)            #t1=root->left
    mv a0, t1
    call insert             #returns root of updated subtree in a0

    ld t2, 0(sp)            #t2=org root of tree
    sd a0,8(t2)             #root->left= updated root stored in a0

    mv a0, t2               #updated root in a0
    beq x0,x0,insert_done   #go to insert insert_done

    root_null:
    mv a0, a1               #a0=val for make_node
    call make_node

    insert_done:
    ld x1, 8(sp)            #return pointer
    addi sp,sp,16           #reset sp
    ret

.globl get
get:
    addi sp, sp, -16        #moving the sp 
    sd x1, 8(sp)            #pushing return address

    beq a0,x0,get_root_null     #if root==NULL
    lw t0, 0(a0)            #t0=root->val;

    beq t0, a1, get_end     #if val==root->val found;
    blt a1, t0, get_go_left     #if val < root->val go left

    get_go_right:
    ld a0, 16(a0)           #a0=root->right
    call get                
    beq x0,x0, get_end      

    get_go_left:
    ld a0, 8(a0)            #a0=root->left
    call get
    beq x0,x0, get_end
    
    get_root_null:
    li a0, 0                #a0=0
    ld x1, 8(sp)            #return pointer
    addi sp, sp, 16         #reset sp
    ret
    
    get_end:
    ld x1, 8(sp)            #return pointer
    addi sp, sp, 16         #reset sp
    ret

.globl getAtMost
getAtMost:
    li t0, -1               #ans = -1

    loop:
    beq a1,x0,end           #if root == NULL
    lw t1,0(a1)             #root->val
    ble t1,a0,update        #if root->val <= val update ans

    getAtMost_go_left:
    ld a1, 8(a1)            #root->left
    beq x0,x0,loop          #loop back

    update:
    mv t0,t1                #ans=root->val
    getAtMost_go_right:
    ld a1, 16(a1)           #root->right
    beq x0,x0,loop          #loop back

    end:
    mv a0,t0                #a0=ans
    ret
    

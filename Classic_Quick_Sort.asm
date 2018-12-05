
.data
newLine: .asciiz "\n"
space: .asciiz " "
deleteOutOfRangeError: .asciiz "Delete: out of range"
addOutOfRangeError: .asciiz "Add: out of range"
emptyListError: .asciiz "Empty list. Declare one before adding"
.globl declareLinkedList
.globl addNode
	.text
main:
	#create linked list
	jal declareLinkedList

	move $a1, $v0 	#pass arguments
	li $a0, 5	#set the number of nodes to $a0
	jal generateRandomLinkedList

	move $s5, $v0	#print out the initial list
	jal printLine
	jal printList

	#pass arguments and do quick sorting
	jal quickSort

	move $s5, $v0 	#print the sorted list
	jal printLine
	jal printList

	move $a0, $v0	#delete demo
	li $a1, 10
	jal deleteAt

	move $s5, $v0	#print just-deleted list
	jal printLine
	jal printList

	move $a0, $v0	#add demo
	li $a1, 6
	li $a2, 3
	jal addAt

	move $a0, $v0
	li $a1, 3
	jal addToEnd

	move $s5, $v0	#print added list
	jal printLine
	jal printList

Exit:	li $v0, 10
	syscall

#********************************************************

#addToEnd - add a node to the end of the list
#input: $a0 - the head node; $a1 - the value of the node
#output: $v0 - the head node
addToEnd:
	addi $sp, $sp, -16	#save registers
	sw $t4, 0($sp)
	sw $t3, 4($sp)
	sw $a0, 8($sp)
	sw $ra, 12($sp)

	bne $a0, $zero, nonEmptyList
	la $a0, emptyListError	#print error message
	li $v0, 4
	syscall
	j Exit5
nonEmptyList:
	lw $t4, 4($a0)	#move to the last node
	beq $t4, $zero, addToEndOfList
	lw $a0, 4($a0)
	j nonEmptyList
addToEndOfList:
	move $t4, $a0	#pass arguments
	move $t3, $a1
	jal addNode	#add new node
Exit5:
	lw $ra, 12($sp)	#restore registers
	lw $a0, 8($sp)
	lw $t3, 4($sp)
	lw $t4, 0($sp)
	lw $v0, 8($sp)	#return the head node
	addi $sp, $sp, 16
	jr $ra

#********************************************************

#addAt - add a node at specific location
#input: $a0 - the address of the list; $a1 -  the location; $a2 - the value
#output: $v0 - the address of the adjusted list
addAt:
	addi $sp, $sp, -20
	sw $a0, 0($sp)	#save registers
	sw $a1, 4($sp)
	sw $a2, 8($sp)
	sw $t3, 12($sp)
	sw $ra, 16($sp)

	bne $a1, 1, addAtOtherPlaces
	jal declareLinkedList #define a new node

	sw $a2, 0($v0) #set value to the new node
	sw $a0, 4($v0) #insert the new node the top of the list

	j Exit4

addAtOtherPlaces:
	#move $v0, $a0	#pre-process data
	lw $a0, 4($a0)
	addi $a1, $a1, -2

loop4:
	slt $t0, $zero, $a1
	beq $t0, 0, stopLoop2	#move pointer to $a1 location
	beq $a0, $zero, outOfRange	#out of range
	addi $a1, $a1, -1
	lw $a0, 4($a0)	#update pointer
	j loop4

stopLoop2:
	lw $t3, 4($a0)
	beq $t3, $zero, outOfRange
	jal declareLinkedList #declare a new node
	#the new node saved to $v0
	sw $a2, ($v0) #set value to the new node


	lw  $t3, 4($a0)	#relink
	sw $v0, 4($a0)
	sw $t3, 4($v0)
	lw $v0, 0($sp) #restore the head node's address
	j Exit4

outOfRange:
	#print out-of-range error meesage
	la $a0, addOutOfRangeError
	li $v0, 4
	syscall
	lw $v0, 0($sp) #restore the head node's address
	j Exit4

Exit4:

	lw $ra, 16($sp)	#restore registers
	lw $t3, 12($sp)
	lw $a2, 8($sp)
	lw $a1, 4($sp)
	lw $a0, 0($sp)
	addi $sp, $sp, 20
	jr $ra
#********************************************************

#deleteAt - delete a node at specific location
#input: $a0 - the address of the list, $a1 - the location
#output: $v0 - the address of the adjusted list
deleteAt:
	addi $sp, $sp, -16
	sw $a0, 0($sp)
	sw $a1, 4($sp)
	sw $t0, 8($sp)
	li $t0, 0

	bne $a1, 1, delete #delete first node
	lw $v0, 4($a0)
	j Exit3
delete:
	move $v0, $a0	#pre-process data
	lw $a0, 4($a0)
	addi $a1, $a1, -2
loop3:
	slt $t0, $zero, $a1
	beq $t0, 0, stopLoop	#move pointer to $a1 location
	beq $a0, $zero, outOfRange2	#out of range
	addi $a1, $a1, -1
	lw $a0, 4($a0)
	lw $v0, 4($v0)
	j loop3
stopLoop:
	beq $a0, $zero, outOfRange2
	move $a1, $a0	#relink
	lw $a0, 4($a0)	#skip the need-deleting node
	sw $a0, 4($v0)
	lw $v0, 0($sp)	#restore the head node's address
	j Exit3

outOfRange2:
	#print out-of-range error meesage
	la $a0, deleteOutOfRangeError
	li $v0, 4
	syscall
	lw $v0, 0($sp) #restore the head node's address
	j Exit3
Exit3:
	lw $t0, 8($sp)
	lw $a1, 4($sp)
	lw $a0, 0($sp)
	addi $sp, $sp, 16
	jr $ra

#********************************************************

#genRandomLinkedList - initialize and add random values into the list
#input: $a0 - number of nodes, $a1 - address of the head node
#output: $v0 - address of the randomly value-generated list, $v1 - address of the last node
generateRandomLinkedList:
	addi $sp, $sp, -12 #save registers
	sw $a0, 0($sp)
	sw $a1, 4($sp)
	sw $ra, 8($sp)

	move $t4, $a1 #last node saved in $t4
	li $s0, 0 #counter
loop1:
	lw $a0, ($sp)
	beq $s0, $a0, Exit1 #reach end of the list

	li $v0, 42 #generate random numbers
	li $a1, 100	#upper bound - 100
	syscall

	move $t3, $a0	#add a new node
	jal addNode

	lw $t4, 4($t4) #udpate last node
	addi $s0, $s0, 1
	j loop1

Exit1:
	lw $ra, 8($sp)
	lw $a1, 4($sp)
	lw $a0, 0($sp)
	move $v0, $a1	#return the head node
	move $v1, $t4 #return the last node
	addi $sp, $sp, 12
	jr $ra

#********************************************************

#quickSort - implement the recusive quick sort algorithm
#input: $v0 - the head's address of the linked list, $v1 - address of the last node
#output: $v0 - the head's address of the linked list, $v1 - the address of the last node
quickSort:
	addi $sp, $sp, -28
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $s0, 24($sp)
	sw $s1, 12($sp)
	sw $s2, 16($sp)
	sw $ra, 20($sp)

	#save address of the head
	move $s3, $v0 #the head's address saved into $s3

	lw $t0, 4($s3)
	beq $t0, $zero, stopRecursion# if the list is empty, stop sorting
	lw $t0, 4($t0) # if the list has an only element, stop sorting
	beq $t0, $zero, stopRecursion

	#declare 3 linkedList: smaller, same, larger
	jal declareLinkedList	#smaller list
	add $s0, $v0, $zero	#the head node of smaller saved to $s0

	jal declareLinkedList	#same list
	add $s1, $v0, $zero #the head node of same saved to $s1

	jal declareLinkedList	#larger list
	add $s2, $v0, $zero #the head node of larger saved to $s2

	#pick pivot at the middle of the list
	move $a0, $s3
	jal pickPivotAtMiddle #pivot is save to $v0

	move $t0, $s3	#pointer saved to $t0
	move $t1, $v0 #copy pivot to $t1
	jal patrition
	#return $s0, $s1, $s2 - store addresses of the head nodes of filtered lists
	#return $t0, $t1, $t2 - store addresses of the last nodes of filerred lists

	move $v0, $s0	#quickSort on smaller list
	move $v1, $t0
	jal quickSort
	move $s0, $v0	#update head and last nodes of smaller list
	move $t0, $v1

	move $v0, $s2	#quickSort on largest list
	move $v1, $t2
	jal quickSort
	move $s2, $v0 #update head and last nodes of larger list
	move $t2, $v1

	#merge list
	jal mergeList
	#return $s0 - the first node and $t2 - the last node of the merged list

	move $v0, $s0 #return the merged list
	move $v1, $t2

	#add $s5, $v0, $zero
	#jal printLine
	#jal printList

	lw $t0, 0($sp) #restore registers
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $s0, 24($sp)
	lw $s1, 12($sp)
	lw $s2, 16($sp)
	lw $ra, 20($sp)
	addi $sp, $sp, 28
	jr $ra

stopRecursion:

	lw $t0, 0($sp) #restore registers
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $s0, 24($sp)
	lw $s1, 12($sp)
	lw $s2, 16($sp)
	lw $ra, 20($sp)
	addi $sp, $sp, 28
	jr $ra

#********************************************************

#print new line
#input: none
#output: void
printLine:
	addi $sp, $sp, -12
	sw $v0, 0($sp)
	sw $s5, 4($sp)
	sw $a0, 8($sp)

	la $a0, newLine
	li $v0, 4
	syscall
	lw $v0, 0($sp)
	lw $s5, 4($sp)
	lw $a0, 8($sp)
	addi $sp, $sp, 12
	jr $ra

#********************************************************

#printList - print the list
#input: $s5 - address of the head node or list
#output: void
printList:
	addi $sp, $sp, -12 #save registers
	sw $s5, 0($sp)
	sw $a0, 4($sp)
	sw $v0, 8($sp)
loop2:
	lw $a0, 4($s5)
	beq $a0, $zero, Exit2 #end of the list

	lw $a0, 0($s5) #print numbers
	li $v0, 1
	syscall

	la $a0, space #seperate numbers
	li $v0, 4
	syscall

	lw $s5, 4($s5)	#update pointer
	j loop2
Exit2:
	lw $a0, 4($sp) #restore registers
	lw $s5, 0($sp)
	lw $v0, 8($sp)
	addi $sp, $sp, 12
	jr $ra

#********************************************************

#mergeList
#input: $s0, $s1, $s2 - addresses of the first nodes; $t0, $t1, $t2 - addresses of the last nodes
#output: $s0 - address of the merged list; $t2 - address of the last node in the merged list
mergeList:
	addi $sp, $sp, -16	#save registers
	sw $ra, 0($sp)
	sw $t4, 4($sp)
	sw $t3, 8($sp)
	sw $v0, 12($sp)

	#copy same list to smaller list
	lw $t3, 0($s1)
	move $t4, $t0 #copy the next prop. of the head node to $t4

Add1:	beq $t3, 0, stopAdd1
	jal addNode	#add a new node with value saved in $t3
	move $t4, $v0	#update pointers
	lw $s1, 4($s1)
	lw $t3, 0($s1)
	j Add1
stopAdd1:

	#copy updated smaller and larger lists
	lw $t3, 0($s2)

Add2:	beq $t3, 0, stopAdd2
	jal addNode	#add a new node with value saved in $t3
	move $t4, $v0	#update pointers
	lw $s2, 4($s2)
	lw $t3, 0($s2)
	j Add2
stopAdd2:

	#$s0 stores the head node, $t2 stores the last node
	move $t2, $t4

	lw $v0, 12($sp)	#restore registers
	lw $t3, 8($sp)
	lw $t4, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 16
	jr $ra

#********************************************************

#patrition - function to sub-list
#input: $t0 - address of the need-parsing list, $t1 - value of pivot
			#$s0 - address of smaller list, $s1 - address of same list, $s2 - address of larger list
#output: $t0, $t1, $t2 - address of the 3 adjusted lists
patrition:
	addi $sp, $sp, -36
	sw $s0, 0($sp)	#save registers
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $ra, 32($sp)

Patrition:
	lw $t3, 4($t0)	#check end of list
	beq $t3, $zero, stopPatrition

	lw $t3, 0($t0)	#patrition into three sub-lists
	slt $t2, $t3, $t1 #compare nodes with pivot

	#smaller list
	bne $t2, 1, NotLessThanPivot
	move $t4, $s0
	jal addNode
	move $s0, $v0
	lw $t0, 4($t0) #update pointer to next node
	j Patrition

	#same list
NotLessThanPivot:
	bne $t3, $t1, NotSamePivot
	move $t4, $s1
	jal addNode
	move $s1, $v0
	lw $t0, 4($t0) #update pointer to next node
	j Patrition

	#larger list
NotSamePivot:
	move $t4, $s2
	jal addNode
	move $s2, $v0
	lw $t0, 4($t0) #update pointer to next node
	j Patrition

stopPatrition:

	move $t0, $s0	#save last nodes to $t0, $t1, $t2
	move $t1, $s1
	move $t2, $s2

	lw $s0, 0($sp)	#restore registers
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $t3, 12($sp)
	lw $t4, 16($sp)
	lw $ra, 32($sp)
	addi $sp, $sp, 36
	jr $ra

#********************************************************

#pickPivotAtMiddle: select the pivot at the middle of the list
#input: $a0 - the address of the linked list or the head node
#output: $v0 - the pivot value
pickPivotAtMiddle:
	addi $sp, $sp, -16 #save registers
	sw $a0, 0($sp)
	sw $t0, 4($sp)
	sw $t1, 8($sp)
	sw $ra, 12($sp)

	#declare two pointers
	#slowPointer stored at $t0
	#fastPointer stored at $t1
	move $t0, $a0
	lw $t1, 4($a0)

Iterate:
	lw $t0, 4($t0)	#update slow pointer
	li $a0, 2	#counter for updating fast pointer

updateFastPointer:

	lw $t1, 4($t1)
	beq $t1, 0, EndPickPivot #reach end of the list

	#move the fast pointer forwards twice faster than the slower pointer
	addi $a0, $a0, -1
	beq $a0, 0, Iterate
	j updateFastPointer
	j Iterate

EndPickPivot:

	#return pivot saved in $v0
	lw $v0, 0($t0)

	lw $a0, 0($sp) #restore registers
	lw $t0, 4($sp)
	lw $t1, 8($sp)
	lw $ra, 12($sp)
	addi $sp, $sp, 16
	jr $ra

#********************************************************

#declareLinkedList - defien a new linked list
#input: none
#output: $v0 - address of the new list or new node
declareLinkedList:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	#test adding linked list
	jal newList #create linked list object

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

#********************************************************

#newList - declare a new linked list
#input: none
#output: $v0 - address of the new list or new node
newList:
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $ra, 4($sp)

	#declare a linked list
	li $a0, 8
	li $v0, 9
	syscall

	lw $a0, 0($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 8
	jr $ra

#********************************************************

#cleanList - clear the list
#input: $a0 - address of the first node/list
#output: void
cleanList:
	sw $zero, ($a0)
	sw $zero, 4($a0)

#********************************************************

#addNode - add new nodes the list
#input: $t4 - address of current node, $t3 - value of the current node
#output: $v0 - address of the next node
addNode:
	addi $sp, $sp, -16
	sw $a0, 0($sp)	#save registers
	sw $t4, 4($sp)
	sw $t3, 8($sp)
	sw $ra, 12($sp)

	li $a0, 8	#generate address for next node
	li $v0, 9
	syscall

	sw $t3, 0($t4)	#set value to the current node
	sw $v0, 4($t4) #set address of next node to previous node

	lw $a0, 0($sp)	#restore registers
	lw $t4, 4($sp)
	lw $t3, 8($sp)
	lw $ra, 12($sp)
	addi $sp, $sp, 16
	jr $ra

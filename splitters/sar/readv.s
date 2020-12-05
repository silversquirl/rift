.global wrap_process_vm_readv
.type wrap_process_vm_readv, @function
wrap_process_vm_readv:
	pushq %rbp
	movq %rsp, %rbp
	movq $310, %rax
	movq %rcx, %r10
	syscall
	pop %rbp
	ret

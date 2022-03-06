		.import _main
		
		.segment "VECTORS"
		
		.addr _init
		.addr _init
		.addr _init
		
		.code
		
_init:		jsr _main

end:		jmp end

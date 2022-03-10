		.import _main
		
        .export __STARTUP__ : absolute = 1

		.segment "VECTORS"
		
		.addr _init
		.addr _init
		.addr _init
		
		.segment "STARTUP"
		
_init:		jsr _main

end:		jmp end

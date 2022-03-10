//Modified version of Generic Types as included by Microchip C18

#ifndef __GENERIC_TYPE_DEFS_H_
#define __GENERIC_TYPE_DEFS_H_

typedef enum _BOOL {
	FALSE = 0, TRUE
} BOOL;	// Undefined size

#define	ON TRUE
#define	OFF	FALSE

typedef unsigned char BYTE;				// 8-bit unsigned
typedef unsigned short int WORD;				// 16-bit unsigned
typedef unsigned long DWORD;				// 32-bit unsigned
typedef signed char CHAR;				// 8-bit signed
typedef signed short int SHORT;				// 16-bit signed
typedef signed long LONG;				// 32-bit signed

typedef union _BYTE_VAL {
	BYTE Val;
	struct {
		unsigned int b0 :1;
		unsigned int b1 :1;
		unsigned int b2 :1;
		unsigned int b3 :1;
		unsigned int b4 :1;
		unsigned int b5 :1;
		unsigned int b6 :1;
		unsigned int b7 :1;
	} bits;
} BYTE_VAL;

typedef union _WORD_VAL {
	WORD Val;
	BYTE v[2];
	struct {
		BYTE LB;
		BYTE HB;
	} byte;
	struct {
		unsigned int b0 :1;
		unsigned int b1 :1;
		unsigned int b2 :1;
		unsigned int b3 :1;
		unsigned int b4 :1;
		unsigned int b5 :1;
		unsigned int b6 :1;
		unsigned int b7 :1;
		unsigned int b8 :1;
		unsigned int b9 :1;
		unsigned int b10 :1;
		unsigned int b11 :1;
		unsigned int b12 :1;
		unsigned int b13 :1;
		unsigned int b14 :1;
		unsigned int b15 :1;
	} bits;
} WORD_VAL;

typedef union _DWORD_VAL {
	DWORD Val;
	WORD w[2];
	BYTE v[4];
	struct {
		WORD LW;
		WORD HW;
	} word;
	struct {
		BYTE LB;
		BYTE HB;
		BYTE UB;
		BYTE MB;
	} byte;
	struct {
		unsigned int b0 :1;
		unsigned int b1 :1;
		unsigned int b2 :1;
		unsigned int b3 :1;
		unsigned int b4 :1;
		unsigned int b5 :1;
		unsigned int b6 :1;
		unsigned int b7 :1;
		unsigned int b8 :1;
		unsigned int b9 :1;
		unsigned int b10 :1;
		unsigned int b11 :1;
		unsigned int b12 :1;
		unsigned int b13 :1;
		unsigned int b14 :1;
		unsigned int b15 :1;
		unsigned int b16 :1;
		unsigned int b17 :1;
		unsigned int b18 :1;
		unsigned int b19 :1;
		unsigned int b20 :1;
		unsigned int b21 :1;
		unsigned int b22 :1;
		unsigned int b23 :1;
		unsigned int b24 :1;
		unsigned int b25 :1;
		unsigned int b26 :1;
		unsigned int b27 :1;
		unsigned int b28 :1;
		unsigned int b29 :1;
		unsigned int b30 :1;
		unsigned int b31 :1;
	} bits;
} DWORD_VAL;

#ifndef NULL
#define NULL 0
#endif

#endif //__GENERIC_TYPE_DEFS_H_

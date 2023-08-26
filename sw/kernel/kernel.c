#include <conio.h>

// char* string = \
// "This is a very long string that is meant to test the loader.\
//  We can only load one cluster so far, which means 8 sectors of\
//  512bytes, or a total of 4k. If there was any more data than this,\
//  then we would have to traverse the fat to find the next cluster number.\
//  This may not be that difficult, but the file will need to be large\
//  enough to actually stretch that far. The kernel will probably be\
//  that big in the future, but for now when it doesnt really do anything\
//  then it can't really be tested.";


int main() {
    // char* string = "this is a shorter string";

    int x = 2;

    cprintf("Hello, world!\r\n");
    cprintf("Here is a value: %x", x);

    // cprintf("Here is a long string: %s\r\n", string);

    while(1);

    return 0;
}
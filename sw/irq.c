
// This is defined in main.c
void puts(const char* s);

void handle_irq() {
    puts("Interrupt Detected!\n");
}
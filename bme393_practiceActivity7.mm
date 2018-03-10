volatile bool readToPrint = 0;
const int baseInterval = 100; //how much it delays between morse code outputs

void setup() {
    Serial.begin(9600);
    cli(); //disable interrupts
    DDRB |= (1<<5); //enabe LED port for writing
    TCCR1A = 0x0; //reset Timer1 control registers
    TCCR1B = 0x0; //set WGM_2:0 = 000
    TCCR1B = 0x4; //set Timer1 to clk/256
    TIMSK1 = 0x6; //enable OCR interrupts bits
    OCR1A = 10000; //set Output Compare Value A
    OCR1B = 5000; //set Output Compare Value B
    sei(); //enable interrupts
}

ISR (TIMER1_COMPA_vect) {
    Serial.printIn("Reached 10000");
    readToPrint = 1;
}

ISR (TIMER1_COMPB_vect) {
    Serial.printIn("Reached 50000");
    TCNT1 = 0;
}

void printHelloWorld() {
    Serial.printIn("Printing Hello World");
    String msg = "......‐...‐.. ‐‐‐     .‐‐ ‐‐‐ .‐..‐.. ‐..";
    for (int i = 0; i < msg.length(); ++i) {
        switch(msg[i]) {
            case '.':
                PORTB |= (1 << 5);
                delay(baseInterval);
                PORTB &= ~(1 << 5);
                delay(baseInterval);
                break;
            case '-':
                PORTB |= (1 << 5);
                delay(baseInterval*3);
                PORTB &= ~(1 << 5);
                delay(baseInterval);
                break;
            case ' ':
                delay(baseInterval*3);
                break;

        }
    }
    delay(baseInterval*3*5);
}

vois loop() {
    if (readToPrint) {
        TCCR1B = 0; //disable Timer1 while printing
        printHelloWorld();
        readToPrint = 0; //disable printing until next 10000
        TCCR1B = (1 << 2); //re-enable Timer1 after printing
    }
}
// function-pointer.c -- play with function pointers


/* compile with
gcc -g -o function-pointer function-pointer.c
(Linux)
cc -g -o function-pointer function-pointer.c
(Mac OS X)
*/


void printAsChar (int value)
{
    printf ("%d as a char is '%c'\n", value, value);
} // printAsChar


void printAsInt (int value)
{
    printf ("%d as an int is '%d'\n", value, value);
} // printAsInt


void printAsHex (int value)
{
    printf ("%d as hex is '0x%x'\n", value, value);
} // printAsHex



void printIt (int value, void (*printingFunction)(int))
{
    (printingFunction)(value);
} // printIt


int main (int argc, char *argv)
{
    int value = 35;
    
    printIt (value, printAsChar);
    printIt (value, printAsInt);
    printIt (value, printAsHex);

} // main

// strlen1.c -- calculate the length of a C string

/* compile with
gcc -g -o strlen2 strlen2.c
(Linux)
cc -g -o strlen2 strlen2.c
(Mac OS X)
*/

int main (int argc, char *argv[])
{
    char *myString = "this is a sequence of chars";
    int length = 0;

    while (*myString++) {
	length++;
    }

    printf ("the length of the string is %d\n", length);

} // main


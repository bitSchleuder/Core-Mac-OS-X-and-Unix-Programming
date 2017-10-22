// constants.c -- show various constants

/* compile with:
cc -g -o constants constants.c
*/

#include <stdio.h>      // for printf()

int main (int argc, char *argv[])
{
    printf ("some integer constants: %d %d %d %d\n",
            1, 3, 32767, -521);
    printf ("some floating-point constants: %f %f %f %f\n",
            3.14159, 1.414213, 1.5, 2.0);
    printf ("single character constants: %c%c%c%c%c\n",
            'W', 'P', '\114', '\125', '\107');
    printf ("and finally a character string constant: '%s'\n",
            "this is a string");

    return (0);

} // main

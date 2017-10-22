// malloccheckstart.m -- play with MallocCheckHeapStart
// run this, then run after doing a 'setenv MallocCheckHeapStart 100' in the shell

/* compile wth
cc -o malloccheckstart malloccheckstart.m
*/

#import <stdlib.h>

int main (int argc, char *argv[])
{
    int i;
    unsigned char *memory;

    for (i = 0; i < 10000; i++) {
	memory = malloc (10);

	if (i == 3783) {
	    // smash some memory
	    memset (memory-16, 0x55, 26);
	}
    }

} // main

struct Person {
    char   *name;
    int     age;
    char    gender; // use 'm', 'f'
    double  shoeSize;
    int end;
};

#define offset(a,b) ( ((int)&(a.b)) - ((int)&(a)) )

void main (void)
{
    struct Person ack;

    printf ("%d %d %d %d %d\n",
	    offset(ack, name), offset(ack,age), offset(ack,gender),
	    offset(ack, shoeSize), offset(ack,end));
    printf ("%d\n", sizeof(struct Person));

} // main

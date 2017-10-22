// limits.m -- see the resource limits in force

/* compile with:
cc -g -Wall -o limits limits.m
*/

#import <sys/types.h>
#import <sys/time.h>
#import <sys/resource.h>
#import <stdio.h>
#import <string.h>
#import <errno.h>

typedef struct Limit {
    int resource;
    const char *name;
} Limit;

Limit limits[] = {
    { RLIMIT_DATA,      "data segment maximum (bytes)" },
    { RLIMIT_RSS,       "resident size maximum (bytes)" },
    { RLIMIT_STACK,     "stack size maximum (bytes)" },
    { RLIMIT_MEMLOCK,   "wired memory maximum (bytes)" },
    { RLIMIT_FSIZE,     "file size maximum (bytes)" },
    { RLIMIT_NOFILE,    "max number of simultaneously open files" },
    { RLIMIT_NPROC,     "max number of simultaneous processes" },
    { RLIMIT_CPU,       "cpu time maximum (seconds)" },
    { RLIMIT_CORE,      "core file maximum (bytes)" }
};

// turn the rlim_t value in to a string, also translating the magic
// "infinity" value to something human readable
void stringValue (rlim_t value, char *buffer, size_t buffersize)
{
    if (value == RLIM_INFINITY) {
        strcpy (buffer, "infinite");
    } else {
        snprintf (buffer, buffersize, "%lld", value);
    }
} // stringValue

// right-justify the first entry in a field width of 45, then display
// two more strings

#define FORMAT_STRING "%45s: %-10s (%s)\n"

int main (int argc, char *argv[])
{
    struct rlimit rl;
    Limit *scan, *stop;

    scan = limits;
    stop = scan + (sizeof(limits) / sizeof(Limit));

    printf (FORMAT_STRING, "limit name", "soft-limit", "hard-limit");

    while (scan < stop) {
        if (getrlimit (scan->resource, &rl) == -1) {
            fprintf (stderr, "error in getrlimit for %s: %d/%s\n",
                     scan->name, errno, strerror(errno));
        } else {
            char soft[20];
            char hard[20];

            stringValue (rl.rlim_cur, soft, 20);
            stringValue (rl.rlim_max, hard, 20);
            
            printf (FORMAT_STRING, scan->name, soft, hard);
        }
        scan++;
    }
    return (0);
} // main

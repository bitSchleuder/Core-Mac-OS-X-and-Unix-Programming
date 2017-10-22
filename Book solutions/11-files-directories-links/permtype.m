// permtype.m -- use stat to discover the type and permissions
//               for a file

/* compile with:
cc -g -Wall -o permtype permtype.m
*/

#import <sys/stat.h>    // for stat() and struct stat
#import <stdlib.h>      // for EXIT_SUCCESS
#import <stdio.h>       // for printf
#import <errno.h>       // for errno
#import <grp.h>         // for group file access routines
#import <pwd.h>         // for passwd file access routines
#import <sys/time.h>    // for struct tm, localtime, etc
#import <string.h>      // for strerror


// cheesy little lookup table for mapping perm value to the 
// familiar character string
static const char *g_perms[]  = {
    "---", "--x", "-w-", "-wx", "r--", "r-x", "rw-", "rwx"
};

typedef struct StatType {
    unsigned long       mask;
    const char         *type;
} StatType;

static StatType g_types[] = {
    { S_IFREG, "Regular FIle" },
    { S_IFDIR, "Directory" },
    { S_IFLNK, "Symbolic Link" },
    { S_IFCHR, "Character Special Device" },
    { S_IFBLK, "Block Special Device" },
    { S_IFIFO, "FIFO" },
    { S_IFSOCK, "Socket" },
};

void displayInfo (const char *filename)
{
    int result;
    struct stat statbuf;
    StatType *scan, *stop;

    result = lstat (filename, &statbuf);

    if (result == -1) {
        fprintf (stderr, "error with stat(%s) :  %d (%s)\n",
                 filename, errno, strerror(errno));
        return;
    }

    printf ("%s:\n", filename);

    printf ("  permissions: %s%s%s\n",
            g_perms[(statbuf.st_mode & S_IRWXU) >> 6],
            g_perms[(statbuf.st_mode & S_IRWXG) >> 3],
            g_perms[(statbuf.st_mode & S_IRWXO)]);

    // figure out the type
    scan = g_types;
    stop = scan + (sizeof(g_types) / sizeof(StatType));

    while (scan < stop) {
        if ((statbuf.st_mode & S_IFMT) == scan->mask) {
            printf ("  type: %s\n", scan->type);
            break;
        }
        scan++;
    }
    
    // any special bits sets?
    if ((statbuf.st_mode & S_ISUID) == S_ISUID) {
        printf ("  set-uid!\n");
    }   
    if ((statbuf.st_mode & S_ISGID) == S_ISUID) {
        printf ("  set-group-id!\n");
    }

    // file size
    printf ("  file is %ld bytes (%f K)\n", 
            (long)statbuf.st_size,
            (float) (statbuf.st_size / 1024.0));

    // owning user / group
    {
        struct passwd *passwd;
        struct group *group;

        passwd = getpwuid (statbuf.st_uid);
        group = getgrgid (statbuf.st_gid);
        
        printf ("  user: %s (%d)\n", passwd->pw_name, statbuf.st_uid);
        printf ("  group: %s (%d)\n", group->gr_name, statbuf.st_gid);
    }

    // now the dates
    {
        char buffer[1024];
        struct tm *tm;

        tm = localtime (&statbuf.st_atime);
        strftime (buffer, 1024, "%m/%d/%Y", tm);
        printf ("  last access: %s\n", buffer);

        tm = localtime (&statbuf.st_mtime);
        strftime (buffer, 1024, "%m/%d/%Y", tm);
        printf ("  last modification: %s\n", buffer);

        tm = localtime (&statbuf.st_ctime);
        strftime (buffer, 1024, "%m/%d/%Y", tm);
        printf ("  last inode change: %s\n", buffer);
    }

    // double-space output
    printf ("\n");

} // displayInfo

int main (int argc, char *argv[])
{
    int i;

    if (argc == 1) {
        fprintf (stderr, "usage:  %s /path/to/file ... \n", argv[0]);
        exit (EXIT_FAILURE);
    }

    for (i = 1; i < argc; i++) {
        displayInfo (argv[i]);
    }

    exit (EXIT_SUCCESS);

} // main

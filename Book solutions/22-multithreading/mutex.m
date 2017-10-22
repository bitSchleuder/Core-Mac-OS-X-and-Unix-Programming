// copy basic.m to mutex.m first, then change threadFunction to this:



void *threadFunction (void *argument)
{
    ThreadInfo *info = (ThreadInfo *) argument;
    int result, i;

    printf ("thread %d, counting to %d, detaching %s\n",
            info->index, info->numberToCountTo, 
            (info->detachYourself) ? "yes" : "no");

    if (info->detachYourself) {
        result = pthread_detach (pthread_self());
        if (result != 0) {
            fprintf (stderr, "could not detach thread %d. Error: %d/%s\n",
                     info->index, result, strerror(result));
        }
    }

    // now to do the actual "work" of the thread

    

    for (i = 0; i < info->numberToCountTo; i++) {
        printf ("  thread %d counting %d\n", info->index, i);
        usleep (info->sleepTime);
    }

    

    printf ("thread %d done\n", info->index);

    return (NULL);

} // threadFunction

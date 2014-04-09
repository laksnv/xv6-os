/* MULTI-THREADED SORTING IN LINUX */           // And not in xv6


#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <string.h>

#define SIZE 10
int a[SIZE], count = 0;

pthread_t thread[SIZE];
pthread_mutex_t lock[SIZE + 1];


void *sort (void *index);
void *check (void * temp);

int main()
{
    int i;

    for(i = 0; i < SIZE; i++)
        a[i] = i;
    
    for(i = 0; i < SIZE; i++)
    {    
        if (pthread_mutex_init(&lock[i], NULL) != 0)
        {
            printf("\nMutex init failed\n");
            return 1;
        }
    }
    
    while(1)
    {
        for(i = 1; i < SIZE; i++)
        {
            int ret = pthread_create(&thread[i - 1], NULL, sort, (void *) &i);
            if (ret != 0)
                printf("\nCan't create thread :[%s]", strerror(ret));
            pthread_join( thread[i], NULL);
        }
        
        int ret = pthread_create(&thread[SIZE - 1], NULL, check, NULL);
        if (ret != 0)
            printf("\nCan't create thread :[%s]", strerror(ret));
        pthread_join( thread[SIZE - 1], NULL);

        
        for(i = 0; i < SIZE - 1; i++)
            pthread_join( thread[i], NULL);
    }     
         
    for(i = 0; i < SIZE; i++)
        pthread_mutex_destroy(&lock[i]);
        
    return 0;
}

void *sort(void *index)
{
    int right = *((int *) index), left = right - 1;
    
    pthread_mutex_lock(&lock[left]);
    pthread_mutex_lock(&lock[right]);

    count++;
    if((a[left] < a[right]) && (left >= 0) && (right < SIZE))
    {
        int temp = a[left];
        a[left] = a[right];
        a[right] = temp;
    }

    pthread_mutex_unlock(&lock[right]);
    pthread_mutex_unlock(&lock[left]);
    
    pthread_exit(NULL);
}

void *check (void * temp)
{
    pthread_mutex_lock(&lock[SIZE]);
    
    for(int i = 0; i < SIZE - 1; i++)
        if(a[i] < a[i + 1])
            pthread_exit(NULL);

    for(int i = 0; i < 10; i++)
        printf("%d ", a[i]);
    printf("\n Sorted; Count = %d \n", count/10);
    
    exit(0);
    pthread_mutex_unlock(&lock[SIZE]);
}
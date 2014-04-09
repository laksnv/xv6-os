#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <string.h>

#define SIZE 10

pthread_t thread[SIZE - 1];
pthread_mutex_t lock;


void *sort(void *index);
int a[SIZE];

int main()
{
    int i;

    for(i = 0; i < 10; i++)
        a[i] = i;
        
    if (pthread_mutex_init(&lock, NULL) != 0)
    {
        printf("\n mutex init failed\n");
        return 1;
    }
    
    for(int j = 0; j < SIZE * SIZE; j++)
    {
        for(i = 1; i < SIZE; i++)
        {
            int ret = pthread_create(&thread[i - 1], NULL, sort, (void *) &i);
            if (ret != 0)
                printf("\ncan't create thread :[%s]", strerror(ret));
        }

        for(i = 0; i < 10; i++)
            pthread_join( thread[i], NULL);
    
         pthread_mutex_destroy(&lock);
    }     
     
    for(i = 0; i < 10; i++)
        printf("%d ", a[i]);
    printf("\n");
    
    
    pthread_exit(NULL);
}

void *sort(void *index)
{
    pthread_mutex_lock(&lock);
    
    int right = *((int *) index), left = right - 1;

    if((a[left] < a[right]) && (left >= 0) && (right < SIZE))
    {
        int temp = a[left];
        a[left] = a[right];
        a[right] = temp;
    }
    
    pthread_mutex_unlock(&lock);
    pthread_exit(NULL);
}



#include <stdio.h>
#include <string.h>

int fma(int a, int b[]);

int main(void)
{
    int a = 3;
    int b[4] = {5, 7, 9, 2};
    int c[4];

    //strcpy(c, fma(a,b));
    fma(a,b);

    return 0;
}

int fma(int a, int b[])
{
    int c[4];
    int i;
    for(i = 0; i < 4; i++)
    {
        c[i] = a * b[i] + c[i];
    }

    return c;
}

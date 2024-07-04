#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#include "nand.h"

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-result"


/*

Operations:

    1 k                 - Create a new gate with k inputs.
    2 x                 - Delete gate number x.
    3 x y k             - Connect the output of gate x to the kth input 
                          of gate y.
    4 x y k             - Connect signal x to the kth input of gate y.
    5 n a_1 a_2 ... a_n - For every possible configuration of boolean 
                          signals (as if enumerating from 0 to 2^n-1
                          in binary), evaluate outputs of gates a_1 
                          a_2 ... a_n and print their outputs in the 
                          respective order of appearance. On the next 
                          line print the length of the critical path.
                          If there is an error, output -1 instead.
    6 x                 - Print the number of gates currently connected
                          to the output of gate x and then their ids.
                          The ids should appear in non-decreasing order.
    7 x                 - Print all inputs of gate x in the following 
                          format:
                            * N    if the input is empty,
                            * sNUM if the input is a boolean signal and 
                                   NUM is its id,
                            * gNUM if the input is a nand gate and NUM 
                                   is its id.

*/

int less(const void *a, const void *b) {
    return *((int*)a) > *((int*)b);
}

int main() {
    int n, q; // n - number of boolean signals, q - number of queries
    scanf("%d%d", &n, &q);
    
    bool *s = malloc(sizeof(bool) * n);
    
    for(int i = 0; i < n; i++)
        s[i] = false;
    
    nand_t **g = (nand_t**)malloc(sizeof(nand_t*) * q);
    int *in_degs = (int*)malloc(sizeof(int) * q);
    for(int i = 0; i < q; i++) {
        g[i] = NULL;
        in_degs[i] = 0;
    }
    int g_front = 0;
    
    for(int i = 0; i < q; i++) {
        int op;
        scanf("%d", &op);
        
        if(op == 1) {
            scanf("%d", &in_degs[g_front]);
            g[g_front] = nand_new(in_degs[g_front]);
            g_front++;
        } else if(op == 2) {
            int x;
            scanf("%d", &x);
            nand_delete(g[x]);
            g[x] = NULL;
        } else if(op == 3) {
            int x, y, k;
            scanf("%d%d%d", &x, &y, &k);
            nand_connect_nand(g[x], g[y], k);
        } else if(op == 4) {
            int x, y, k;
            scanf("%d%d%d", &x, &y, &k);
            nand_connect_signal(s + x, g[y], k);
        } else if(op == 5) {
            int k;
            scanf("%d", &k);
            nand_t **my_g = (nand_t**)malloc(sizeof(nand_t*) * k);
            bool *r = (bool*)malloc(sizeof(bool) * k);
            for(int j = 0; j < k; j++) {
                my_g[j] = NULL;
                r[j] = false;
            }
            for(int j = 0; j < k; j++) {
                int x;
                scanf("%d", &x);
                my_g[j] = g[x];
            }
            
            for(int mask = 0; mask < (1 << n); mask++) {
                
                for(int bit = 0; bit < n; bit++)
                    s[bit] = (mask >> bit) & 1;
                int path = nand_evaluate(my_g, r, k);
                if(path != -1) {
                    for(int j = 0; j < k; j++)
                        printf("%d ", r[j]);
                    printf("%d\n", path);
                } else {
                    printf("-1\n");
                }
                
            }
            
            free(my_g);
            free(r);
            
        } else if(op == 6) {
            int x;
            scanf("%d", &x);
            int l = nand_fan_out(g[x]);
            int *a = malloc(sizeof(int) * l);
            for(int i = 0; i < l; i++) {
                nand_t *my_g = nand_output(g[x], i);
                for(int j = 0; j < q; j++) {
                    if(my_g == g[j]) {
                        a[i] = j;
                    }
                }
            }
            qsort(a, l, sizeof(int), less);
            
            printf("%d ", l);
            for(int i = 0; i < l; i++)
                printf("%d ", a[i]);
            printf("\n");
            
            free(a);
        } else if(op == 7) {
            
            int x;
            scanf("%d", &x);
            
            for(int j = 0; j < in_degs[x]; j++) {
                void *v = nand_input(g[x], j);
                
                if(v == NULL) {
                    printf("N ");
                } else {
                    for(int k = 0; k < q; k++)
                        if(v == g[k])
                            printf("g%d ", k);
                    
                    for(int k = 0; k < n; k++)
                        if(v == (s + k))
                            printf("s%d ", k);
                }
                
            }
            
            printf("\n");
            
        } else {
            printf("INVALID OPERATION\n");
        }
    }
    
    free(s);
    free(in_degs);
    for(int i = 0; i < q; i++)
        nand_delete(g[i]);
    free(g);
    
    return 0;
}

#pragma GCC diagnostic pop

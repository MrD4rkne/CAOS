#include "stdio.h"
#include <signal.h>
#include <assert.h>
#include <inttypes.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// To jest deklaracja testowanej funkcji.
int64_t mdiv(int64_t* x, size_t n, int64_t y);

static void proceed();

static int testCounter = 0;
static int testCount = 0;

static void ovfHandler(int signum) {
  if (signum != SIGFPE) {
    printf("unexpected signal %d", signum);
  }
  else {
    printf("ovf\n");
  }
  proceed();
}

static void calculate() {
  signal(SIGFPE, ovfHandler);
  printf("Test %d\n", testCounter);
  int64_t n;
  scanf("%ld", &n);

  int64_t* x = (int64_t*)malloc(n * sizeof(int64_t));
  for (int i = 0; i < n; i++) {
    scanf("%ld", &x[i]);
  }

  int64_t y;
  scanf("%ld", &y);

  int64_t mod = mdiv(x, n, y);

  for (int i = 0; i < n; i++) {
    printf("%ld\n", x[i]);
  }
  printf("%ld\n", mod);
}

static void proceed() {
  while (true) {
    testCounter++;
    if (testCounter > testCount) {
      exit(0);
      return;
    }
    calculate();
  }
}

int main() {
  scanf("%d", &testCount);
  testCounter = 0;

  proceed();
  return 0;
}


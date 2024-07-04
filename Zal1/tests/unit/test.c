#ifdef NDEBUG
#undef NDEBUG
#endif

#include "nand.h"
#include "memory_tests.h"
#include <assert.h>
#include <errno.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <stdint.h>
#include <stdlib.h>

/** MAKRA SKRACAJĄCE IMPLEMENTACJĘ TESTÓW **/

// To są możliwe wyniki testu.
#define PASS 0
#define FAIL 1
#define WRONG_TEST 2

// Oblicza liczbę elementów tablicy x.
#define SIZE(x) (sizeof x / sizeof x[0])

#define TEST_ECANCELED(f)                \
  do {                                   \
    errno = 0;                           \
    if ((f) != -1 || errno != ECANCELED) \
      return FAIL;                       \
  } while (0)

#define TEST_PASS(f)                     \
  do {                                   \
    if ((f) != 0)                        \
      return FAIL;                       \
  } while (0)

#define ASSERT(f)                        \
  do {                                   \
    if (!(f))                            \
      return FAIL;                       \
  } while (0)

#define V(code, where) (((unsigned long)code) << (3 * where))

#define ASSERT_ERRNO(f)                 \
  do {                                   \
    if (errno != (f))                        \
      return FAIL;                       \
    errno = 0;                           \
  } while (0)

#define SET_FAIL_MEMORY(k) \
  do{ \
    get_memory_test_data()->fail_counter = get_memory_test_data()->call_counter + k; \
  }while(0) \

/** WŁAŚCIWE TESTY **/
static int test_nand_delete(void) {
  errno = 0;

  nand_delete(NULL);
  ASSERT_ERRNO(0);

  nand_t* g0 = nand_new(2);
  ASSERT(g0 != NULL);

  nand_t* g1 = nand_new(11);
  ASSERT(g1 != NULL);

  for (int i = 0; i <= 9; i++) {
    ASSERT(nand_connect_nand(g0, g1, i) == 0);
    ASSERT_ERRNO(0);
  }
  // overwrite
  for (int i = 0; i <= 9; i++) {
    ASSERT(nand_connect_nand(g0, g1, i) == 0);
    ASSERT_ERRNO(0);
  }

  ASSERT(nand_fan_out(g0) == 10);
  ASSERT_ERRNO(0);

  ASSERT(nand_fan_out(g1) == 0);
  ASSERT_ERRNO(0);

  nand_delete(g1);

  ASSERT(nand_fan_out(g0) == 0);
  ASSERT_ERRNO(0);

  for (int i = 0; i <= 9; i++) {
    ASSERT(nand_output(g0, i) == NULL);
    ASSERT_ERRNO(EINVAL);
  }

  nand_delete(g0);

  g0 = nand_new(2);
  ASSERT(g0 != NULL);
  ASSERT_ERRNO(0);
  g1 = nand_new(11);
  ASSERT(g1 != NULL);
  ASSERT_ERRNO(0);

  for (int i = 0; i <= 9; i++) {
    ASSERT(nand_connect_nand(g0, g1, i) == 0);
    ASSERT_ERRNO(0);
  }
  for (int i = 0; i <= 9; i++) {
    ASSERT(nand_connect_nand(g0, g1, i) == 0);
    ASSERT_ERRNO(0);
  }

  ASSERT(nand_fan_out(g0) == 10);
  ASSERT_ERRNO(0);

  ASSERT(nand_fan_out(g1) == 0);
  ASSERT_ERRNO(0);

  nand_delete(g0);
  g0 = NULL;

  ASSERT(nand_fan_out(g1) == 0);
  ASSERT_ERRNO(0);

  for (int i = 0; i <= 10; i++) {
    ASSERT(nand_input(g1, i) == NULL);
    ASSERT_ERRNO(0);
  }

  nand_delete(g1);


  return PASS;
}

static int test_nand_connect_nand() {
  errno = 0;

  nand_t* g0 = nand_new(0);
  nand_t* g1 = nand_new(100);

  ASSERT(g0 != NULL);
  ASSERT(g1 != NULL);

  ASSERT(nand_connect_nand(g1, g0, 0) == -1);
  ASSERT_ERRNO(EINVAL);

  ASSERT(nand_connect_nand(g0, g1, 101) == -1);
  ASSERT_ERRNO(EINVAL);

  ASSERT(nand_connect_nand(g1, g0, 101) == -1);
  ASSERT_ERRNO(EINVAL);

  ASSERT(nand_connect_nand(NULL, g1, 1) == -1);
  ASSERT_ERRNO(EINVAL);

  ASSERT(nand_connect_nand(NULL, NULL, 1) == -1);
  ASSERT_ERRNO(EINVAL);

  ASSERT(nand_connect_nand(g0, NULL, 1) == -1);
  ASSERT_ERRNO(EINVAL);

  ASSERT(nand_connect_nand(g0, g1, 55) == 0);
  ASSERT_ERRNO(0);

  nand_delete(g0);
  nand_delete(g1);

  return PASS;
}

static int test_nand_connect_signal() {
  errno = 0;

  nand_t* g0 = nand_new(0);
  bool b[2] = { true,false };

  ASSERT(g0 != NULL);

  ASSERT(nand_connect_signal(NULL, NULL, 1000) == -1);
  ASSERT_ERRNO(EINVAL);

  ASSERT(nand_connect_signal(NULL, g0, 1000) == -1);
  ASSERT_ERRNO(EINVAL);

  ASSERT(nand_connect_signal(NULL, g0, 0) == -1);
  ASSERT_ERRNO(EINVAL);

  ASSERT(nand_connect_signal(&b[0], g0, 1000) == -1);
  ASSERT_ERRNO(EINVAL);

  ASSERT(nand_connect_signal(&b[0], g0, 0) == -1);
  ASSERT_ERRNO(EINVAL);

  ASSERT(nand_connect_signal(&b[0], NULL, 0) == -1);
  ASSERT_ERRNO(EINVAL);

  nand_delete(g0);

  nand_t* g1 = nand_new(1000);
  ASSERT(nand_connect_signal(NULL, NULL, 1000) == -1);
  ASSERT_ERRNO(EINVAL);

  ASSERT(nand_connect_signal(NULL, g1, 1000) == -1);
  ASSERT_ERRNO(EINVAL);

  ASSERT(nand_connect_signal(NULL, g1, 999) == -1);
  ASSERT_ERRNO(EINVAL);

  ASSERT(nand_connect_signal(&b[0], g1, 1000) == -1);
  ASSERT_ERRNO(EINVAL);

  ASSERT(nand_connect_signal(&b[1], g1, 999) == 0);
  ASSERT_ERRNO(0);

  ASSERT(nand_connect_signal(&b[0], NULL, 0) == -1);
  ASSERT_ERRNO(EINVAL);

  ASSERT(nand_connect_signal(&b[0], g1, 0) == 0);
  ASSERT_ERRNO(0);

  nand_delete(g1);

  return PASS;
}

int test_nand_evaluate() {
  nand_t* g0 = nand_new(0);
  nand_t* g1 = nand_new(1);
  nand_t* g2 = nand_new(2);
  nand_t* g3 = nand_new(3);
  nand_t* g4 = nand_new(4);
  nand_t* gates[5] = { g0,g1,g2,g3,g4 };
  bool b[5] = {};

  ASSERT(nand_evaluate(NULL, NULL, 10) == -1);
  ASSERT_ERRNO(EINVAL);

  ASSERT(nand_evaluate(NULL, b, 10) == -1);
  ASSERT_ERRNO(EINVAL);

  ASSERT(nand_evaluate(gates, NULL, 10) == -1);
  ASSERT_ERRNO(EINVAL);

  ASSERT(nand_evaluate(gates, b, 0) == -1);
  ASSERT_ERRNO(EINVAL);

  nand_t* gates2[5] = { g0,g1,g2,g3,NULL };
  ASSERT(nand_evaluate(gates2, b, 5) == -1);
  ASSERT_ERRNO(EINVAL);

  nand_delete(g0);
  nand_delete(g1);
  nand_delete(g2);
  nand_delete(g3);
  nand_delete(g4);

  return PASS;
}

int test_nand_fan_out() {
  ASSERT(nand_fan_out(NULL) == -1);
  ASSERT_ERRNO(EINVAL);

  return PASS;
}

int test_nand_input() {
  nand_t* g0 = nand_new(1);
  ASSERT(g0 != NULL);

  errno = 1;
  ASSERT(nand_input(g0, 0) == NULL);
  ASSERT_ERRNO(0);

  ASSERT(nand_input(g0, 1) == NULL);
  ASSERT_ERRNO(EINVAL);

  ASSERT(nand_input(NULL, 0) == NULL);
  ASSERT_ERRNO(EINVAL);

  nand_delete(g0);

  return PASS;
}

int test_nand_output() {
  errno = 0;

  nand_t* g0 = nand_new(2);
  ASSERT(g0 != NULL);
  ASSERT_ERRNO(0);

  nand_t* g1 = nand_new(11);
  ASSERT(g1 != NULL);

  ASSERT_ERRNO(0);
  for (int i = 0; i <= 9; i++) {
    ASSERT(nand_connect_nand(g0, g1, i) == 0);
    ASSERT_ERRNO(0);
  }
  for (int i = 0; i <= 9; i++) {
    ASSERT(nand_connect_nand(g0, g1, i) == 0);
    ASSERT_ERRNO(0);
  }

  ASSERT(nand_fan_out(g0) == 10);
  ASSERT_ERRNO(0);

  ASSERT(nand_fan_out(g1) == 0);
  ASSERT_ERRNO(0);

  for (int i = 0; i <= 9; i++) {
    ASSERT(nand_output(g0, i) == g1);
    ASSERT_ERRNO(0);

    ASSERT(nand_input(g1, i) == g0);
    ASSERT_ERRNO(0);
  }

  ASSERT(nand_input(g1, 10) == NULL);
  ASSERT_ERRNO(0);

  ASSERT(nand_output(g0, 10) == NULL);
  ASSERT_ERRNO(EINVAL);

  ASSERT(nand_output(g0, 11) == NULL);
  ASSERT_ERRNO(EINVAL);

  ASSERT(nand_output(g1, 0) == NULL);
  ASSERT_ERRNO(EINVAL);

  ASSERT(nand_output(NULL, 0) == NULL);
  ASSERT_ERRNO(EINVAL);

  nand_delete(g1);

  ASSERT(nand_fan_out(g0) == 0);
  ASSERT_ERRNO(0);

  for (int i = 0; i <= 9; i++) {
    ASSERT(nand_output(g0, i) == NULL);
    ASSERT_ERRNO(EINVAL);
  }

  nand_delete(g0);

  return PASS;
}

int test_cycles() {
  errno = 0;

  nand_t* g0 = nand_new(2);
  ASSERT(g0 != NULL);
  ASSERT_ERRNO(0);

  nand_t* g1 = nand_new(0);
  ASSERT(g0 != NULL);
  ASSERT_ERRNO(0);

  ASSERT(nand_connect_nand(g1, g0, 0) == 0);
  ASSERT_ERRNO(0);

  nand_t* g[2] = { g0,g1 };
  bool b[2] = {};
  ASSERT(nand_evaluate(g, b, 2) == -1);
  ASSERT_ERRNO(ECANCELED);

  bool b2 = false;
  ASSERT(nand_connect_signal(&b2, g0, 1) == 0);
  ASSERT_ERRNO(0);

  ASSERT(nand_evaluate(g, b, 2) == 1);
  ASSERT(b[0] == true);
  ASSERT(b[1] == false);
  ASSERT_ERRNO(0);

  ASSERT(nand_connect_nand(g0, g0, 1) == 0);
  ASSERT_ERRNO(0);

  ASSERT(nand_evaluate(g, b, 2) == -1);
  ASSERT_ERRNO(ECANCELED);

  nand_delete(g0);
  nand_delete(g1);

  return PASS;
}

static int example(void) {
  TEST_PASS(test_nand_connect_nand());
  TEST_PASS(test_nand_connect_signal());
  TEST_PASS(test_nand_delete());
  TEST_PASS(test_nand_evaluate());
  TEST_PASS(test_nand_fan_out());
  TEST_PASS(test_nand_input());
  TEST_PASS(test_nand_output());

  TEST_PASS(test_cycles());

  return PASS;
}

// Testuje reakcję implementacji na niepowodzenie alokacji pamięci.
static int test_memory(void) {

  memory_tests_check();

  errno = 0;

  for (int i = 1; i <= 10; i++) {
    SET_FAIL_MEMORY(i);
    nand_t* g = nand_new(100);
    if (g == NULL) {
      ASSERT_ERRNO(ENOMEM);
    }
    else {
      ASSERT_ERRNO(0);
      nand_delete(g);
    }
  }

  SET_FAIL_MEMORY(0);

  nand_t* g0 = nand_new(1);
  ASSERT(g0 != NULL);

  nand_t* g1 = nand_new(100);
  ASSERT(g1 != NULL);

  int successCounter = 0;
  for (int i = 1; i <= 10; i++) {
    SET_FAIL_MEMORY(i);
    int res = nand_connect_nand(g0, g1, i);
    if (res == -1) {
      ASSERT_ERRNO(ENOMEM);
    }
    else {
      successCounter++;
    }
  }

  ASSERT(nand_fan_out(g0) == successCounter);
  for (int i = 0; i < successCounter; i++) {
    ASSERT(nand_output(g0, i) == g1);
  }

  for (int i = 1; i <= 10; i++) {
    SET_FAIL_MEMORY(i);
    int res = nand_connect_nand(g1, g0, 0);
    if (res == -1) {
      ASSERT_ERRNO(ENOMEM);
    }
    else {
      successCounter++;
    }
  }

  ASSERT(nand_fan_out(g1) == 1);
  ASSERT(nand_output(g1, 0) == g0);

  nand_delete(g0);

  ASSERT(nand_fan_out(g1) == 0);
  for (int i = 0; i < 100; i++) {
    ASSERT(nand_input(g1, i) == NULL);
    ASSERT_ERRNO(0);
  }

  nand_delete(g1);
  g1 = NULL;

  const int gatesCount = 50;
  nand_t** gates = NULL;
  while (gates == NULL) {
    gates = (nand_t**)malloc(gatesCount * sizeof(nand_t*));
  }

  for (int i = 0; i < gatesCount; i++) {
    gates[i] = NULL;
    while (gates[i] == NULL) {
      gates[i] = nand_new(i);
    }
  }

  int failIncrementer = 1;

  g0 = NULL;
  while (g0 == NULL) {
    g0 = nand_new(10);
  }

  successCounter = 0;
  for (int i = 2; i < gatesCount; i++) {
    SET_FAIL_MEMORY(failIncrementer++);
    failIncrementer = failIncrementer % 3;
    while (nand_connect_nand(g0, gates[i], 0) == -1) {
      ASSERT_ERRNO(ENOMEM);
      ASSERT(nand_fan_out(g0) == successCounter);
    }
    successCounter++;
    ASSERT_ERRNO(0);
    ASSERT(nand_fan_out(g0) == successCounter);
  }

  for (int i = 0; i < gatesCount; i++) {
    nand_delete(gates[i]);
  }
  free(gates);

  ASSERT(nand_fan_out(g0) == 0);

  nand_delete(g0);
  g0 = NULL;

  return PASS;
}

// Testuje reakcję implementacji na niepowodzenie alokacji pamięci.
static int memory(void) {
  return test_memory();
}

/** URUCHAMIANIE TESTÓW **/

typedef struct {
  char const* name;
  int (*function)(void);
} test_list_t;

#define TEST(t) {#t, t}

static const test_list_t test_list[] = {
  TEST(example),
  TEST(memory),
};

static int do_test(int (*function)(void)) {
  int result = function();
  if (result == PASS) {
    puts("Pass!");
  }
  else {
    puts("Fail!");
  }
  return result;
}

int main(int argc, char* argv[]) {
  if (argc == 2)
    for (size_t i = 0; i < SIZE(test_list); ++i)
      if (strcmp(argv[1], test_list[i].name) == 0)
        return do_test(test_list[i].function);

  fprintf(stderr, "Użycie:\n%s nazwa_testu\n", argv[0]);
  return WRONG_TEST;
}

#define MAX_CAPACITY SIZE_MAX/sizeof(void*)

#include <stdlib.h>
#include <stdbool.h>
#include <math.h>
#include <stdint.h>

#include "list.h"

struct lt
{
    void** array;
    size_t size;
    size_t capacity;
};

/// @brief Try to extend numeric capacity of list.
/// @param size pointer with current value of capacity to be changes
/// @return If operation was successfull
static bool try_multiply_capacity(size_t* size);

/// @brief Remove all occurences of value from array by moving all elements to the left.
/// @param array array to be modified
/// @param size size of array
/// @param value value to be removed
/// @return New size of array
static size_t remove_value(void** array, size_t size, const void* value);

/// @brief Extend list capacity.
/// @param list
/// @return true if successful, false otherwise
static bool extend_list(list_t list);

static const size_t DEFAULT_CAPACITY = 2;

list_t list_new()
{
    list_t newlist = (list_t)malloc(sizeof(struct lt));
    if (newlist == NULL)
    {
        return NULL;
    }

    newlist->array = (void**)calloc(DEFAULT_CAPACITY, sizeof(void*));
    if (newlist->array == NULL)
    {
        list_delete(newlist);
        newlist = NULL;
        return NULL;
    }

    newlist->size = 0;
    newlist->capacity = DEFAULT_CAPACITY;
    return newlist;
}

void list_remove_occurences(list_t list, void* value)
{
    list->size = remove_value(list->array, list->size, value);
}

bool list_push_back(list_t list, void* value)
{
    if (MAX_CAPACITY - 1 < list->size) {
        return false;
    }

    while (list->capacity < list->size + 1) {
        if (!extend_list(list)) {
            return false;
        }
    }

    list->array[list->size++] = value;
    return true;
}

void* list_get_elem_at(list_t list, size_t index)
{
    if (index >= list->size)
    {
        return NULL;
    }

    return list->array[index];
}

size_t list_get_size(list_t list)
{
    if (list == NULL)
    {
        return -1;
    }

    return list->size;
}

void list_delete(list_t list)
{
    if (list == NULL)
    {
        return;
    }

    if (list->array != NULL) {
        free(list->array);
        list->array = NULL;
    }
    free(list);
}

static const int GROWTH_FACTOR = 2;

static bool extend_list(list_t list)
{
    size_t newCapacity = list->capacity;
    if (!try_multiply_capacity(&newCapacity)) {
        return false;
    }

    void** realocatedArray = (void**)realloc(list->array, newCapacity * sizeof(void*));
    if (realocatedArray == NULL)
    {
        return false;
    }

    list->array = realocatedArray;

    // Fill unitialized values.
    for (size_t i = list->size; i < newCapacity; i++)
    {
        list->array[i] = NULL;
    }

    list->capacity = newCapacity;
    return true;
}

static bool try_multiply_capacity(size_t* capacity) {
    if (capacity == NULL) {
        return false;
    }

    size_t newCapacity = *capacity;
    if (SIZE_MAX / GROWTH_FACTOR / sizeof(void*) < newCapacity) {
        if (newCapacity == MAX_CAPACITY) {
            return false;
        }
        else {
            newCapacity = MAX_CAPACITY;
        }
    }
    else {
        newCapacity *= GROWTH_FACTOR;
    }

    *capacity = newCapacity * sizeof(void*);
    return true;
}

static size_t remove_value(void** array, size_t size, const void* value)
{
    size_t newSize = 0;
    for (size_t i = 0; i < size; i++)
    {
        if (array[i] != value)
        {
            array[newSize++] = array[i];
        }
    }
    return newSize;
}
#ifndef LIST_H
#define LIST_H

// Dynamically realocated array.
typedef struct lt* list_t;

/// @brief Create empty list with default capacity.
/// @return Empty list
list_t list_new();

/// @brief Remove all occurences of value from list.
/// @param list list to be modified
/// @param value value to be removed
void list_remove_occurences(list_t list, void* value);

/// @brief Add value to the end of list.
/// @param list list to be modified
/// @param value value to be added
/// @return true if successful, false otherwise
bool list_push_back(list_t list, void* value);

/// @brief Get element at index.
/// @param list list to be checked
/// @param index index of element
/// @return Element at index
void* list_get_elem_at(list_t list, size_t index);

/// @brief Get list size.
/// @param list list to be checked
/// @return List size
size_t list_get_size(list_t list);

/// @brief Destroy list object.
/// @param list list to be destroyed
void list_delete(list_t list);

#endif
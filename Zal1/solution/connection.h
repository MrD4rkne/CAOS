#ifndef CONNECTION_H
#define CONNECTION_H

#include "nand.h"

/// @brief Represents connection info between two NAND gates.
typedef struct connection* connection_t;

/// @brief Creates new connection.
/// @param source source NAND gate
/// @param target target NAND gate
/// @param targetInputIndex index of input socket of target gate
/// @return New connection or NULL if memory allocation failed
connection_t connection_new(nand_t* source, nand_t* target, ssize_t targetInputIndex);

/// @brief Gets source NAND gate of connection.
/// @param connection target connection
/// @return source NAND gate or NULL if connection is NULL
nand_t* connection_get_source(connection_t connection);

/// @brief Gets target NAND gate of connection.
/// @param connection target connection
/// @return target NAND gate or NULL if connection is NULL
nand_t* connection_get_target(connection_t connection);

/// @brief Gets index of input socket of target NAND gate.
/// @param connection target connection
/// @return index of input socket of target NAND gate or -1 if connection is NULL
ssize_t connection_get_target_input_index(connection_t connection);

/// @brief Destroys connection (or do nothing if null).
/// @param connection target connection
void connection_delete(connection_t connection);

#endif
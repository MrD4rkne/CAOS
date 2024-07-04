#ifndef SOCKET_H
#define SOCKET_H

#include <stdbool.h>

#include "nand.h"
#include "connection.h"

typedef struct sct* socket_t;

enum sct_s {
    SIGNAL = 0,
    GATE = 1,
    DISCONNECTED = 2,
    UNDEFINED = 3
};

/// @brief Represents status of socket.
typedef enum sct_s socket_status;

/// @brief Creates new socket.
/// @return New socket or NULL if memory allocation failed
socket_t socket_new();

/// @brief Plugs bool signal into socket.
/// @param socket target socket
/// @param val signal to plug
void socket_plug_signal(socket_t socket, bool const* val);

/// @brief Plugs connection into socket.
/// @param socket target socket
/// @param connection connection to plug
void socket_plug_gate(socket_t socket, connection_t connection);

/// @brief Gets status of socket.
/// @param socket target socket
/// @return status of socket or UNDEFINED if socket is NULL
socket_status socket_get_status(socket_t socket);

/// @brief Tries to get signal from socket.
/// @param socket target socket
/// @return signal or NULL if socket is not connected to any bool signal
bool const* socket_try_get_signal(socket_t socket);

/// @brief Tries to get connection from socket.
/// @param socket target socket
/// @return connection or NULL if socket is not connected to any NAND gate
connection_t socket_try_get_connection(socket_t socket);

/// @brief Disconnects socket from any input should exist.
/// @param socket target socket
void socket_release(socket_t socket);

/// @brief Destroys socket (or nothing if null).
/// @param socket target socket
void socket_delete(socket_t socket);

#endif
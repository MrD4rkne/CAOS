#include <stdlib.h>

#include "socket.h"

union sgs
{
    bool const* signal;
    connection_t connection;
};

typedef union sgs signal_source;

struct sct
{
    signal_source source;
    socket_status type;
};

socket_t socket_new()
{
    socket_t newSocket = (socket_t)malloc(sizeof(struct sct));
    if (newSocket == NULL)
    {
        return NULL;
    }

    newSocket->source.signal = NULL;
    newSocket->type = DISCONNECTED;

    return newSocket;
}

void socket_plug_signal(socket_t socket, bool const* val)
{
    if (socket == NULL || val == NULL)
    {
        return;
    }

    socket->source.signal = val;
    socket->type = SIGNAL;
}

void socket_plug_gate(socket_t socket, connection_t connection)
{
    if (socket == NULL || connection == NULL)
    {
        return;
    }

    socket->source.connection = connection;
    socket->type = GATE;
}

socket_status socket_get_status(socket_t socket)
{
    if (socket == NULL)
    {
        return UNDEFINED;
    }

    return socket->type;
}

bool const* socket_try_get_signal(socket_t socket)
{
    if (socket == NULL || socket->type != SIGNAL)
    {
        return NULL;
    }

    return socket->source.signal;
}

connection_t socket_try_get_connection(socket_t socket)
{
    if (socket == NULL || socket->type != GATE)
    {
        return NULL;
    }

    return socket->source.connection;
}

void socket_release(socket_t socket)
{
    if (socket == NULL)
    {
        return;
    }

    socket->source.signal = NULL;
    socket->source.connection = NULL;
    socket->type = DISCONNECTED;
}

void socket_delete(socket_t socket)
{
    if (socket == NULL)
        return;

    free(socket);
}
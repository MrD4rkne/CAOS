#include <stdlib.h>

#include "connection.h"

typedef struct connection {
    nand_t* source;
    nand_t* target;
    ssize_t targetInputIndex;
} connection;

typedef struct connection* connection_t;

connection_t connection_new(nand_t* source, nand_t* target, ssize_t targetInputIndex) {
    connection_t newConnection = (connection_t)malloc(sizeof(struct connection));
    if (newConnection == NULL)
    {
        return NULL;
    }

    newConnection->source = source;
    newConnection->target = target;
    newConnection->targetInputIndex = targetInputIndex;

    return newConnection;
}

nand_t* connection_get_source(connection_t connection) {
    if (connection == NULL)
    {
        return NULL;
    }

    return connection->source;
}

nand_t* connection_get_target(connection_t connection) {
    if (connection == NULL)
    {
        return NULL;
    }

    return connection->target;
}

ssize_t connection_get_target_input_index(connection_t connection) {
    if (connection == NULL)
    {
        return -1;
    }

    return connection->targetInputIndex;
}

void connection_delete(connection_t connection) {
    if (connection == NULL)
    {
        return;
    }

    free(connection);
}
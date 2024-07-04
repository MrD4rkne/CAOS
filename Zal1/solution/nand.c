#define DISCONNECTED_SOCKET_PATH_LENGTH 0
#define DISCONNECTED_SOCKET_OUTPUT false
#define BOOL_SIGNAL_PATH_LENGTH 0
#define INVALID -1
#define NOT_CALCULATED -1
#define EMPTY_GATE_OUTPUT false
#define EMPTY_GATE_PATH_LENGTH 0

#include <errno.h>
#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>

#include "nand.h"
#include "socket.h"
#include "list.h"
#include "connection.h"

/// @brief NAND info about current calculations.
typedef struct nand_info* nand_info_t;

typedef enum evaluate_st {
    Success = 0,
    Enomem = 1,
    Loop = 2,
    Unpluged = 3
} evaluate_status;

struct nand_info
{
    ssize_t criticalPathLength;
    bool wasVisited;
    bool isOnStack;
    bool output;
};

/// @brief Calculates bool output and length of critical path for socket.
/// @param socket target socket
/// @param output pointer to output
/// @param critalPath pointer to critical path length
/// @param gatesInfo array of current calculations data
/// @param gatesCount number of all NAND gates
/// @return info about operation
static evaluate_status calculate_socket_info(socket_t socket, bool* output, ssize_t* critalPath);

/// @brief Calculates bool output and length of critical path for gate and it's inputs.
/// @param gatesInfo array of current calculations data
/// @param gatesCount number of all NAND gates
/// @param gate target gate
/// @return info about operation
static evaluate_status calculate_gate_info(nand_t* gate);

/// @brief Reset calculation info for gate and it's calculation predecestors.
/// @param gate target gate
static void clear_calculation_info(nand_t* gate);

/// @brief Destroy nand_t from memory.
/// @param gate target NAND gate
static void destroy_nand(nand_t* gate);

/// @brief Whether index is a valid socket no.
/// @param input target NAND gate
/// @param k index
/// @return whether index is valid
static bool is_valid_socket_no(nand_t const* input, unsigned k);

/// @brief Initializes inputs array of NAND gate.
/// @param gate inputs' owner
/// @param count size of array
/// @return true if successful, false otherwise
static bool init_inputs(nand_t* gate, size_t count);

/// @brief Releases all sockets of gates connected to given NAND gate.
/// @param gate target NAND gate
static void disconnect_gate_output(nand_t* gate);

/// @brief Connects two NAND gates.
/// @param source source NAND gate
/// @param gateIndex index of input socket of source gate
/// @param target target NAND gate
/// @return true if successful, false otherwise
static bool connect_gates(nand_t* source, size_t gateIndex, nand_t* target);

/// @brief Disconnects gate from socket.
/// @param gate target NAND gate
/// @param socketNo index of input socket
static void disconnect_gate_from_socket(nand_t* gate, size_t socketNo);

/// @brief Create info about gate for calculations.
/// @return Default info or NULL if allocation failed.
static nand_info_t info_new();

/// @brief Delete info object if not NULL.
static void info_delete(nand_info_t info);

struct nand
{
    socket_t* inputs;
    size_t inputsCount;
    // List of connection_t.
    list_t outputs;
    // Info for calculations.
    nand_info_t info;
};

nand_t* nand_new(unsigned n)
{
    nand_t* newGate = (nand_t*)malloc(sizeof(nand_t));
    if (newGate == NULL)
    {
        errno = ENOMEM;
        return NULL;
    }

    newGate->inputsCount = n;
    newGate->outputs = list_new();
    newGate->inputs = NULL;
    newGate->info = NULL;

    if (newGate->outputs == NULL || !init_inputs(newGate, n))
    {
        destroy_nand(newGate);
        errno = ENOMEM;
        return NULL;
    }

    return newGate;
}

void nand_delete(nand_t* g)
{
    if (g == NULL)
        return;

    for (size_t i = 0; i < g->inputsCount; i++)
    {
        if (socket_get_status(g->inputs[i]) == GATE) {
            disconnect_gate_from_socket(g, i);
        }
    }
    disconnect_gate_output(g);
    destroy_nand(g);
}

int nand_connect_nand(nand_t* g_out, nand_t* g_in, unsigned k)
{
    if (g_in == NULL || g_out == NULL || !is_valid_socket_no(g_in, k))
    {
        errno = EINVAL;
        return -1;
    }

    if (socket_get_status(g_in->inputs[k]) == GATE)
    {
        disconnect_gate_from_socket(g_in, k);
    }

    if (!connect_gates(g_out, k, g_in))
    {
        errno = ENOMEM;
        return -1;
    }

    return 0;
}

int nand_connect_signal(bool const* s, nand_t* g, unsigned k)
{
    if (g == NULL || s == NULL || !is_valid_socket_no(g, k))
    {
        errno = EINVAL;
        return -1;
    }

    if (socket_get_status(g->inputs[k]) == GATE)
    {
        disconnect_gate_from_socket(g, k);
    }

    socket_plug_signal(g->inputs[k], s);
    return 0;
}

ssize_t nand_evaluate(nand_t** g, bool* s, size_t m)
{
    if (g == NULL || s == NULL || m == 0)
    {
        errno = EINVAL;
        return -1;
    }

    // Validate NAND pointers.
    for (size_t i = 0; i < m; i++)
    {
        if (g[i] == NULL) {
            errno = EINVAL;
            return -1;
        }
    }

    evaluate_status evaluateStatus = Success;

    for (size_t i = 0; i < m; i++) {
        evaluateStatus = calculate_gate_info(g[i]);
        if (evaluateStatus != Success)
            break;
    }

    ssize_t longestCrititalPath = 0;
    if (evaluateStatus == Success) {
        for (size_t i = 0; i < m; i++)
        {
            if (g[i]->info->criticalPathLength > longestCrititalPath)
            {
                longestCrititalPath = g[i]->info->criticalPathLength;
            }
            s[i] = g[i]->info->output;
        }
    }

    // Reset calculations info.
    for (size_t i = 0; i < m; i++) {
        clear_calculation_info(g[i]);
    }

    switch (evaluateStatus) {
        default:
        case Success:
            return longestCrititalPath;
        case Enomem:
            errno = ENOMEM;
            return -1;
        case Loop:
        case Unpluged:
            errno = ECANCELED;
            return -1;
    }
}

ssize_t nand_fan_out(nand_t const* g)
{
    if (g == NULL)
    {
        errno = EINVAL;
        return -1;
    }

    return list_get_size(g->outputs);
}

void* nand_input(nand_t const* g, unsigned k)
{
    if (g == NULL || !is_valid_socket_no(g, k))
    {
        errno = EINVAL;
        return NULL;
    }

    switch (socket_get_status(g->inputs[k]))
    {
        case SIGNAL:
            return (void*)socket_try_get_signal(g->inputs[k]);
        case GATE:
            return (void*)connection_get_source(socket_try_get_connection(g->inputs[k]));
        case DISCONNECTED:
            errno = 0;
            return NULL;
        default:
            errno = ENOSYS;
            return NULL;
    }
}

nand_t* nand_output(nand_t const* g, ssize_t k)
{
    if (g == NULL || k < 0 || (size_t)k >= list_get_size(g->outputs))
    {
        errno = EINVAL;
        return NULL;
    }

    connection_t connection = list_get_elem_at(g->outputs, (size_t)k);
    return connection_get_target(connection);
}

static bool is_valid_socket_no(nand_t const* input, unsigned k)
{
    return k < input->inputsCount;
}

static bool init_inputs(nand_t* gate, size_t count)
{
    if (count == 0) {
        gate->inputs = NULL;
        return true;
    }

    gate->inputs = (socket_t*)calloc(count, sizeof(socket_t));
    if (gate->inputs == NULL)
    {
        return false;
    }

    for (size_t i = 0; i < count; i++)
    {
        gate->inputs[i] = socket_new();

        if (gate->inputs[i] == NULL)
        {
            // Clear allocated data.
            for (size_t j = 0; j < i; j++)
            {
                socket_delete(gate->inputs[j]);
                gate->inputs[j] = NULL;
            }
            free(gate->inputs);
            gate->inputs = NULL;
            return false;
        }
    }

    return true;
}

static void disconnect_gate_output(nand_t* gate)
{
    list_t connectedOutputs = gate->outputs;
    for (size_t i = 0; i < list_get_size(connectedOutputs); i++)
    {
        connection_t currentConnection = (connection_t)list_get_elem_at(connectedOutputs, i);
        nand_t* targetGate = connection_get_target(currentConnection);
        size_t targetGateIndex = connection_get_target_input_index(currentConnection);

        socket_release(targetGate->inputs[targetGateIndex]);
        connection_delete(currentConnection);
        currentConnection = NULL;
    }
}

static bool connect_gates(nand_t* source, size_t gateIndex, nand_t* target)
{
    connection_t newConnection = connection_new(source, target, gateIndex);
    if (newConnection == NULL)
    {
        errno = ENOMEM;
        return false;
    }

    socket_plug_gate(target->inputs[gateIndex], newConnection);
    if (!list_push_back(source->outputs, newConnection))
    {
        disconnect_gate_from_socket(source, gateIndex);
        connection_delete(newConnection);
        newConnection = NULL;

        errno = ENOMEM;
        return false;
    }
    return true;
}

static void disconnect_gate_from_socket(nand_t* gate, size_t socketNo)
{
    socket_t currInput = gate->inputs[socketNo];
    connection_t currConnection = socket_try_get_connection(currInput);
    nand_t* sourceGate = connection_get_source(currConnection);
    // Remove from source's outputs.
    list_remove_occurences(sourceGate->outputs, currConnection);
    // Remove from destination's inputs.
    socket_release(gate->inputs[socketNo]);
    connection_delete(currConnection);
}

static void destroy_nand(nand_t* gate)
{
    if (gate == NULL)
        return;

    if (gate->inputs != NULL)
    {
        for (size_t i = 0; i < gate->inputsCount; i++) {
            if (gate->inputs[i] != NULL) {
                socket_delete(gate->inputs[i]);
                gate->inputs[i] = NULL;
            }
        }
        free(gate->inputs);
        gate->inputs = NULL;
    }

    list_delete(gate->outputs);
    gate->outputs = NULL;

    free(gate);
}

static evaluate_status calculate_gate_info(nand_t* gate)
{
    if (gate->info == NULL) {
        gate->info = info_new();
        if (gate->info == NULL) {
            return Enomem;
        }
    }
    if (gate->info->isOnStack)
    {
        return Loop;
    }
    if (gate->info->wasVisited)
    {
        // Already visited, no point in further calculations.
        return Success;
    }

    gate->info->wasVisited = true;
    gate->info->isOnStack = true;

    if (gate->inputs == 0) {
        gate->info->criticalPathLength = EMPTY_GATE_PATH_LENGTH;
        gate->info->output = EMPTY_GATE_OUTPUT;
        gate->info->isOnStack = false;
        return Success;
    }

    ssize_t longestSubPath = 0;
    bool gateOutput = false;
    for (size_t i = 0; i < gate->inputsCount; i++)
    {
        ssize_t subPathLength = INVALID;
        bool subOutput;
        evaluate_status operationStatus = calculate_socket_info(gate->inputs[i], &subOutput, &subPathLength);
        if (operationStatus != Success)
        {
            // Some operation failed.
            return operationStatus;
        }

        gateOutput |= !subOutput;
        if (subPathLength > longestSubPath)
        {
            longestSubPath = subPathLength;
        }
    }

    // Update results of calculations.
    gate->info->criticalPathLength = longestSubPath + 1;
    gate->info->output = gateOutput;
    gate->info->isOnStack = false;
    return Success;
}

static evaluate_status calculate_socket_info(socket_t socket, bool* output, ssize_t* critalPath)
{
    switch (socket_get_status(socket))
    {
        case DISCONNECTED:
            return Unpluged;
        case SIGNAL:
            *critalPath = BOOL_SIGNAL_PATH_LENGTH;
            *output = *socket_try_get_signal(socket);
            return Success;
        case GATE:
            connection_t connection = socket_try_get_connection(socket);
            nand_t* subGate = connection_get_source(connection);
            evaluate_status status = calculate_gate_info(subGate);
            if (status != Success)
            {
                return status;
            }

            *critalPath = subGate->info->criticalPathLength;
            *output = subGate->info->output;
            return Success;
        default:
            // Should not happen.
            return Enomem;
    }
}

static void clear_calculation_info(nand_t* gate) {
    if (gate->info == NULL)
        return;

    info_delete(gate->info);
    gate->info = NULL;

    for (size_t i = 0; i < gate->inputsCount; i++) {
        if (socket_get_status(gate->inputs[i]) == GATE) {
            nand_t* source = connection_get_source(socket_try_get_connection(gate->inputs[i]));
            clear_calculation_info(source);
        }
    }
}

static nand_info_t info_new() {
    nand_info_t info = (nand_info_t)malloc(sizeof(struct nand_info));
    if (info == NULL)
        return NULL;
    info->criticalPathLength = NOT_CALCULATED;
    info->isOnStack = false;
    info->wasVisited = false;
    info->output = false;
    return info;
}

static void info_delete(nand_info_t info) {
    if (info == NULL)
        return;
    free(info);
}
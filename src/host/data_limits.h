#ifndef KNOT_DATA_LIMITS_H
#define KNOT_DATA_LIMITS_H

#include <stddef.h>

size_t knot_limit_depth(void);
size_t knot_limit_nodes(void);
void knot_limit_set(size_t depth, size_t nodes);

#endif

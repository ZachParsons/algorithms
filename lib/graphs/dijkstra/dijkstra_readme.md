# Dijkstra's Algorithm Implementations

This directory contains two different implementations of Dijkstra's algorithm,
each optimized for different use cases. Both implementations provide specialized
approaches to shortest path finding.

## Available Implementations

### 1. Tree Implementation (`Algorithms.Graphs.Dijkstra.Tree`)
Classic Dijkstra's algorithm that builds a complete shortest path tree from source to all nodes.
Accessed via `shortest_path_tree/2` and `shortest_path/3`.

### 2. Search Implementation (`Algorithms.Graphs.Dijkstra.Search`)
Path-based approach with early termination, optimized for single source-target queries.
Accessed via `shortest_path_search/3`.

## Algorithm Design Differences

| Aspect             | Tree                                      | Search                              |
|--------------------|-------------------------------------------|-------------------------------------|
| **Algorithm Type** | Classic Dijkstra (tree-building)          | Modified Dijkstra (targeted search) |
| **Scope**          | Source → **ALL nodes**                    | Source → **SPECIFIC target**        |
| **Termination**    | When all nodes processed                  | When **target found**               |
| **Data Structure** | Distance map + previous pointers          | Complete paths in priority queue    |
| **Use Case**       | Multiple target queries                   | Single target queries               |
| **Memory Usage**   | O(V)                                      | O(V × P) where P = path length      |
| **Performance**    | Always explores all reachable             | **Early termination** advantage     |
| **Graph Format**   | `WeightedGraph` struct with adjacency list| Map with `{cost, neighbor}` tuples  |
| **Return Value**   | `{:ok, {distance, path}}` or distance map | `{total_cost, complete_path}`       |

## When to Use Which Implementation

**Use Tree (`shortest_path_tree/2`, `shortest_path/3`) when:**
- You need distances to multiple targets from the same source
- You're working with the structured `WeightedGraph` format
- You want the classic academic Dijkstra implementation
- Memory efficiency is important (O(V) vs O(V×P))
- Production systems (standard, well-tested approach)
- Educational purposes (matches academic literature)

**Use Search (`shortest_path_search/3`) when:**
- You need a path to a single specific target
- You want early termination for better performance
- You're working with simple map-based graphs
- You need the complete path immediately without reconstruction
- Coding interviews (easier to implement under pressure)
- Quick prototyping (faster to implement)

## Recommendation Matrix

| Use Case                        | Recommended Implementation | Reason                            |
|---------------------------------|----------------------------|-----------------------------------|
| Single path, sparse graph       | `shortest_path_search/3`   | Early termination advantage       |
| Multiple paths, same source     | `shortest_path_tree/2`     | Amortized cost benefits           |
| Memory-constrained environment  | `shortest_path_tree/2`     | O(V) vs O(V×P) memory             |
| Dense graphs                    | `shortest_path_tree/2`     | Avoids path explosion             |
| Production systems              | `shortest_path_tree/2`     | Standard, well-tested approach    |
| Coding interviews               | `shortest_path_search/3`   | Easier to implement under pressure|
| Educational purposes            | `shortest_path_tree/2`     | Matches academic literature       |
| Quick prototyping               | `shortest_path_search/3`   | Faster to implement               |
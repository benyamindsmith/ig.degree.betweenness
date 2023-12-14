## THE ALGORITHM

This algorithm detects communities by calculating the closeness centrality measures of nodes and assigns communities based on the subsequent subgraphs.

The algorithm first calculates closeness centrality for all nodes in the graph and then starts from the node with the largest closeness centrality extracts the sub-graph set it as its "cluster". The remaining nodes are assigned to a separate cluster. This is preformed iteratively until all possible communities are identified.

In the case of an overlap of nodes, the node with higher closeness centrality gets it. As a result, there are is no overlap in nodes between clusters. For choice of number of communities, the number which maximizes modularity is chosen.

## LIMITATIONS

This algorithm:

1. Works only with undirected networks.
2. Works only with named nodes.
4. If edge_density is greater than or equal to 1 then these algorithms will not work. 
3. Datasets like `igraphdata`'s "karate" and "yeast" datasets work
## THE ALGORITHM

This algorithm detects communities by calculating the closeness centrality measures of nodes and assigns communities based on the subsequent subgraphs.

The algorithm first calculates closeness centrality for all nodes in the graph and then starts from the node with the largest closeness centrality extracts the sub-graph set it as its "cluster". The remaining nodes are assigned to a separate cluster. This is preformed iteratively until all possible communities are identified.

In the case of an overlap of nodes, the node with higher closeness centrality gets it. As a result, there are is no overlap in nodes between clusters. For choice of number of communities, the number which maximizes modularity is chosen.

## LIMITATIONS

This algorithm:

1. Works only with undirected networks.
2. Works only with named nodes (fixed now with `prep_unlabeled_data`)
3. Works best with Bipartite Graphs
4. If edge_density is greater than or equal to 1 then these algorithms will not work. 
5. Datasets like `igraphdata`'s "karate" and "yeast" datasets work
6. Works best with networks with 30-50 nodes with high connectivity

## TODO

- Proposed Method Maximizes Modularity. Consider CPM like how louvain and Lieden do. 
- Consider looking at using glms to inform network complexity

## Datasets this preforms better than Girvan Newman

- karate
- UKFaculty


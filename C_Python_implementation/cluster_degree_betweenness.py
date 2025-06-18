#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Updated on Sun Mar 9 20:07 2025

"""

import sys, re, igraph as ig

# Read-in data from command prompt
filename = sys.argv[1]
#filename = '/Users/tylerpittman/Documents/cluster_degree_betweenness/SNA_pres_edgelist.txt'
#filename = '/Users/tylerpittman/Documents/cluster_degree_betweenness/edgelistF.txt'

# Read the file and create a list of edges 
with open(filename, "r") as f:
    edges = [tuple(line.strip().split("\t")) for line in f]

# Create directed graph from tuple list
g = ig.Graph.TupleList(edges, directed=True) 
g.vs['degree'] = g.degree()
#ig.summary(g)
#print(g.get_adjacency())

############################################################
# Algorithm function, don't forget to comment out print() statements
def cluster_degree_betweenness(graph):
    
    # Copy full graph, intialize counters and lists
    graph_ = graph.copy()  
    #graph_ = g
    n_edges = len(graph_.es) 
    n_nodes = len(graph_.vs) 
    cmpnts = []  
    modularities = []
    
    for i in range(n_edges):
        try:
            # Sort the nodes by degree in descending order
            #print(graph_.degree()) 
            degree_nodes = sorted(graph_.vs['name'], key=lambda x: graph_.degree(x), reverse=True)
            
            # Calculate edge betweenness
            edgelist = [(graph_.vs[edge.source]['name'], graph_.vs[edge.target]['name']) for edge in graph_.es]
            graph_.es['name'] = edgelist
            #len(edgelist)
            edge_btwn = dict(zip(edgelist, graph_.edge_betweenness())) #Python dictionary can't have duplicate keys
            #len(edge_btwn)
            #print(edge_btwn)
            
            # Create subgraph of edges associated with the highest-degree node
            node = degree_nodes[0]
            edges_to_keep = [index for index, item in enumerate(edgelist) if str(node) in item]
            subgraph = graph_.subgraph_edges(edges_to_keep, delete_vertices=True)
            #ig.summary(subgraph)
            #print(subgraph)
            
            # If subgraph has no edges, store the components and continue
            if len(subgraph.es) == 0:  
                cmpnts.append(graph_.components(mode='weak'))
                continue
            
            # Calculate edge betweenness for the subgraph and find the edge with the highest betweenness
            subgraph_edgelist = [(subgraph.vs[edge.source]['name'], subgraph.vs[edge.target]['name']) for edge in subgraph.es]
            #print(subgraph_edgelist) #uncomment this to see betweenness of subgraph edges
            #len(subgraph_edgelist)
            subgraph_edge_betweeness = sorted([edge for edge in subgraph_edgelist if edge in edge_btwn], 
                                              key=lambda x: edge_btwn[x], reverse=True)
            
            # Remove the edge with the highest betweenness
            #print(subgraph_edge_betweeness[0]) 
            edge_to_delete = graph_.es.find(name_eq=subgraph_edge_betweeness[0])  
            graph_.delete_edges(edge_to_delete)

            # Find membership components for subgraph
            cmpnt = graph_.components(mode='weak')
            cmpnts.append(cmpnt)
            #graph_.components().__dict__
            
            # Calculate modularity for full graph using membership components for subgraph
            modal = graph.modularity(cmpnt.membership)
            modularities.append(modal)
            print("Iteration ", i+1, ": modularity ", modal)
            #print(i+1)
        except :
            break
    
    graph_ = graph
    
    # Get communities from each iteration
    communities = [cmp.membership for cmp in cmpnts]      
    
    # Find the iteration with the highest modularity
    iter_num = modularities.index(max(modularities))
    
    # Print out summary information (can comment out)
    print("Number of nodes: ", n_nodes)
    print("Number of edges: ", n_edges)
    print("Iteration with highest modularity: ", iter_num+1)
    print("Modularity for full graph with detected communities: ", max(modularities))
    print("Number of communities: ", len(set(communities[iter_num])))
    print("Assigned community for each node:\n", communities[iter_num])
    print("Nodes:\n", graph.vs['name'])
    
    # Get bridge edges
    bridges = graph.bridges()

    # Convert edge indices in bridges to node names
    bridge_nodes = [(graph.vs[edge_tuple[0]]["name"], graph.vs[edge_tuple[1]]["name"]) 
                    for edge_tuple in [graph.es[i].tuple for i in bridges]]

    
    # Prepare the result
    res = {
        "names": graph.vs['name'],
        "vcount": graph.vcount(),
        "algorithm": "node degree+edge betweenness",
        "modularity": modularities,
        "membership": communities[iter_num],
        "bridges":  bridge_nodes
    }
    
    return res
############################################################


# Apply algorithm
g_sp = cluster_degree_betweenness(g)

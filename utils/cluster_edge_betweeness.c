#include <igraph/igraph.h>
#include <stdio.h>
#include <stdlib.h>

// Custom function to find the index of the maximum value in an igraph_vector_t
long int vector_max_index(const igraph_vector_t *v) {
    long int i, max_index = 0;
    igraph_real_t max_value = VECTOR(*v)[0];  // Start with the first element

    for (i = 1; i < igraph_vector_size(v); i++) {
        if (VECTOR(*v)[i] > max_value) {
            max_value = VECTOR(*v)[i];
            max_index = i;
        }
    }
    return max_index;
}

void cluster_degree_betweenness(igraph_t* graph) {
    igraph_vector_t modularities;
    igraph_vector_int_t degrees, membership, best_membership, csize, best_csize;
    igraph_vector_t edge_betweenness;
    igraph_real_t modularity;
    igraph_real_t resolution = 1.0; // Modularity resolution parameter
    igraph_integer_t no_of_clusters;

    // Variables to track the highest modularity and the corresponding iteration
    igraph_real_t highest_modularity = -1.0;
    long int best_iteration = 0;

    // Initialize vectors
    igraph_vector_init(&modularities, 0);
    igraph_vector_init(&edge_betweenness, 0);
    igraph_vector_int_init(&degrees, igraph_vcount(graph));
    igraph_vector_int_init(&membership, 0); // For storing membership
    igraph_vector_int_init(&best_membership, 0); // To store the best membership
    igraph_vector_int_init(&csize, 0); // For storing component sizes
    igraph_vector_int_init(&best_csize, 0); // To store the best component sizes

    // Calculate initial degrees
    igraph_degree(graph, &degrees, igraph_vss_all(), IGRAPH_ALL, IGRAPH_NO_LOOPS);

    long int n_edges = igraph_ecount(graph);

    for (long int i = 0; i < n_edges - 1; i++) {
        // Calculate edge betweenness
        igraph_edge_betweenness(graph, &edge_betweenness, IGRAPH_DIRECTED, NULL);

        // Find the index of the edge with the highest betweenness
        long int max_betweenness = vector_max_index(&edge_betweenness);

        // Delete the edge with the highest betweenness
        igraph_es_t es;
        igraph_es_1(&es, max_betweenness);  // Select the edge with the highest betweenness
        igraph_delete_edges(graph, es);  // Delete the selected edge
        igraph_es_destroy(&es);

        // Update degree for vertices
        igraph_degree(graph, &degrees, igraph_vss_all(), IGRAPH_ALL, IGRAPH_NO_LOOPS);

        // Store the components using igraph_clusters
        igraph_clusters(graph, &membership, &csize, &no_of_clusters, IGRAPH_WEAK);

        // Calculate modularity
        igraph_modularity(graph, &membership, NULL, resolution, IGRAPH_DIRECTED, &modularity);

        // Store the modularity for this iteration
        igraph_vector_push_back(&modularities, modularity);

        // Check if this is the highest modularity so far
        if (modularity > highest_modularity) {
            highest_modularity = modularity;
            best_iteration = i;

            // Store the best membership and component sizes
            igraph_vector_int_update(&best_membership, &membership);
            igraph_vector_int_update(&best_csize, &csize);
        }

        // Optionally: print modularity for this iteration
        printf("Iteration %ld: Modularity = %lf, Components = %d\n", i, modularity, (int)no_of_clusters);
    }

    // Print the iteration with the highest modularity
    printf("Best iteration: %ld with highest modularity: %lf\n", best_iteration, highest_modularity);

    // Print components (clusters) for the best iteration
    /*
    printf("Components in the best iteration:\n");
    for (long int i = 0; i < igraph_vector_int_size(&best_csize); i++) {
        printf("Component %ld size: %d\n", i, VECTOR(best_csize)[i]);
    }
    */;

    printf("Membership of vertices in the best iteration:\n");
    for (long int i = 0; i < igraph_vector_int_size(&best_membership); i++) {
        printf("Vertex %ld is in component %d\n", i, VECTOR(best_membership)[i]);
    }

    // Clean up
    igraph_vector_destroy(&modularities);
    igraph_vector_int_destroy(&membership);
    igraph_vector_int_destroy(&best_membership);
    igraph_vector_int_destroy(&degrees);
    igraph_vector_int_destroy(&csize);
    igraph_vector_int_destroy(&best_csize);
    igraph_vector_destroy(&edge_betweenness);
}
//
// int main() {
//     igraph_t g;
//
//     // Load the graph from an edge list file
//     FILE *file = fopen("twitter_congress_edgelist.txt", "r");
//     igraph_read_graph_edgelist(&g, file, 0, 1);
//     fclose(file);
//
//     // Apply the clustering algorithm
//     cluster_degree_betweenness(&g);
//
//     // Cleanup
//     igraph_destroy(&g);
//     return 0;
// }

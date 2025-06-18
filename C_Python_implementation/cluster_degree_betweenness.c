#include <igraph/igraph.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_LINE 3000  // Maximum length of a line in the edgelist
#define MAX_NAME 1000  // Maximum length of a node name
#define BUFFER_SIZE 1000000  // Adjust based on expected length of all printed node names comma separated

// Structure to hold clustering results
typedef struct {
  const char *names;
  igraph_integer_t vcount;
  const char *algorithm;
  igraph_vector_t *modularity;
  igraph_vector_int_t *membership;
  const char *bridges;
} Result;

// Structure to map string names to integer indices
typedef struct {
  char **names;    // Array of string names
  int *indices;    // Corresponding integer indices
  int size;        // Number of unique nodes
  int capacity;    // Allocated size of arrays
} NameIndexMap;

// Initialize the NameIndexMap
void init_name_index_map(NameIndexMap *map, int initial_capacity) {
  map->names = malloc(initial_capacity * sizeof(char *));
  map->indices = malloc(initial_capacity * sizeof(int));
  map->size = 0;
  map->capacity = initial_capacity;
}

// Free the NameIndexMap
void free_name_index_map(NameIndexMap *map) {
  for (int i = 0; i < map->size; i++) {
    free(map->names[i]);
  }
  free(map->names);
  free(map->indices);
}

// Get or add a node's index based on its string name
int get_or_add_city_index(NameIndexMap *map, const char *city) {
  for (int i = 0; i < map->size; i++) {
    if (strcmp(map->names[i], city) == 0) {
      return map->indices[i];
    }
  }
  if (map->size >= map->capacity) {
    map->capacity *= 2;
    map->names = realloc(map->names, map->capacity * sizeof(char *));
    map->indices = realloc(map->indices, map->capacity * sizeof(int));
  }
  map->names[map->size] = strdup(city);
  map->indices[map->size] = map->size; // Index is the position in the array
  return map->size++;
}

// Read edgelist and populate both graph and name map
void read_edgelist(const char *filename, igraph_t *graph, NameIndexMap *city_map) {
  FILE *file = fopen(filename, "r");
  if (!file) {
    perror("Error opening file");
    exit(EXIT_FAILURE);
  }

  igraph_vector_int_t edges;
  igraph_vector_int_init(&edges, 0);
  init_name_index_map(city_map, 1000000000); // Initial capacity for a billion nodes

  char line[MAX_LINE];
  while (fgets(line, sizeof(line), file)) {
    // Find the tab delimiter
    char *tab_pos = strchr(line, '\t');
    if (tab_pos == NULL) continue; // Skip lines without a tab

    /*// Extract source node name (before the tab)
     size_t source_len = tab_pos - line;
     char source[source_len + 3];
     sprintf(source, "'%.*s'", (int)source_len, line);

     // Extract target node name (after the tab)
     char *target_start = tab_pos + 1;
     char *newline_pos = strchr(target_start, '\n');
     size_t target_len = newline_pos ? (newline_pos - target_start) : strlen(target_start);
     char target[target_len + 3];
     sprintf(target, "'%.*s'", (int)target_len, target_start);*/

    // Extract source node name (before the tab)
    size_t source_len = tab_pos - line;
    char source[source_len + 1];
    strncpy(source, line, source_len);
    source[source_len] = '\0';

    // Extract target node name (after the tab)
    char *target_start = tab_pos + 1;
    char *newline_pos = strchr(target_start, '\n');
    size_t target_len = newline_pos ? (newline_pos - target_start) : strlen(target_start);
    char target[target_len + 1];
    strncpy(target, target_start, target_len);
    target[target_len] = '\0';

    // Get or assign indices for source and target
    int src_index = get_or_add_city_index(city_map, source);
    int tgt_index = get_or_add_city_index(city_map, target);
    igraph_vector_int_push_back(&edges, src_index);
    igraph_vector_int_push_back(&edges, tgt_index);
  }
  fclose(file);

  // Create graph with the number of unique nodes
  igraph_empty(graph, city_map->size, IGRAPH_DIRECTED);
  igraph_add_edges(graph, &edges, 0);


  igraph_vector_int_destroy(&edges);
  // Note: city_map is not freed here; it's needed later
}

void store_city_names(int n_nodes, NameIndexMap *city_map, char *node_names, size_t buffer_size) {
  size_t pos = 0;  // Track position in node_names buffer

  for (int i = 0; i < n_nodes; i++) {
    const char *name = NULL;

    for (int j = 0; j < city_map->size; j++) {
      if (city_map->indices[j] == i) {
        name = city_map->names[j];

        // Append name to node_names buffer
        int written = snprintf(node_names + pos, buffer_size - pos, "%s%s",
                               name, (i < n_nodes - 1) ? ", " : "");

        if (written < 0 || (size_t)written >= buffer_size - pos) {
          fprintf(stderr, "Buffer overflow risk! Increase BUFFER_SIZE.\n");
          return;
        }

        pos += written;
        break;
      }
    }
  }
}

void assign_node_names(igraph_t *graph, NameIndexMap *city_map, int n_nodes) {
  for (int i = 0; i < n_nodes; i++) {
    const char *nname = NULL;

    // Find the name corresponding to node i
    for (int j = 0; j < city_map->size; j++) {
      if (city_map->indices[j] == i) {
        nname = city_map->names[j];
        break;
      }
    }

    if (nname) {
      igraph_cattribute_VAS_set(graph, "name", i, nname);
    }
  }
}

void assign_edge_names(igraph_t *graph) {
  igraph_integer_t ecount = igraph_ecount(graph); // Get number of edges
  for (int i = 0; i < ecount; i++) {
    igraph_integer_t from, to;
    igraph_edge(graph, i, &from, &to); // Get source and target nodes

    const char *from_name = igraph_cattribute_VAS(graph, "name", from);
    const char *to_name = igraph_cattribute_VAS(graph, "name", to);

    if (from_name && to_name) {
      char edge_name[MAX_LINE + 3]; // Buffer for edge name, should be same as line size
      snprintf(edge_name, sizeof(edge_name), "%s | %s", from_name, to_name);
      igraph_cattribute_EAS_set(graph, "name", i, edge_name);
    }
  }
}

void delete_edge_by_name(igraph_t *graph, const char *edge_name) {
  igraph_integer_t eid;
  igraph_es_t es;

  // Iterate over edges to find the correct one
  for (eid = 0; eid < igraph_ecount(graph); eid++) {
    const char *name = igraph_cattribute_EAS(graph, "name", eid);
    if (name != NULL && strcmp(name, edge_name) == 0) {
      // Found the edge, delete it
      igraph_delete_edges(graph, igraph_ess_1(eid));
      //printf("Pruned edge: %s\n", edge_name);
      return; // Exit after deletion
    }
  }

  printf("Edge not found: %s\n", edge_name);
}

void bridges_to_string(const igraph_vector_int_t *bridges, char *bridge_list, size_t buffer_size) {
  size_t len = igraph_vector_int_size(bridges);
  size_t pos = 0;

  for (size_t i = 0; i < len; i++) {
    int edge_index = VECTOR(*bridges)[i];

    // Append edge index to bridge_list buffer
    int written = snprintf(bridge_list + pos, buffer_size - pos, "%d%s",
                           edge_index + 1, (i < len - 1) ? ", " : "");

    if (written < 0 || (size_t)written >= buffer_size - pos) {
      fprintf(stderr, "Buffer overflow risk! Increase BUFFER_SIZE.\n");
      return;
    }

    pos += written;
  }
}

int find_max_degree_node(const igraph_vector_int_t *degrees) {
  int max_degree = -1;
  int max_node = -1;
  int size = igraph_vector_int_size(degrees);

  for (int i = 0; i < size; i++) {
    int degree = VECTOR(*degrees)[i];
    if (degree > max_degree) {
      max_degree = degree;
      max_node = i;  // Store the node with the maximum degree
    }
  }

  return max_node;
}

void print_vector_int(const igraph_vector_int_t *vec, const char *label) {
  printf("%s: ", label);
  for (int i = 0; i < igraph_vector_int_size(vec); i++) {
    printf("%ld ", (long) VECTOR(*vec)[i]); // Print each element
  }
  printf("\n");
}

void remove_duplicates(igraph_vector_int_t *vec) {
  if (igraph_vector_int_size(vec) == 0) return;

  igraph_vector_int_t temp;
  igraph_vector_int_init(&temp, 0);

  igraph_integer_t prev = VECTOR(*vec)[0];
  igraph_vector_int_push_back(&temp, prev);

  for (long i = 1; i < igraph_vector_int_size(vec); i++) {
    igraph_integer_t current = VECTOR(*vec)[i];
    if (current != prev) {  // Only add if it's not a duplicate
      igraph_vector_int_push_back(&temp, current);
    }
    prev = current;
  }

  // Copy back to original vector
  igraph_vector_int_update(vec, &temp);
  igraph_vector_int_destroy(&temp);
}

// node degree+edge betweenness community detection function, accesses original node names
void cluster_degree_betweenness(igraph_t *graph, NameIndexMap *city_map, Result *res) {
  igraph_t graph_, subgraph_, subgraph1_;
  igraph_vector_ptr_t cmpnts;
  igraph_vector_t *modularities = malloc(sizeof(igraph_vector_t));
  igraph_integer_t n_edges, n_nodes, i;

  n_edges = igraph_ecount(graph);
  n_nodes = igraph_vcount(graph);

  //printf("Graph has %d vertices and %d edges.\n", (int)igraph_vcount(graph), (int)igraph_ecount(graph));

  // Assign edge order as an edge attribute
  for (int i = 0; i < n_edges; i++) {
    igraph_cattribute_EAN_set(graph, "order", i, (double)i);
  }
  // Print assigned edge orders
  /*printf("Edge Orders:\n");
   for (int i = 0; i < n_edges; i++) {
   double order_value = igraph_cattribute_EAN(graph, "order", i);
   printf("Edge %ld: order = %.0f\n", (long)i, order_value);
   }*/

  // Assign node names from city_map
  assign_node_names(graph, city_map, n_nodes);

  // Verify: Print node names from the graph
  /*printf("Sociogram node names:\n");
   for (int i = 0; i < n_nodes; i++) {
   const char *name = igraph_cattribute_VAS(graph, "name", i);
   printf("Sociogram node %d: %s\n", i, name);
   }*/

  // Assign edge names in "from | to" format
  assign_edge_names(graph);

  // Print edges with names
  /*printf("Sociogram edges:\n");
   for (int i = 0; i < n_edges; i++) {
   const char *ename = igraph_cattribute_EAS(graph, "name", i);
   printf("Sociogram edge %d: %s\n", i, ename);
   }*/

  // Copy graph to &graph_
  igraph_vector_ptr_init(&cmpnts, 0);
  igraph_vector_init(modularities, 0);
  if (igraph_copy(&graph_, graph) != IGRAPH_SUCCESS) {
    fprintf(stderr, "Failed to copy graph\n");
    exit(1);
  }

  for (i = 0; i < n_edges; i++) {
    igraph_vector_int_t degrees, degreesI, order, edge_ids, sedge_ids, vertex_ids;
    igraph_vector_int_init(&degrees, n_nodes);
    igraph_real_t max_btwn, btwn_value;
    igraph_integer_t max_btwn_edge;
    igraph_degree(&graph_, &degrees, igraph_vss_all(), IGRAPH_ALL, IGRAPH_LOOPS);

    // Print iteration start, and node degrees
    //printf("Iteration %ld: subgraph node degrees\n", (long)(i + 1));
    //igraph_vector_int_print(&degrees);

    int max_node = find_max_degree_node(&degrees);
    int max_degree = VECTOR(degrees)[max_node];
    const char *mnode_name;
    mnode_name = igraph_cattribute_VAS(&graph_, "name", max_node);

    // Print what node what maximum degree
    //printf("Subgraph node with maximum degree: %s (Degree: %d)\n", mnode_name, max_degree);

    // &subgraph_, remove isolated vertices outside direct ties for node with highest degree centrality
    igraph_vector_int_init(&edge_ids, 0);
    igraph_incident(&graph_, &edge_ids, max_node, IGRAPH_ALL);

    // Sort edge IDs, need to make sure correct edge order for subgraph selector!
    igraph_vector_int_sort(&edge_ids);

    // Print the edge IDs
    //print_vector_int(&edge_ids, "Selector subgraph edge IDs");

    // Get nodes with these incident edges
    igraph_vector_int_init(&vertex_ids, 0);
    for (int i = 0; i < igraph_vector_int_size(&edge_ids); i++) {
      igraph_integer_t from, to;
      igraph_edge(&graph_, VECTOR(edge_ids)[i], &from, &to);
      igraph_vector_int_push_back(&vertex_ids, from);
      igraph_vector_int_push_back(&vertex_ids, to);
    }
    remove_duplicates(&vertex_ids);

    // Print the vertex IDs
    //print_vector_int(&vertex_ids, "Selector subgraph vertex IDs");

    // Calculate edge-betweeness in graph, need to set this as edge attribute
    igraph_vector_t edge_btwn;
    igraph_vector_init(&edge_btwn, igraph_ecount(&graph_));
    igraph_edge_betweenness(&graph_, &edge_btwn, IGRAPH_DIRECTED, NULL);

    // Assign betweenness as an edge attribute
    igraph_cattribute_EAN_setv(&graph_, "betweenness", &edge_btwn);


    // Assign which edges to keep based on &edge_ids
    igraph_es_t es;
    igraph_integer_t edge_count;

    // Create an edge selector from edge IDs
    igraph_es_vector(&es, &edge_ids);

    // Get total edge count
    edge_count = igraph_ecount(&graph_);

    // Initialize edge attribute "keep" with default "No"
    for (int q = 0; q < edge_count; q++) {
      igraph_cattribute_EAS_set(&graph_, "keep", q, "No");
    }

    // Set "Yes" for edges in edge_ids
    for (int w = 0; w < igraph_vector_size((igraph_vector_t*) &edge_ids); w++) {
      igraph_cattribute_EAS_set(&graph_, "keep", VECTOR(edge_ids)[w], "Yes");
    }

    // Print edge attributes
    /*printf("Edge Attributes:\n");
     for (int r = 0; r < edge_count; r++) {
     const char *keep_value = igraph_cattribute_EAS(&graph_, "keep", r);
     printf("Edge %ld: keep = %s\n", (long)r, keep_value);
     }*/


    // Print &graph_ edge betweenness values
    /*for (int y = 0; y < n_edges; y++) {
     printf("Edge %ld betweenness: %f\n", (long)y, VECTOR(edge_btwn)[y]);
    }*/


    // Create vertex-induced subgraph of the node with maximum degree
    igraph_induced_subgraph(&graph_, &subgraph_, igraph_vss_vector(&vertex_ids), IGRAPH_SUBGRAPH_AUTO);

    // have to use keep edge attribute to select only edges in &edge_ids
    // Initialize vector to store edges to remove
    igraph_vector_int_t edges_to_remove;
    igraph_vector_int_init(&edges_to_remove, 0);

    // Find edges to remove (where "keep" != "Yes")
    for (int i = 0; i < igraph_ecount(&subgraph_); i++) {
      const char *keep_value = igraph_cattribute_EAS(&subgraph_, "keep", i);
      if (strcmp(keep_value, "Yes") != 0) {
        igraph_vector_int_push_back(&edges_to_remove, i);
      }
    }

    // Delete edges not marked as "Yes"
    igraph_delete_edges(&subgraph_, igraph_ess_vector(&edges_to_remove));

    //printf("Selector subgraph has %d vertices and %d edges.\n", (int)igraph_vcount(&subgraph_), (int)igraph_ecount(&subgraph_));

    // Print edges with names
    /*printf("Selector subgraph edges:\n");
     for (int i = 0; i < igraph_ecount(&subgraph_); i++) {
     const char *ename = igraph_cattribute_EAS(&subgraph_, "name", i);
     printf("Selector subgraph edge %d: %s\n", i, ename);
     } */

    // Access edge_btwn as attribute from &graph_ in &subgraph_
    // Print &graph_ edge betweenness values from &subgraph_
    /*igraph_real_t sbtwn_value;
     for (igraph_integer_t k = 0; k < igraph_ecount(&subgraph_); k++) {
     sbtwn_value = igraph_cattribute_EAN(&subgraph_, "betweenness", k);
     printf("Edge %ld betweenness: %f\n", (long)k, sbtwn_value);
     }*/

    // This part has to select edge with maximum betweenness and the lowest "order" from its edge attribute
    max_btwn_edge = -1;
    max_btwn = -1.0;
    igraph_real_t min_order = 0.0;
    const char *edge_name = NULL;

    for (igraph_integer_t j = 0; j < igraph_ecount(&subgraph_); j++) {
      igraph_real_t btwn_value = igraph_cattribute_EAN(&subgraph_, "betweenness", j);
      igraph_real_t order_value = igraph_cattribute_EAN(&subgraph_, "order", j);

      if (btwn_value > max_btwn) {
        // Update if new maximum betweenness
        max_btwn = btwn_value;
        max_btwn_edge = j;
        min_order = order_value;
        edge_name = igraph_cattribute_EAS(&subgraph_, "name", j);
      } else if (btwn_value == max_btwn && order_value < min_order) {
        // If equal betweenness but lower order, then update edge selection
        max_btwn_edge = j;
        min_order = order_value;
        edge_name = igraph_cattribute_EAS(&subgraph_, "name", j);
      }
    }

    // Print the edge with the highest betweenness
    //printf("Edge %ld has the maximum betweenness: %f\n", (long)max_btwn_edge, max_btwn);

    //printf("Subgraph edge with maximum betweenness: %ld\n", (long)max_btwn_edge + 1);
    //printf("Subgraph edge with maximum betweenness: %s\n", edge_name);

    // Remove edge with highest edge betweenness in &subgraph_ from &graph_
    // Delete edge by name, using created void function since igraph C library does not have this function
    delete_edge_by_name(&graph_, edge_name);

    // Print edges with names from &graph_
    /*printf("Subgraph edges:\n");
     for (int i = 0; i < igraph_ecount(&graph_); i++) {
     const char *ename = igraph_cattribute_EAS(&graph_, "name", i);
     printf("Subgraph edge %d: %s\n", i, ename);
     }*/

    // Find components in &graph_
    igraph_vector_int_t *membership = malloc(sizeof(igraph_vector_int_t));
    igraph_vector_int_init(membership, n_nodes);
    igraph_connected_components(&graph_, membership, NULL, NULL, IGRAPH_WEAK);
    igraph_vector_ptr_push_back(&cmpnts, membership);

    igraph_real_t modularity;
    igraph_modularity(graph, membership, NULL, 1.0, IGRAPH_DIRECTED, &modularity);
    igraph_vector_push_back(modularities, modularity);

    printf("Iteration %ld: modularity %f\n", (long)(i + 1), modularity);

    igraph_vector_int_destroy(&degrees);
    igraph_vector_int_destroy(&order);
    igraph_vector_int_destroy(&edge_ids);
  }

  // Restore original graph
  igraph_destroy(&graph_);
  igraph_copy(&graph_, graph);

  // Find best iteration
  igraph_integer_t iter_num = 0;
  igraph_real_t max_modularity = VECTOR(*modularities)[0];
  for (i = 1; i < igraph_vector_size(modularities); i++) {
    if (VECTOR(*modularities)[i] > max_modularity) {
      max_modularity = VECTOR(*modularities)[i];
      iter_num = i;
    }
  }

  // Output statistics
  printf("Number of nodes: %d\n", (int)n_nodes);
  printf("Number of edges: %d\n", (int)n_edges);
  printf("Iteration with highest modularity: %ld\n", (long)(iter_num + 1));

  igraph_vector_int_t *best_membership = (igraph_vector_int_t *)VECTOR(cmpnts)[iter_num];
  //igraph_real_t full_modular;
  //igraph_modularity(graph, best_membership, NULL, 1.0, IGRAPH_DIRECTED, &full_modular);
  //printf("Modularity for full graph with detected communities: %.16f\n", full_modular);
  printf("Modularity for full graph with detected communities: %.16f\n", max_modularity);

  igraph_integer_t num_communities = 0;
  igraph_vector_int_t seen;
  igraph_vector_int_init(&seen, 0);
  for (i = 0; i < igraph_vector_int_size(best_membership); i++) {
    igraph_integer_t comm = VECTOR(*best_membership)[i];
    if (!igraph_vector_int_contains(&seen, comm)) {
      igraph_vector_int_push_back(&seen, comm);
      num_communities++;
    }
  }
  igraph_vector_int_destroy(&seen);
  printf("Number of communities: %ld\n", (long)num_communities);

  printf("Assigned community for each node:\n");
  igraph_vector_int_t *best_membership1 = (igraph_vector_int_t *)VECTOR(cmpnts)[iter_num];
  for (i = 0; i < igraph_vector_int_size(best_membership1); i++) {
    igraph_integer_t comm1 = VECTOR(*best_membership1)[i];
    printf("%ld", (long)comm1);  // Use %ld for igraph_integer_t
    if (i < igraph_vector_int_size(best_membership1) - 1) {
      printf(", ");
    }
  }
  printf("\n");
  printf("Nodes:\n");
  for (i = 0; i < n_nodes; i++) {
    const char *name = NULL;
    for (int j = 0; j < city_map->size; j++) {
      if (city_map->indices[j] == i) {
        name = city_map->names[j];
        printf("%s", name);
        if (j < igraph_vector_int_size(best_membership1) - 1) {
          printf(", ");
        }
        break;
      }
    }
  }
  printf("\n");

  /*// Print community assignments using original node names
   printf("Assigned community for each node:\n");
   for (i = 0; i < n_nodes; i++) {
   const char *name = NULL;
   for (int j = 0; j < city_map->size; j++) {
   if (city_map->indices[j] == i) {
   name = city_map->names[j];
   break;
   }
   }
   igraph_integer_t comm = VECTOR(*best_membership)[i];
   printf("%s: %ld\n", name, (long)comm);
   }*/


  // Below works nicely to print string of comma separated node names, output to result
  char node_names[BUFFER_SIZE] = "";  // Initialize empty character array
  store_city_names(n_nodes, city_map, node_names, BUFFER_SIZE);
  //printf("List of node names: %s\n", node_names);

  igraph_vector_int_t bridges;  // Correctly declare as a variable, not a pointer!
  igraph_vector_int_init(&bridges, 0);
  igraph_bridges(graph, &bridges);
  char bridge_list[BUFFER_SIZE] = "";
  bridges_to_string(&bridges, bridge_list, BUFFER_SIZE);
  //printf("Bridge Edges: %s\n", bridge_list);

  // Populate result
  res->names = node_names;
  res->vcount = n_nodes;
  res->algorithm = "node degree+edge betweenness";
  res->modularity = modularities;
  res->membership = best_membership;
  res->bridges = bridge_list;

  // Clean up
  for (i = 0; i < igraph_vector_ptr_size(&cmpnts); i++) {
    if (i != iter_num) {
      igraph_vector_int_t *mem = (igraph_vector_int_t *)VECTOR(cmpnts)[i];
      igraph_vector_int_destroy(mem);
      free(mem);
    }
  }
  igraph_vector_ptr_destroy(&cmpnts);
  igraph_destroy(&graph_);
}

int main(int argc, char *argv[]) {
  // **Enable igraph attribute handling, have to set this at very start of program**
  igraph_set_attribute_table(&igraph_cattribute_table);

  if (argc < 2) {
    fprintf(stderr, "Usage: %s <filename>\n", argv[0]);
    return EXIT_FAILURE;
  }

  igraph_t g;
  NameIndexMap city_map;
  int n_nodesG;
  read_edgelist(argv[1], &g, &city_map);


  // Assign names to graph nodes
  //n_nodesG = igraph_vcount(&g);
  //assign_node_names(&g, &city_map, n_nodesG);

  /*// Verify, print node names from the graph
   printf("Graph node names:\n");
   for (int i = 0; i < n_nodesG; i++) {
   const char *nnname = igraph_cattribute_VAS(&g, "name", i);
   printf("Node %d: %s\n", i, nnname);
   }*/

  Result res = {0};
  cluster_degree_betweenness(&g, &city_map, &res);

  //This prints result of algorithm
  //printf("Nodes: %s\n", res.names);
  //printf("Algorithm: %s\n", res.algorithm);
  //printf("Bridges: %s\n", res.bridges);


  ////////////
  // Write results to output.txt
  FILE *fp = fopen("community_detection_OUTPUT.txt", "w");
  if (fp == NULL) {
    perror("Error opening output.txt");
    return EXIT_FAILURE;
  }

  // Write all result fields to the file
  fprintf(fp, "Nodes: %s\n", res.names);
  fprintf(fp, "Number of nodes: %ld\n", (long)res.vcount);
  fprintf(fp, "Algorithm: %s\n", res.algorithm);

  // Write modularity vector
  fprintf(fp, "Modularity values:\n");
  for (long i = 0; i < igraph_vector_size(res.modularity); i++) {
    fprintf(fp, "Iteration %ld: %.16f\n", i + 1, VECTOR(*res.modularity)[i]);
  }

  // Write membership/community assignments with node names
  fprintf(fp, "Community assignments:\n");
  for (igraph_integer_t i = 0; i < res.vcount; i++) {
    const char *name = igraph_cattribute_VAS(&g, "name", i);
    if (name) {
      fprintf(fp, "%s: %ld\n", name, (long)VECTOR(*res.membership)[i]);
    }
  }

  fprintf(fp, "Bridges: %s\n", res.bridges);

  // Close the file
  fclose(fp);
  ////////////

  // Clean up
  igraph_destroy(&g);
  igraph_vector_destroy(res.modularity);
  free(res.modularity);
  igraph_vector_int_destroy(res.membership);
  free(res.membership);
  free_name_index_map(&city_map);

  return EXIT_SUCCESS;
}

library(KEGGREST)
# Define a function to retrieve KEGG pathways for *Ralstonia* species
get_kegg_pathways <- function(species_id) {
  # Retrieve pathways for the species
  kegg_pathways <- keggLink("pathway", species_id)
  pathway_info <- keggList("pathway", species_id)
  return(pathway_info)
}

# Example usage with *Ralstonia* species KEGG ID, e.g., "rso" for Ralstonia solanacearum
species_id <- "bpla"  # Replace with the appropriate species abbreviation if available
kegg_pathways <- get_kegg_pathways(species_id)
print(kegg_pathways)

write.csv(kegg_pathways, "/home/akshay/major_project/results/Burkholderia_plantarii_pathways.csv")

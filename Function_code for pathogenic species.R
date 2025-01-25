# Function to safely extract data and handle missing fields
library(rentrez)

safe_extract <- function(gene_summary, field) {
  if (is.null(gene_summary[[field]])) {
    return(NA)
  }
  return(gene_summary[[field]])
}

# Modified function to retrieve gene information
get_genes_from_ncbi <- function(organism_name, retmax = 100) {
  # Search for the organism in the NCBI Gene database
  search_query <- paste0(organism_name, "[ORGN]")
  search_results <- entrez_search(db = "gene", term = search_query, retmax = retmax)
  
  if (length(search_results$ids) == 0) {
    stop("No gene records found for the specified organism.")
  }
  
  # Fetch detailed summaries for the genes
  gene_summaries <- entrez_summary(db = "gene", id = search_results$ids)
  
  # Convert summaries to a data frame, handling missing fields
  gene_info <- do.call(rbind, lapply(gene_summaries, function(x) {
    data.frame(
      GeneID = safe_extract(x, "uid"),
      GeneName = safe_extract(x, "name"),
      Description = safe_extract(x, "description"),
      Organism = safe_extract(x, "organism"),
      stringsAsFactors = FALSE
    )
  }))
  
  return(gene_info)
}

# Example usage
organism_name <- "Agrobacterium"  # Replace with the name of the bacterium of interest
genes <- get_genes_from_ncbi(organism_name)

# View the results
print(genes)
write.csv(genes, "/home/akshay/major_project/results/genes_Agrobacterium_species.csv", row.names = FALSE)  # Export results to a CSV file


# Load packages
library(rentrez)     # For querying NCBI
library(KEGGREST)    # For accessing KEGG pathway data
library(seqinr)      # For reading FASTA files

rm(list = ls())

# Load FASTA file (contains sequences)
fasta_file <- "/home/akshay/major_project/pathogenic_sequences.fasta"
sequences <- read.fasta(fasta_file, seqtype = "DNA", as.string = TRUE)



# Load taxonomy file (contains feature IDs and taxonomy)
taxonomy_file <- "/home/akshay/major_project/taxonomy.tsv"
taxonomy_data <- read.table(taxonomy_file, header = TRUE, sep = "\t")
feature_ids <- taxonomy_data$Feature.ID  # Adjust column name as necessary


# Load feature IDs from the text file
feature_ids_file <- "/home/akshay/major_project/pathogenic_otu_ids.txt"
feature_ids <- readLines(feature_ids_file)



# Define the get_ncbi_annotation function with error handling and debugging
get_ncbi_annotation <- function(id) {
  tryCatch({
    # Print the current ID to track progress
    print(paste("Processing ID:", id))
    
    # Search for the feature ID in the nucleotide database
    search_result <- entrez_search(db = "protein", term = id)
    
    if (length(search_result$ids) > 0) {
      # Fetch GenBank record for the first result
      record <- entrez_fetch(db = "nuccore", id = search_result$ids[1], rettype = "gb", retmode = "text")
      
      # Extract gene name and description
      gene_name <- sub(".*?gene=([\\w\\d]+).*", "\\1", record)
      description <- sub(".*?product=([\\w\\s]+).*", "\\1", record)
      
      return(data.frame(ID = id, Gene_Name = gene_name, Description = description, stringsAsFactors = FALSE))
    } else {
      # If no result is found, return NA
      return(data.frame(ID = id, Gene_Name = NA, Description = NA, stringsAsFactors = FALSE))
    }
  }, error = function(e) {
    # Print error message if function fails
    print(paste("Error processing ID:", id))
    return(data.frame(ID = id, Gene_Name = NA, Description = NA, stringsAsFactors = FALSE))
  })
}

# Apply the function to all feature IDs and combine the results
annotations <- do.call(rbind, lapply(feature_ids, get_ncbi_annotation))

# View the resulting data frame
View(annotations)

# Save the results to a CSV file
write.csv(annotations, "annotations.csv", row.names = FALSE)

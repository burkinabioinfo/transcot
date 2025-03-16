# transcot

## 1. SRA Download and FASTQ Conversion

This step automates the process of downloading SRA datasets and converting them into compressed FASTQ files. The key actions include:

- **Querying SRA**: Using Entrez Direct (`esearch` and `efetch`), the script retrieves run information (SRR IDs) for specified projects.
- **Downloading Data**: The SRA files are downloaded using `prefetch` into a temporary directory.
- **Converting to FASTQ**: The downloaded `.sra` files are converted into FASTQ files (compressed with gzip) using `fasterq-dump` with the `--split-files` option for paired-end reads.
- **Cleanup**: Temporary files are automatically removed after processing to maintain a clean workspace.

This approach streamlines data retrieval and preprocessing, integrating seamlessly into the project pipeline.


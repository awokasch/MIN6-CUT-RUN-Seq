#!/bin/bash

cd "/Volumes/One Touch/CUT_RUN"

# Path to blacklist
BLACKLIST="/Volumes/One Touch/genomes/mm10blacklist.liftover.genome_mm39.bed"

echo "Starting blacklist filtering..."

# Filter each peak file
for peaks in *.mm39_peaks.narrowPeak; do
  base="${peaks%.mm39_peaks.narrowPeak}"
  filtered="${base}_BLfiltered.narrowPeak"
  
  echo "Filtering: $peaks"
  
  bedtools intersect -v \
    -a "$peaks" \
    -b "$BLACKLIST" \
    > "$filtered"
  
  echo "Done: $filtered"
done

echo "All peaks filtered!"

#!/bin/bash

cd "/Volumes/One Touch/CUT_RUN"

ADAPTER="/Volumes/One Touch/Bioinformatics/TruSeq_CD_adapter.txt"

echo "Your Mac has $(sysctl -n hw.logicalcpu) logical CPUs"

for r1 in *_S1_L005_R1_001.fastq.gz; do
  r2="${r1/_R1_/_R2_}"

  if [[ ! -f "$r2" ]]; then
    echo "Warning: mate file not found for $r1 (expected $r2), skipping..."
    continue
  fi

  base_r1="${r1%.fastq.gz}"
  out_r1_paired="${base_r1}.trimmed_paired.fastq.gz"

  # SKIP if already trimmed
  if [[ -f "$out_r1_paired" ]]; then
    echo "Skipping $r1 (already trimmed)"
    continue
  fi

  base_r2="${r2%.fastq.gz}"
  out_r1_unpaired="${base_r1}.trimmed_unpaired.fastq.gz"
  out_r2_paired="${base_r2}.trimmed_paired.fastq.gz"
  out_r2_unpaired="${base_r2}.trimmed_unpaired.fastq.gz"

  echo "Trimming PE: $r1 and $r2"

  trimmomatic PE -threads 24 \
    "$r1" "$r2" \
    "$out_r1_paired" "$out_r1_unpaired" \
    "$out_r2_paired" "$out_r2_unpaired" \
    "ILLUMINACLIP:$ADAPTER:2:30:7" \
    LEADING:15 TRAILING:15 MINLEN:15

  echo "Completed trimming: $r1 and $r2"
done

echo "All trimming complete!"

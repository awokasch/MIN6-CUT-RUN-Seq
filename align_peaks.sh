#!/bin/bash

cd "/Volumes/One Touch/CUT_RUN"

BOWTIE_INDEX="/Volumes/One Touch/genomes/mm39_ec/mm39_ec"

echo "Starting alignment pipeline..."

# ===== ALIGNMENT (SAM → BAM PIPE) =====

for r1 in *.trimmed_paired.fastq.gz; do
  if [[ "$r1" == *"_R2_"* ]]; then
    continue
  fi
  
  r2="${r1/_R1_/_R2_}"
  base="${r1%.trimmed_paired.fastq.gz}"
  bam_all="${base}.mm39_ec.bam"
  
  if [[ -f "$bam_all" ]]; then
    echo "Skipping alignment for $base (already done)"
    continue
  fi
  
  echo "Aligning: $r1 and $r2"
  
  bowtie2 -p 6 \
    -x "$BOWTIE_INDEX" \
    -1 "$r1" -2 "$r2" | samtools view -b - -o "$bam_all"
  
  echo "Alignment complete: $bam_all"
done

# ===== BAM FILTERING =====
echo "Filtering BAM files..."

for bam in *.mm39_ec.bam; do
  base="${bam%.mm39_ec.bam}"
  
  bam_F4q10="${base}.mm39_ec.F4q10.bam"
  bam_sorted="${base}.mm39_ec.F4q10.sorted.bam"
  bam_mm39="${base}.mm39.F4q10.sorted.bam"
  
  if [[ -f "$bam_mm39" ]]; then
    echo "Skipping BAM processing for $base (already done)"
    continue
  fi
  
  echo "Processing: $bam"
  
  samtools view -b -F 4 -q 10 -@ 6 "$bam" -o "$bam_F4q10"
  samtools sort -@ 6 "$bam_F4q10" -o "$bam_sorted"
  samtools index "$bam_sorted"
  
  samtools view -@ 6 -bh "$bam_sorted" \
    chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chrX chrY chrM > "$bam_mm39"
  samtools index "$bam_mm39"
  
  echo "BAM processing complete: $bam_mm39"
done

# ===== PEAK CALLING WITH MACS3 =====
echo "Calling peaks with MACS3..."

for bam in *.mm39.F4q10.sorted.bam; do
  base="${bam%.mm39.F4q10.sorted.bam}"
  peaks_out="${base}.mm39_peaks.narrowPeak"
  
  if [[ -f "$peaks_out" ]]; then
    echo "Skipping peak calling for $base (already done)"
    continue
  fi
  
  echo "Calling peaks for: $bam"
  
  macs3 callpeak \
    -t "$bam" \
    -g mm \
    -f BAMPE \
    -q 0.01 \
    --nomodel \
    --shift 0 \
    --extsize 150 \
    --keep-dup all \
    -n "$base.mm39"
  
  echo "Peaks called: ${base}.mm39_peaks.narrowPeak"
done

echo "Pipeline complete!"

#!/bin/bash

cd "/Volumes/One Touch/CUT_RUN"

# Define your conditions (use filtered peaks!)
WT_PEAKS=("14630-AW-0001_S1_L005_R1_001_BLfiltered.narrowPeak" \
          "14630-AW-0002_S1_L005_R1_001_BLfiltered.narrowPeak" \
          "14630-AW-0003_S1_L005_R1_001_BLfiltered.narrowPeak")

DELTA_C_PEAKS=("14630-AW-0004_S1_L005_R1_001_BLfiltered.narrowPeak" \
               "14630-AW-0005_S1_L005_R1_001_BLfiltered.narrowPeak" \
               "14630-AW-0006_S1_L005_R1_001_BLfiltered.narrowPeak")

DELTA_207_PEAKS=("14630-AW-0007_S1_L005_R1_001_BLfiltered.narrowPeak" \
                 "14630-AW-0008_S1_L005_R1_001_BLfiltered.narrowPeak" \
                 "14630-AW-0009_S1_L005_R1_001_BLfiltered.narrowPeak")

DELTA_216_PEAKS=("14630-AW-0010_S1_L005_R1_001_BLfiltered.narrowPeak" \
                 "14630-AW-0011_S1_L005_R1_001_BLfiltered.narrowPeak" \
                 "14630-AW-0012_S1_L005_R1_001_BLfiltered.narrowPeak")

H3K4ME3_PEAKS=("14630-AW-0013_S1_L005_R1_001_BLfiltered.narrowPeak" \
               "14630-AW-0014_S1_L005_R1_001_BLfiltered.narrowPeak" \
               "14630-AW-0015_S1_L005_R1_001_BLfiltered.narrowPeak")

MCHERRY_PEAKS=("14630-AW-0016_S1_L005_R1_001_BLfiltered.narrowPeak" \
               "14630-AW-0017_S1_L005_R1_001_BLfiltered.narrowPeak" \
               "14630-AW-0018_S1_L005_R1_001_BLfiltered.narrowPeak")

# Create output directories
mkdir -p peak_overlap_analysis
mkdir -p peak_overlap_analysis/filtered_peaks

echo "=== PEAK OVERLAP ANALYSIS ==="

# Function to merge peak files
merge_peaks() {
  local output=$1
  shift
  cat "$@" | sort -k1,1 -k2,2n | bedtools merge -i stdin > "$output"
}

# ===== STEP 1: MERGE PEAKS PER CONDITION =====
echo ""
echo "=== STEP 1: MERGING PEAKS PER CONDITION ==="

echo "Merging WT peaks..."
merge_peaks peak_overlap_analysis/WT_merged.bed "${WT_PEAKS[@]}"
echo "WT merged peaks:"
wc -l peak_overlap_analysis/WT_merged.bed

echo "Merging DeltaC peaks..."
merge_peaks peak_overlap_analysis/DELTA_C_merged.bed "${DELTA_C_PEAKS[@]}"
echo "DeltaC merged peaks:"
wc -l peak_overlap_analysis/DELTA_C_merged.bed

echo "Merging Delta207 peaks..."
merge_peaks peak_overlap_analysis/DELTA_207_merged.bed "${DELTA_207_PEAKS[@]}"
echo "Delta207 merged peaks:"
wc -l peak_overlap_analysis/DELTA_207_merged.bed

echo "Merging Delta216 peaks..."
merge_peaks peak_overlap_analysis/DELTA_216_merged.bed "${DELTA_216_PEAKS[@]}"
echo "Delta216 merged peaks:"
wc -l peak_overlap_analysis/DELTA_216_merged.bed

echo "Merging H3K4me3 peaks..."
merge_peaks peak_overlap_analysis/H3K4ME3_merged.bed "${H3K4ME3_PEAKS[@]}"
echo "H3K4me3 merged peaks:"
wc -l peak_overlap_analysis/H3K4ME3_merged.bed

echo "Merging mCherry control peaks..."
merge_peaks peak_overlap_analysis/MCHERRY_merged.bed "${MCHERRY_PEAKS[@]}"
echo "mCherry merged peaks:"
wc -l peak_overlap_analysis/MCHERRY_merged.bed

# ===== STEP 2: REMOVE mCHERRY BACKGROUND =====
echo ""
echo "=== STEP 2: FILTERING OUT mCHERRY BACKGROUND ==="

echo "Filtering mCherry peaks from WT..."
bedtools intersect -v \
    -a peak_overlap_analysis/WT_merged.bed \
    -b peak_overlap_analysis/MCHERRY_merged.bed \
    > peak_overlap_analysis/WT_mCherry_filtered.bed
echo "WT before mCherry filter:"
wc -l peak_overlap_analysis/WT_merged.bed
echo "WT after mCherry filter:"
wc -l peak_overlap_analysis/WT_mCherry_filtered.bed

echo ""
echo "Filtering mCherry peaks from DeltaC..."
bedtools intersect -v \
    -a peak_overlap_analysis/DELTA_C_merged.bed \
    -b peak_overlap_analysis/MCHERRY_merged.bed \
    > peak_overlap_analysis/DELTA_C_mCherry_filtered.bed
echo "DeltaC before mCherry filter:"
wc -l peak_overlap_analysis/DELTA_C_merged.bed
echo "DeltaC after mCherry filter:"
wc -l peak_overlap_analysis/DELTA_C_mCherry_filtered.bed

echo ""
echo "Filtering mCherry peaks from Delta207..."
bedtools intersect -v \
    -a peak_overlap_analysis/DELTA_207_merged.bed \
    -b peak_overlap_analysis/MCHERRY_merged.bed \
    > peak_overlap_analysis/DELTA_207_mCherry_filtered.bed
echo "Delta207 before mCherry filter:"
wc -l peak_overlap_analysis/DELTA_207_merged.bed
echo "Delta207 after mCherry filter:"
wc -l peak_overlap_analysis/DELTA_207_mCherry_filtered.bed

echo ""
echo "Filtering mCherry peaks from Delta216..."
bedtools intersect -v \
    -a peak_overlap_analysis/DELTA_216_merged.bed \
    -b peak_overlap_analysis/MCHERRY_merged.bed \
    > peak_overlap_analysis/DELTA_216_mCherry_filtered.bed
echo "Delta216 before mCherry filter:"
wc -l peak_overlap_analysis/DELTA_216_merged.bed
echo "Delta216 after mCherry filter:"
wc -l peak_overlap_analysis/DELTA_216_mCherry_filtered.bed

echo ""
echo "Filtering mCherry peaks from H3K4me3..."
bedtools intersect -v \
    -a peak_overlap_analysis/H3K4ME3_merged.bed \
    -b peak_overlap_analysis/MCHERRY_merged.bed \
    > peak_overlap_analysis/H3K4ME3_mCherry_filtered.bed
echo "H3K4me3 before mCherry filter:"
wc -l peak_overlap_analysis/H3K4ME3_merged.bed
echo "H3K4me3 after mCherry filter:"
wc -l peak_overlap_analysis/H3K4ME3_mCherry_filtered.bed

# ===== STEP 3: PEAK OVERLAP ANALYSIS ON FILTERED PEAKS =====
echo ""
echo "=== STEP 3: PEAK OVERLAP ANALYSIS (mCherry filtered peaks) ==="

echo ""
echo "=== WT vs DeltaC ==="
echo "Peaks LOST in DeltaC:"
bedtools intersect -v \
    -a peak_overlap_analysis/WT_mCherry_filtered.bed \
    -b peak_overlap_analysis/DELTA_C_mCherry_filtered.bed \
    > peak_overlap_analysis/WT_only_vs_DeltaC.bed
wc -l peak_overlap_analysis/WT_only_vs_DeltaC.bed

echo "Peaks SHARED between WT and DeltaC:"
bedtools intersect -u \
    -a peak_overlap_analysis/WT_mCherry_filtered.bed \
    -b peak_overlap_analysis/DELTA_C_mCherry_filtered.bed \
    > peak_overlap_analysis/WT_and_DeltaC_shared.bed
wc -l peak_overlap_analysis/WT_and_DeltaC_shared.bed

echo "Peaks UNIQUE to DeltaC:"
bedtools intersect -v \
    -a peak_overlap_analysis/DELTA_C_mCherry_filtered.bed \
    -b peak_overlap_analysis/WT_mCherry_filtered.bed \
    > peak_overlap_analysis/DeltaC_only.bed
wc -l peak_overlap_analysis/DeltaC_only.bed

echo ""
echo "=== WT vs Delta207 ==="
echo "Peaks LOST in Delta207:"
bedtools intersect -v \
    -a peak_overlap_analysis/WT_mCherry_filtered.bed \
    -b peak_overlap_analysis/DELTA_207_mCherry_filtered.bed \
    > peak_overlap_analysis/WT_only_vs_207.bed
wc -l peak_overlap_analysis/WT_only_vs_207.bed

echo "Peaks SHARED between WT and Delta207:"
bedtools intersect -u \
    -a peak_overlap_analysis/WT_mCherry_filtered.bed \
    -b peak_overlap_analysis/DELTA_207_mCherry_filtered.bed \
    > peak_overlap_analysis/WT_and_207_shared.bed
wc -l peak_overlap_analysis/WT_and_207_shared.bed

echo "Peaks UNIQUE to Delta207:"
bedtools intersect -v \
    -a peak_overlap_analysis/DELTA_207_mCherry_filtered.bed \
    -b peak_overlap_analysis/WT_mCherry_filtered.bed \
    > peak_overlap_analysis/207_only.bed
wc -l peak_overlap_analysis/207_only.bed

echo ""
echo "=== WT vs Delta216 ==="
echo "Peaks LOST in Delta216:"
bedtools intersect -v \
    -a peak_overlap_analysis/WT_mCherry_filtered.bed \
    -b peak_overlap_analysis/DELTA_216_mCherry_filtered.bed \
    > peak_overlap_analysis/WT_only_vs_216.bed
wc -l peak_overlap_analysis/WT_only_vs_216.bed

echo "Peaks SHARED between WT and Delta216:"
bedtools intersect -u \
    -a peak_overlap_analysis/WT_mCherry_filtered.bed \
    -b peak_overlap_analysis/DELTA_216_mCherry_filtered.bed \
    > peak_overlap_analysis/WT_and_216_shared.bed
wc -l peak_overlap_analysis/WT_and_216_shared.bed

echo "Peaks UNIQUE to Delta216:"
bedtools intersect -v \
    -a peak_overlap_analysis/DELTA_216_mCherry_filtered.bed \
    -b peak_overlap_analysis/WT_mCherry_filtered.bed \
    > peak_overlap_analysis/216_only.bed
wc -l peak_overlap_analysis/216_only.bed

echo ""
echo "=== Delta207 vs Delta216 ==="
echo "Peaks SHARED:"
bedtools intersect -u \
    -a peak_overlap_analysis/DELTA_207_mCherry_filtered.bed \
    -b peak_overlap_analysis/DELTA_216_mCherry_filtered.bed \
    > peak_overlap_analysis/207_and_216_shared.bed
wc -l peak_overlap_analysis/207_and_216_shared.bed

echo "Peaks UNIQUE to Delta207 vs Delta216:"
bedtools intersect -v \
    -a peak_overlap_analysis/DELTA_207_mCherry_filtered.bed \
    -b peak_overlap_analysis/DELTA_216_mCherry_filtered.bed \
    > peak_overlap_analysis/207_only_vs_216.bed
wc -l peak_overlap_analysis/207_only_vs_216.bed

echo ""
echo "=== Delta207 vs DeltaC ==="
echo "Peaks SHARED:"
bedtools intersect -u \
    -a peak_overlap_analysis/DELTA_207_mCherry_filtered.bed \
    -b peak_overlap_analysis/DELTA_C_mCherry_filtered.bed \
    > peak_overlap_analysis/207_and_DeltaC_shared.bed
wc -l peak_overlap_analysis/207_and_DeltaC_shared.bed

echo ""
echo "=== Delta216 vs DeltaC ==="
echo "Peaks SHARED:"
bedtools intersect -u \
    -a peak_overlap_analysis/DELTA_216_mCherry_filtered.bed \
    -b peak_overlap_analysis/DELTA_C_mCherry_filtered.bed \
    > peak_overlap_analysis/216_and_DeltaC_shared.bed
wc -l peak_overlap_analysis/216_and_DeltaC_shared.bed

# ===== STEP 4: SAVE FILTERED PEAKS FOR BIGWIG GENERATION =====
echo ""
echo "=== STEP 4: SAVING FILTERED PEAKS FOR BIGWIG GENERATION ==="

cp peak_overlap_analysis/WT_mCherry_filtered.bed \
   peak_overlap_analysis/filtered_peaks/WT_filtered.bed
cp peak_overlap_analysis/DELTA_C_mCherry_filtered.bed \
   peak_overlap_analysis/filtered_peaks/DeltaC_filtered.bed
cp peak_overlap_analysis/DELTA_207_mCherry_filtered.bed \
   peak_overlap_analysis/filtered_peaks/Delta207_filtered.bed
cp peak_overlap_analysis/DELTA_216_mCherry_filtered.bed \
   peak_overlap_analysis/filtered_peaks/Delta216_filtered.bed
cp peak_overlap_analysis/H3K4ME3_mCherry_filtered.bed \
   peak_overlap_analysis/filtered_peaks/H3K4me3_filtered.bed
cp peak_overlap_analysis/MCHERRY_merged.bed \
   peak_overlap_analysis/filtered_peaks/mCherry_filtered.bed

# Create all conditions merged (mCherry filtered)
cat peak_overlap_analysis/WT_mCherry_filtered.bed \
    peak_overlap_analysis/DELTA_C_mCherry_filtered.bed \
    peak_overlap_analysis/DELTA_207_mCherry_filtered.bed \
    peak_overlap_analysis/DELTA_216_mCherry_filtered.bed \
    | sort -k1,1 -k2,2n \
    | bedtools merge -i stdin \
    > peak_overlap_analysis/filtered_peaks/all_conditions_merged.bed

echo "All filtered peak files:"
ls -lh peak_overlap_analysis/filtered_peaks/

echo ""
echo "=== PEAK OVERLAP ANALYSIS COMPLETE ==="

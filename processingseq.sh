


#Set an array of sample names
samples=("1" "2")

exec > >(tee -a test4log.txt) 2>&1

# Set the input file paths for paired-end reads

for sample in "${samples[@]}"
do
  sample1="${sample}-trimmed-pair1.fastq"
  sample2="${sample}-trimmed-pair2.fastq"
  
  # create a new directory for each sample
  directory="output/${sample}"
  mkdir -p $directory
    
    dedupe_command="dedupe.sh in=${sample1},${sample2} out=${directory}/${sample}_trimmed-dedupe.fastq ac=f mlp=100 mop=100 -Xmx20g"
    subsample_command="seqtk sample -s 11 ${directory}/${sample}_trimmed-dedupe.fastq 50000 > ${directory}/${sample}_trimmed-dedupe-50K.fastq"
    split_command="bbsplitpairs.sh in=${directory}/${sample}_trimmed-dedupe-50K.fastq out=${directory}/${sample}_trimmed-dedupe-50K-split_R1.fastq out2=${directory}/${sample}_trimmed-dedupe-50K-split_R2.fastq"

eval ${dedupe_command}
if [ $? -ne 0 ]; then
    echo "Error running command: ${dedupe_command}"
    exit 1
fi

eval ${subsample_command}
if [ $? -ne 0 ]; then
    echo "Error running command: ${subsample_command}"
    exit 1
fi

eval ${split_command}
if [ $? -ne 0 ]; then
    echo "Error running command: ${split_command}"
    exit 1
fi
done


# RGI
for sample in "${samples[@]}"
do
    rgi_directory="output/${sample}"
    bwt_command="rgi bwt --threads 8 --read_one ${rgi_directory}/${sample}_trimmed-dedupe-50K-split_R1.fastq --read_two ${rgi_directory}/${sample}_trimmed-dedupe-50K-split_R2.fastq --aligner kma --output ${rgi_directory}/${sample} --debug --clean --local --include_wildcard"
    kmer_query_command="rgi kmer_query --threads 8 --input ${rgi_directory}/${sample}.sorted.length_100.bam --kmer_size 61 --bwt --output ${rgi_directory}/${sample}.kmer_query.out --debug --local"
    eval ${bwt_command}
    if [ $? -ne 0 ]; then
        echo "Error running command: ${bwt_command}"
        exit 1
    fi

    eval ${kmer_query_command}
    if [ $? -ne 0 ]; then
        echo "Error running command: ${kmer_query_command}"
        exit 1
    fi
done

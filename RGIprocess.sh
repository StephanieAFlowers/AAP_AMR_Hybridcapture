# RGI version 5.5.1 

for sample in "${samples[@]}"
do

 base_sample=$(echo ${sample} | grep -o '[0-9]\{2\}$')
    directory="output/${base_sample}"
    
    # create the directory for the sample
    directory="output/${base_sample}"
    bwt_command="rgi bwt --threads 8 --read_one ${directory}/${base_sample}_trimmed-dedupe-50K-split_R1.fastq --read_two ${directory}/${base_sample}_trimmed-dedupe-50K-split_R2.fastq --aligner kma --output_file ${directory}/${base_sample} --debug --clean --local --include_wildcard"
    kmer_query_command="rgi kmer_query --threads 8 --input ${directory}/${base_sample}.sorted.length_100.bam --kmer_size 61 --bwt --output ${directory}/${base_sample}.sorted.length_100.bam --debug --local"

eval ${bwt_command}
if [ $? -ne 0 ]; then
    echo "Error running command: ${subsample_command}"
    exit 1
fi

eval ${kmer_query_command}
if [ $? -ne 0 ]; then
    echo "Error running command: ${split_command}"
    exit 1
fi
done

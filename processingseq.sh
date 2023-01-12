

samples=("XXX" "XXX")

##Trim samples with skewer

for sample in "${samples[@]}"
do

skewer -m pe -q 25 -Q 25 ${sample}_R1.fastq ${sample}_R2.fastq -o ${sample}-trimmed --threads 40

done

#Deduplicate (bbmap) and subsample reads (seqtk)- output files into seperate folders

for sample in "${samples[@]}"
do

# Set the input file paths for paired-end reads
  sample1="${sample}-trimmed-pair1.fastq"
  sample2="${sample}-trimmed-pair2.fastq"


    base_sample=$(echo ${sample} | grep -o '[0-9]\{2\}$')
    directory="output/${base_sample}"
    mkdir -p $directory
    
    dedupe_command="dedupe.sh in=${sample1},${sample2} out=${directory}/${base_sample}_trimmed-dedupe.fastq ac=f mlp=100 mop=100 -Xmx20g"
    subsample_command="seqtk sample -s 11 ${directory}/${base_sample}_trimmed-dedupe.fastq 50000 > ${directory}/${base_sample}_trimmed-dedupe-50K.fastq"
    split_command="bbsplitpairs.sh in=${directory}/${base_sample}_trimmed-dedupe-50K.fastq out=${directory}/${base_sample}_trimmed-dedupe-50K-split_R1.fastq out2=${directory}/${base_sample}_trimmed-dedupe-50K-split_R2.fastq"

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



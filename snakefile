######
# Experimental pangenome pipeline
# Antton Alberdi & Carlotta Pietroni
# 2025/01/22
# Description: the pipeline maps reads from a bam file into a pangenome reference
#
# 1) Clone this repo.
# 2) Place genomes with .fna extension in the input folder.
# 3) Create a screen session.
# 4) Launch the snakemake using the following code:
# module purge && module load snakemake/7.20.0 mamba/1.3.1
# snakemake -j 20 --cluster 'sbatch -o logs/{params.jobname}-slurm-%j.out --mem {resources.mem_gb}G --time {resources.time} -c {threads} --job-name={params.jobname} -v'   --use-conda --conda-frontend mamba --conda-prefix conda --latency-wait 600
#
######

#List sample wildcards
samples, = glob_wildcards("input/{sample}.bam")

#Target files
rule all:
    input:
        expand("output/{sample}.bam", sample=samples)

rule bowtie_build:
    input:
        "pangenome/all_gene_families.fna"
    output:
        touch('pangenome/index.done') # Flag file
    params:
        jobname = "pangenome_index",
        index = "pangenome/all_gene_families"
    threads:
        8
    resources:
        mem_gb=8,
        time='00:15:00'
    log:
        "logs/pangenome_index.log"
    shell:
        """
	module load bowtie2/2.4.2
        bowtie2-build \
            --large-index \
            --threads {threads} \
            {input} {params.index} \
        &> {log}
        """

rule extract_bam:
    input:
        "input/{sample}.bam"
    output:
	read1="reads/{sample}.1.fq",
	read2="reads/{sample}.2.fq"
    params:
        jobname = "extract_{sample}"
    threads:
        20
    resources:
        mem_gb=8,
        time='00:30:00'
    log:
        "logs/{sample}_extract.log"
    shell:
        """
	module load samtools/1.21
        samtools fastq -1 {output.read1} -2 {output.read2} {input}
        """

rule bowtie_map:
    input:
        idx = "pangenome/index.done",
        read1 = "reads/{sample}.1.fq",
        read2 = "reads/{sample}.2.fq",
    output:
        "output/{sample}.bam"
    params:
        jobname = "mags_{sample}",
        reference = "pangenome/all_gene_families"
    threads:
        8
    resources:
        mem_gb=24,
        time='00:30:00'
    log:
        "logs/{sample}_map.log"
    shell:
        """
	module load bowtie2/2.4.2 samtools/1.21
	bowtie2 \
            --time \
            --threads {threads} \
            -x {params.reference} \
            -1 {input.read1} \
            -2 {input.read2} \
            --seed 1337 \
        | samtools sort -@ {threads} -o {output} \
        &> {log}
        """

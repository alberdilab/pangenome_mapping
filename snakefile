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
genomes, = glob_wildcards("input/{genome}.fna")

#Target files
rule all:
    input:
        expand("output/{genome}/annotations.tsv", genome=genomes)

rule dram:
    input:
        "input/{genome}.fna"
    output:
        annotations="output/{genome}/annotations.tsv"
    params:
        outputdir=workflow.basedir + "/output/{genome}",
	jobname="{genome}.dr"
    threads:
        1
    resources:
        mem_gb=24,
        time='02:00:00'
    shell:
        """
	module load dram/1.5.0
	rm -rf {params.outputdir}
	DRAM.py annotate \
                -i {input} \
                -o {params.outputdir} \
		--config_loc dram_config \
                --threads {threads} \
                --min_contig_size 1500 
        """

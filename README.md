# pangenome_mapping

The pipeline only relies on two software:

- Mamba
- Snakemake

The rest of the many required softwatre are downloaded and installed inside the conda environments.

### Prepare working environment

```sh


# Clone metagenomic assembly+binning pipeline repository
git clone https://github.com/alberdilab/pangenome_mapping.git
mv pangenome_mapping pangenome_mapping_test1

# Create screen session 
screen -S pangenome_mapping_test1
cd pangenome_mapping_test1
module load snakemake/7.19.1
snakemake -j 20 --cluster 'sbatch -o logs/{params.jobname}-slurm-%j.out --mem {resources.mem_gb}G --time {resources.time} -c {threads} --job-name={params.jobname} -v' --latency-wait 600
```

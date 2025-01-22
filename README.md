# pangenome_mapping

The pipeline only relies on two software:

- Mamba
- Snakemake

The rest of the many required softwatre are downloaded and installed inside the conda environments.

### Prepare working environment

```sh
# Load dependencies mamba and snakemake (not needed if they are already installed in root)
module load mamba/1.5.6 snakemake/7.20.0

# Clone metagenomic assembly+binning pipeline repository
cd pangenome_mapping
git clone https://github.com/3d-alberdilab/pangenome_mapping.git
mv pangenome_mapping_test1


# Create screen session 
screen -S pangenome_mapping_test1
cd pangenome_mapping_test1
snakemake -j 20 --cluster 'sbatch -o logs/{params.jobname}-slurm-%j.out --mem {resources.mem_gb}G --time {resources.time} -c {threads} --job-name={params.jobname} -v'   --use-conda --conda-frontend mamba --conda-prefix conda --latency-wait 600
```

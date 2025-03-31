FROM ucsb/jupyter-base:latest

MAINTAINER LSIT Systems <lsitops@lsit.ucsb.edu>

USER root



RUN conda install -y \
  bioconda::fastqc \
  bioconda::trimmomatic \
  agbiome::bbtools \
  bioconda::megahit \
  bioconda::spades \
  bioconda::quast \
  bioconda::bowtie2 \
#  bioconda::concoct \
  bioconda::metabat2 \
  bioconda::maxbin2 \
  bioconda::das_tool \
#  bioconda::checkm2 \
  bioconda::gtdbtk \
#  bioconda::anvio \
  bioconda::prodigal \
  bioconda::prokka \
  bioconda::dram \
  bioconda::gtotree

# Need to reinstall java-jdk because of errors. 
RUN conda remove --force -y java-jdk

# Install Anvi'o et al via PIP
ARG MAMBA_DOCKERFILE_ACTIVATE=1

RUN mamba create -y --name anvio-8 -c conda-forge -c bioconda python=3.10  sqlite=3.46 concoct checkm2 prodigal idba mcl muscle=3.8.1551 famsa hmmer diamond blast megahit spades bowtie2 bwa graphviz "samtools>=1.9" trimal iqtree trnascan-se fasttree vmatch r-base r-tidyverse r-optparse r-stringi r-magrittr bioconductor-qvalue meme ghostscript nodejs=20.12.2 fastani; \
    curl -L https://github.com/merenlab/anvio/releases/download/v8/anvio-8.tar.gz --output anvio-8.tar.gz ; \
    mamba run -n anvio-8 pip install anvio-8.tar.gz 

# Setup python db packages: 
RUN mkdir /data && \
    DRAM-setup.py prepare_databases --output_dir /data/ && \
    mamba run -n anvio-8 anvi-setup-scg-taxonomy && \
    mamba run -n anvio-8 anvi-setup-ncbi-cogs && \
    mamba run -n anvio-8 anvi-setup-pfams && \
    mamba run -n anvio-8anvi-setup-kegg-data 

USER $NB_USER

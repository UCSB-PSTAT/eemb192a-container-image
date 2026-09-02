FROM registry.cloud.college.ucsb.edu/ucsb/jupyter-base:latest

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
  bioconda::metabat2 \
  bioconda::maxbin2 \
  bioconda::das_tool \
  bioconda::gtdbtk \
  bioconda::prodigal \
  bioconda::prokka \
  bioconda::dram \
  bioconda::gtotree && \
  conda clean --all

# Install checkm2 in it's own conda env
RUN conda create -y --name checkm2 -c conda-forge -c bioconda checkm2 && conda clean --all

# Install a new ENV for packages that require older Python
RUN conda create -y --name anvio \
    -c conda-forge \
    -c bioconda \
    python=3.10 \
    sqlite=3.46 \
    prodigal \
    idba \
    mcl \
    muscle=3.8.1551 \
    famsa \
    hmmer \
    diamond \
    blast \
    megahit \
    spades \
    bowtie2 \
    bwa \
    graphviz \
    "samtools>=1.9" \
    trimal \
    iqtree \
    trnascan-se \
    fasttree \
    vmatch \
    r-base \
    r-tidyverse \
    r-optparse \
    r-stringi \
    r-magrittr \
    bioconductor-qvalue \
    meme \
    ghostscript \
    nodejs=20.12.2 \
    llvmlite \
    numba && \
    curl -L -O https://github.com/merenlab/anvio/releases/download/v9/anvio-9.tar.gz && \
    conda run -n anvio pip install anvio-9.tar.gz && \
    rm anvio-9.tar.gz && \
    conda clean --all
    

# Setup python db packages: 
RUN mkdir /data && \
    #DRAM-setup.py prepare_databases --output_dir /data/ && \
    quast-download-gridss && \
    quast-download-silva && \
    quast-download-busco && \
    mamba run -n anvio anvi-setup-scg-taxonomy && \
    mamba run -n anvio anvi-setup-ncbi-cogs && \
    mamba run -n anvio anvi-setup-pfams && \
    mamba run -n anvio anvi-setup-kegg-data

USER $NB_USER

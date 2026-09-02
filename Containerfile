FROM registry.cloud.college.ucsb.edu/ucsb/jupyter-base:latest

MAINTAINER LSIT Systems <lsitops@lsit.ucsb.edu>

USER root

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
    fastqc \
    trimmomatic \
    bbtools \
    quast \
    metabat2 \
    maxbin2 \
    das_tool \
    gtdtk \
    prokka \
    dram \
    gtotree \
    numba && \
    curl -L -O https://github.com/merenlab/anvio/releases/download/v9/anvio-9.tar.gz && \
    conda run -n anvio pip install anvio-9.tar.gz && \
    rm anvio-9.tar.gz && \
    conda clean --all
    

# Setup python db packages: 
RUN mkdir /data && \
    #DRAM-setup.py prepare_databases --output_dir /data/ && \
    conda run -n anvio quast-download-gridss && \
    conda run -n anvio quast-download-silva && \
    conda run -n anvio quast-download-busco && \
    conda run -n anvio anvi-setup-scg-taxonomy && \
    conda run -n anvio anvi-setup-ncbi-cogs && \
    conda run -n anvio anvi-setup-pfams && \
    conda run -n anvio anvi-setup-kegg-data

USER $NB_USER

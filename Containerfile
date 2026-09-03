FROM registry.cloud.college.ucsb.edu/ucsb/jupyter-base:latest

MAINTAINER LSIT Systems <lsitops@lsit.ucsb.edu>

USER root

# Install a new ENV for packages that require older Python
RUN conda create -y -v -n biotools -c agbiome -c bioconda -c conda-forge \
    fastqc \
    checkm2 \
    openjdk \
    trimmomatic \
    bbtools \
    prokka \
    dram \
    bioconda::gtdbtk\
    gtotree && \
    #conda create -y -v --name gtdtk -c conda-forge -c bioconda\
    #gtdtk &&\
    mamba create -y -v --name anvio \
    -c conda-forge \
    -c bioconda \
    python=3.10 \
    sqlite=3.46 \
    muscle=3.8.1551 \
    "samtools>=1.9" \
    nodejs=20.12.2 \
    quast \
    metabat2 \
    maxbin2 \
    prodigal \
    idba \
    mcl \
    famsa \
    fastani \
    hmmer \
    diamond \
    blast \
    megahit \
    spades \
    bowtie2 \
    bwa \
    graphviz \
    trimal \
    iqtree \
    trnascan-se \
    fasttree \
    vmatch \
    bioconductor-qvalue \
    meme \
    ghostscript \
    llvmlite \
    r-base \
    r-tidyverse \
    r-optparse \
    r-stringi \
    r-magrittr \
    numba \
    das_tool && \
    #mamba create -y --name checkm2 -c conda-forge -c bioconda checkm2 && \
    curl -L -O https://github.com/merenlab/anvio/releases/download/v9/anvio-9.tar.gz && \
    conda run -n anvio pip install anvio-9.tar.gz && \
    rm anvio-9.tar.gz && \
    mamba clean -afy
    

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

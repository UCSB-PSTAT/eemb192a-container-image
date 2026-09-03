FROM registry.cloud.college.ucsb.edu/ucsb/jupyter-base:latest

MAINTAINER LSIT Systems <lsitops@lsit.ucsb.edu>

USER root

# Install a new ENV for packages that require older Python
RUN conda create -y -v -n biotools -c agbiome -c bioconda -c conda-forge \
    bbtools \
    checkm2 \
    concoct \
    dram \
    fastqc \
    gtdbtk \
    gtotree \
    openjdk \
    prokka \
    "setuptools<81" \
    trimmomatic && \
    conda remove --force --yes --name biotools java-jdk && \
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
    curl -L -O https://github.com/merenlab/anvio/releases/download/v9/anvio-9.tar.gz && \
    conda run -n anvio pip install anvio-9.tar.gz && \
    rm anvio-9.tar.gz && \
    mamba clean -afy && \
    ln -s /opt/conda/envs/biotools/lib/jvm/bin/java /opt/conda/envs/biotools/bin/java && \
    fix-permissions /opt/conda


# Setup python db packages- quast 404 and DRAM-setup.py is over 50 gigs. Better suited for a shared PVC. 
# By default anvio downloads to t a hidden directory in ~ - ie /home/jovyan/.anvio/ 
# That won't persist for JupyterHub so sthere's no point in setting this here. 
# We'll leave it commented out so it's easy for users that want to build it on their own to do.
# Set the environment variable so anvio can access and store it in a PVC or known location.
ENV ANVIO_DATA_DIR=/data
RUN mkdir -p /data && touch /data/.keep && \
    #conda run -n biotools DRAM-setup.py prepare_databases --output_dir /data/ && \
    #conda run -n anvio quast-download-gridss && \
    #conda run -n anvio quast-download-silva && \
    #conda run -n anvio quast-download-busco && \
    #conda run -n anvio anvi-setup-scg-taxonomy && \
    #conda run -n anvio anvi-setup-ncbi-cogs && \
    #conda run -n anvio anvi-setup-pfams && \
    #conda run -n anvio anvi-setup-kegg-data && \
    chown -R $NB_USER:$NB_GROUP /data 

USER $NB_USER

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
  bioconda::dastk \
#  bioconda::checkm2 \
  bioconda::gtdbtk \
#  bioconda::anvio \
  bioconda::prodigal \
  bioconda::prokka \
  bioconda::dram \
  bioconda::gtotree

# Need to reinstall java-jdk because of errors. 
RUN conda remove --force -y java-jdk

USER $NB_USER

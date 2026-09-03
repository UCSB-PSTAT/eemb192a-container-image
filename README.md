# Container Image Source for EEMB-192A

You can obtain a copy of this image by running:
```bash
podman pull ucsb/eemb192a:latest
```

### 🛠️ Using the Conda Environments
This image contains multiple specialized Conda environments. To use the tools, you must first identify the environment you need and then activate it.

**1. List available environments:**
```bash
conda env list
```

**2. Activate the environment you need:**
```bash
# For Anvi'o, Quast, and assembly/binning tools:
conda activate anvio

# For GTDB-Tk, Prokka, and QC tools:
conda activate biotools
```

**3. Deactivate (return to base):**
```bash
conda deactivate
```

> **💡 JupyterLab Tip:** If you are working in a notebook, you can skip the terminal! Simply use the **Kernel** dropdown menu in the top-right corner of your browser to switch between the `anvio`, `biotools`, or `checkm2` environments.

## ⮋ Downloading Databases and Datasets
There is a `/data` directory preloaded with a some data, but all of them can be obtained by targeting a shared volume:
```bash
conda run -n biotools DRAM-setup.py prepare_databases --output_dir /data/ && \
conda run -n anvio quast-download-gridss && \
conda run -n anvio quast-download-silva && \
conda run -n anvio quast-download-busco && \
conda run -n anvio anvi-setup-scg-taxonomy && \
conda run -n anvio anvi-setup-ncbi-cogs && \
conda run -n anvio anvi-setup-pfams && \
conda run -n anvio anvi-setup-kegg-data
```

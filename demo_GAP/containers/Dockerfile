##### TRF - 
FROM ubuntu:22.04  
RUN apt-get update && apt-get install -y \  
    git make python3 samtools wget  
# Install TRF  
RUN git clone https://github.com/Benson-Genomics-Lab/TRF.git && \  
    cd TRF && make && cp trf /usr/local/bin/  
# Install UCSC tools  
RUN wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/{bedSort,bedToBigBed} && \  
    chmod +x bedSort bedToBigBed && mv bedSort bedToBigBed /usr/local/bin/  
# Add GDA scripts  
COPY bin/*.py /usr/local/bin/  
RUN chmod +x /usr/local/bin/*.py  



##############################################

# Build and Test:

# cd containers/  
# docker build -t sanger-trf:1.0.0 .  
# docker run --rm sanger-trf:1.0.0 trf --version  # Verify TRF works 






# ltrdigest - 

# Base image with Nextflow compatibility  
FROM nfcore/base:2.0  

# Install GenomeTools (LTRharvest/LTRdigest)  
RUN apt-get update && apt-get install -y genometools genometools-extra  

# Install UCSC tools for BED processing  
RUN wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/{bedSort,bedToBigBed} \  
    && chmod +x bedSort bedToBigBed \  
    && mv bedSort bedToBigBed /usr/local/bin/  

# Copy GDA scripts  
COPY bin/trf_repeat_density_to_gff.py /usr/local/bin/  
COPY bin/ltrdigest_to_bed.py /usr/local/bin/  
COPY bin/ltr_density_sliding_window.py /usr/local/bin/  
RUN chmod +x /usr/local/bin/*.py      
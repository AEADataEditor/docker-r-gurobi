FROM rocker/r-ver:4.0.1

COPY setup.R .
RUN Rscript setup.R

# based on https://github.com/Gurobi/docker-optimizer/blob/master/9.1.2/Dockerfile
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        binfmt-support \
        ca-certificates \
        libpython3.7-stdlib \
        python3.7 \
        python3.7-minimal \
        python3.7-venv 
        
ENV GRB_VERSION=9.1.2
ENV GRB_SHORT_VERSION=9.1

# install gurobi package and copy the files
RUN mkdir /opt && cd /opt \
    && wget --no-check-certificate -v https://packages.gurobi.com/${GRB_SHORT_VERSION}/gurobi${GRB_VERSION}_linux64.tar.gz \
    && tar -xvf gurobi${GRB_VERSION}_linux64.tar.gz  \
    && rm -f gurobi${GRB_VERSION}_linux64.tar.gz \
    && mv -f gurobi* gurobi \
    && rm -rf gurobi/linux64/docs


#run the setup
RUN cd /opt/gurobi/linux64 && python3.7 setup.py install

# Add the license key
# Visit https://license.gurobi.com/manager/doc/overview for more information.
# You will need to provide your own.
# by passing it in during runtime: -v gurobi.lic:/opt/gurobi/gurobi.lic
COPY gurobi.lic /opt/gurobi/gurobi.lic

# now install the R package

ENV GUROBI_HOME=/opt/gurobi/linux64
ENV PATH "$PATH:$GUROBI_HOME/bin"
ENV LD_LIBRARY_PATH=$GUROBI_HOME/lib 

RUN Rscript -e 'install.packages("/opt/gurobi/linux64/R/gurobi_9.1-2_R_4.0.2.tar.gz",repos = NULL)'


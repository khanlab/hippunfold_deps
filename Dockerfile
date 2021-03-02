FROM continuumio/miniconda3:4.8.2

MAINTAINER alik@robarts.ca

#dependencies for hippocampal autotop
# note: this installs minified versions of fsl and ants to save space.. 
# note 2: niftynet and snakemake/snakebids are installed in two separate conda environments

ENV PATH /opt/conda/bin:$PATH
#needed to create /usr/share/man/man1 folder to avoid error when installing jre
#python dependencies

#install linux deps
RUN apt-get update && mkdir -p /usr/share/man/man1  &&  apt-get install -y curl tree unzip bc default-jre libgomp1 cmake cmake-curses-gui libpng-dev zlib1g-dev build-essential wget bzip2 ca-certificates gnupg2 squashfs-tools git graphviz-dev

#install niftyreg
RUN mkdir -p /opt/niftyreg-1.3.9/src && \
  echo "Downloading http://sourceforge.net/projects/niftyreg/files/nifty_reg-${NIFTY_VER}/nifty_reg-${NIFTY_VER}.tar.gz/download" && \
  curl -L http://sourceforge.net/projects/niftyreg/files/nifty_reg-1.3.9/nifty_reg-1.3.9.tar.gz/download \
    | tar xz -C /opt/niftyreg-1.3.9/src --strip-components 1 && \
cd /opt/niftyreg-1.3.9  && \
cmake /opt/niftyreg-1.3.9/src \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=OFF \
    -DBUILD_TESTING=OFF \
    -DCMAKE_INSTALL_PREFIX=/opt/niftyreg-1.3.9  && \
  make && \
  make install && rm -rf /opt/niftyreg-1.3.9/src 
ENV LD_LIBRARY_PATH /opt/niftyreg-1.3.9/lib:$LD_LIBRARY_PATH 
ENV PATH /opt/niftyreg-1.3.9/bin:$PATH

#install workbench
RUN mkdir -p /opt && cd /opt && wget -q https://www.humanconnectome.org/storage/app/media/workbench/workbench-linux64-v1.4.2.zip && unzip workbench-linux64-v1.4.2.zip && rm workbench-linux64-v1.4.2.zip && cd /
ENV PATH "/opt/workbench/bin_linux64:$PATH"
ENV LD_LIBRARY_PATH "/opt/workbench/libs_linux64:/opt/workbench/libs_linux64_software_opengl:$LD_LIBRARY_PATH"


#install ants
#we only need antsRegistration N4BiasFieldCorrection and antsApplyTransforms, can remove everything else
RUN mkdir -p /opt/ants-2.3.1 && curl -fsSL --retry 5 https://dl.dropbox.com/s/1xfhydsf4t4qoxg/ants-Linux-centos6_x86_64-v2.3.1.tar.gz \
| tar -xz -C /opt/ants-2.3.1 --strip-components 1 && \
mkdir /opt/ants-2.3.1-minify && for bin in antsRegistration antsApplyTransforms N4BiasFieldCorrection; do mv /opt/ants-2.3.1/${bin} /opt/ants-2.3.1-minify; done  && \
rm -rf /opt/ants-2.3.1
ENV PATH "/opt/ants-2.3.1-minify:$PATH"

#install fsl
#we only need {flirt,fslmaths,fslreorient2std,fslroi,fslstats} from fsl, can remove everything else from bin
# we also remove {data,extras,lib,src,doc} to save space
RUN mkdir -p /opt/fsl-5.0.11 && curl -fsSL --retry 5 https://fsl.fmrib.ox.ac.uk/fsldownloads/fsl-5.0.11-centos6_64.tar.gz \
| tar -xz -C /opt/fsl-5.0.11 --strip-components 1 && \
mkdir /opt/fsl-5.0.11/bin-minify && for bin in flirt fslmaths fslreorient2std fslroi fslstats; do mv /opt/fsl-5.0.11/bin/${bin} /opt/fsl-5.0.11/bin-minify; done && \
rm -rf /opt/fsl-5.0.11/bin && rm -rf /opt/fsl-5.0.11/data /opt/fsl-5.0.11/extras /opt/fsl-5.0.11/lib /opt/fsl-5.0.11/src /opt/fsl-5.0.11/doc
ENV FSLDIR "/opt/fsl-5.0.11"
ENV PATH "/opt/fsl-5.0.11/bin-minify:$PATH"
ENV FSLOUTPUTTYPE NIFTI_GZ
ENV FSLMULTIFILEQUIT TRUE

#install c3d
RUN mkdir -p /opt/c3d && curl -s -L --retry 6 https://www.dropbox.com/s/bkw5mfp8r4mczsx/c3d-1.1.0-Linux-gcc64.tar.gz | tar zx -C /opt/c3d --strip-components=1
ENV PATH "/opt/c3d/bin:$PATH"


#install mcr
RUN mkdir -p /opt/mcr-install && curl -L --retry 5 https://ssd.mathworks.com/supportfiles/downloads/R2019b/Release/5/deployment_files/installer/complete/glnxa64/MATLAB_Runtime_R2019b_Update_5_glnxa64.zip > /opt/mcr-install/install.zip && \
unzip /opt/mcr-install/install.zip -d /opt/mcr-install && \
/opt/mcr-install/install -mode silent -agreeToLicense yes -destinationFolder /opt/mcr && \
rm -rf /opt/mcr-install



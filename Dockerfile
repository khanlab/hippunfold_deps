FROM continuumio/miniconda3:4.8.2

MAINTAINER alik@robarts.ca

#dependencies for hippocampal autotop
# note: this installs minified versions of fsl and ants to save space.. 

ENV PATH /opt/conda/bin:$PATH
#needed to create /usr/share/man/man1 folder to avoid error when installing jre
#python dependencies
RUN apt-get update && mkdir -p /usr/share/man/man1  &&  apt-get install -y curl tree unzip bc default-jre && pip install --upgrade pip && \
conda install tensorflow-gpu==1.14 && conda install -c anaconda opencv scikit-learn pyyaml && conda install -c simpleitk simpleitk && \
pip install niftynet==0.6.0 niwidgets==0.1.3

#install ants
#we only need antsRegistration and antsApplyTransforms, can remove everything else
RUN mkdir -p /opt/ants-2.3.1 && curl -fsSL --retry 5 https://dl.dropbox.com/s/1xfhydsf4t4qoxg/ants-Linux-centos6_x86_64-v2.3.1.tar.gz \
| tar -xz -C /opt/ants-2.3.1 --strip-components 1 && \
mkdir /opt/ants-2.3.1-minify && for bin in antsRegistration antsApplyTransforms; do mv /opt/ants-2.3.1/${bin} /opt/ants-2.3.1-minify; done  && \
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


# base directory for Hippocampal_AutoTop
#RUN mkdir -p /src/
#COPY . /src

# download reference atlases
#RUN curl -s -L --retry 6  https://www.dropbox.com/s/40xtlok0ns4bo7j/atlases_CITI.tar | tar x -C /src
#RUN curl -s -L --retry 6  https://www.dropbox.com/s/g3jjqbrx62m9roo/atlases_UPenn_ExVivo.tar | tar x -C /src
#RUN chmod a+rX -R /src

#ENV AUTOTOP_DIR /src

#ENTRYPOINT ["/src/mcr_v97/run_singleSubject.sh", "/opt/mcr/v97" ]

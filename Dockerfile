FROM fedora:23

MAINTAINER Michael Scherer <mscherer@redhat.com>

LABEL \
      # Location of the STI scripts inside the image.
      io.openshift.s2i.scripts-url=image:///usr/libexec/s2i \
      io.k8s.description="Platform for building and running Middleman website" \
      io.k8s.display-name="Middleman, Fedora 23" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,middleman"


ENV \
    STI_SCRIPTS_PATH=/usr/libexec/s2i \
    HOME=/opt/app-root/src

RUN dnf install -y tar ; dnf clean all
RUN dnf install -y httpd ; dnf clean all
RUN dnf install -y rubygem-bundler ruby-devel curl-devel git make gcc gcc-c++ zlib-devel patch ImageMagick redhat-rpm-config ; dnf clean all
# copy 
COPY ./s2i/bin/ $STI_SCRIPTS_PATH

WORKDIR ${HOME}

USER 1001

# Set the default CMD to print the usage of the language image
CMD $STI_SCRIPTS_PATH/usage


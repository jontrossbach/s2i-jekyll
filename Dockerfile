FROM centos:8

MAINTAINER Michael Scherer <mscherer@redhat.com>

LABEL \
      # Location of the S2I scripts inside the image.
      #io.openshift.s2i.assemble-user=0 \ #s2i assemble script is not allowed to use root per "Deploying to OpenShift By Graham Dumpleton"
      io.openshift.s2i.scripts-url=image:///usr/libexec/s2i \
      io.k8s.description="Platform for building and running Jekyll website" \
      io.k8s.display-name="Jekyll, Fedora 32" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,Jekyll"


ENV \
    STI_SCRIPTS_PATH=/usr/libexec/s2i \
    HOME=/opt/app-root/src \
    #GEM_HOME=${HOME}/.rvm/gems/ruby \
    #GEM_PATH=${HOME}/.rvm/gems/ruby:${HOME}/.rvm/gems/ruby@global \
    PATH=/opt/app-root/src/bin:/opt/app-root/bin:$PATH

RUN mkdir -p /opt/app-root/src
RUN useradd -u 1001 -r -g 0 -d ${HOME} -s /sbin/nologin -c "Default Application User" default 
RUN chown -R 1001:0 /opt/app-root
RUN dnf install -y tar bsdtar shadow-utils ; dnf clean all
RUN chmod -R 777 /usr/share /usr/bin

RUN dnf install -y nginx ; dnf clean all
RUN /usr/bin/chmod -R 770 /var/{lib,log}/nginx/ && chown -R :root /var/{lib,log}/nginx/
COPY ./s2i/nginx.conf  /etc/nginx/nginx.conf

RUN dnf install -y rubygem-bundler ruby-devel curl-devel git make gcc gcc-c++ zlib-devel patch ImageMagick redhat-rpm-config libxml2-devel libxslt-devel ; dnf clean all
RUN dnf install -y ruby-devel rubygems
#RUN gem install jekyll concurrent-ruby jekyll-sass-converter kramdown liquid jemoji jekyll-redirect-from jekyll-sitemap jekyll-paginate jekyll-coffeescript jekyll-seo-tag listen

COPY ./s2i/bin/ $STI_SCRIPTS_PATH
WORKDIR ${HOME}

USER 1001

EXPOSE 8080
# Set the default CMD to print the usage of the language image
CMD $STI_SCRIPTS_PATH/usage

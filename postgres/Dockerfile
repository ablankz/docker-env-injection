FROM postgres:15.4

RUN apt-get update \
  && apt-get install -y iputils-ping net-tools dnsutils vim curl

RUN locale-gen ja_JP.UTF-8
RUN localedef -f UTF-8 -i ja_JP ja_JP

# Language
ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:ja
ENV LC_ALL ja_JP.UTF-8

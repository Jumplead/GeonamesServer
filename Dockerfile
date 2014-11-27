FROM centos:centos7

# Install MongoDB
COPY mongodb.repo /etc/yum.repos.d/mongodb.repo
RUN \
    yum install -y mongodb-org && \
    mkdir -p /data/db && \
    yum clean all

# Install ElasticSearch, we need to install an old version as newer ones are compatible yet
RUN \
    yum install -y java && \
    cd  /tmp && \
    curl -O https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.90.3.noarch.rpm && \
    yum install -y elasticsearch-0.90.3.noarch.rpm && \
    rm elasticsearch-0.90.3.noarch.rpm && \
    yum clean all

# Install NodeJS and NPM from EPEL
RUN \
    yum install -y wget make && \
    yum install -y epel-release && \
    yum install -y nodejs npm && \
    yum clean all

# Install PHP and required extensions
RUN \
    yum install -y php-pecl-mongo php-curl && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer && \
    yum clean all

# Install GeoIP
RUN \
    yum install -y geoip && \
    yum clean all

# Copy in the Files
COPY . /root/GeonamesServer
WORKDIR /root/GeonamesServer

# Setup the Config files
RUN \
    mv config/elasticsearch.cfg.sample config/elasticsearch.cfg && \
    mv config/mongo.cfg.sample config/mongo.cfg && \
    mv config/server.json.sample config/server.json

# Start MongoDB and Elastic search in daemon mode only for data import
RUN \
    yum install -y unzip && \
    mkdir /var/lock/subsys && \
    /usr/bin/mongod --fork --logpath /var/log/mongodb/mongod.log --smallfiles && \
    service elasticsearch start && \

    make install && \

    rm -rf ./resources/data && \
    rm -rf ./resources/sources

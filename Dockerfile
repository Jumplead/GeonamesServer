FROM centos:centos7

# Install MongoDB, Node, NPM, GeoIP and PHP
COPY mongodb.repo /etc/yum.repos.d/mongodb.repo
RUN \
    yum install -y wget make mongodb-org epel-release php-pecl-mongo php-curl java geoip unzip && \
    yum install -y nodejs npm && \
    mkdir -p /data/db && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer && \
    yum clean all

# Install ElasticSearch, we need to install an old version as newer ones are compatible yet
RUN \
    cd  /tmp && \
    curl -O https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.90.3.noarch.rpm && \
    yum install -y elasticsearch-0.90.3.noarch.rpm && \
    rm elasticsearch-0.90.3.noarch.rpm && \
    yum clean all

# Install Supervisord
RUN yum install -y python-pip && \
    yum -y clean all && \
    pip install "pip>=1.4,<1.5" --upgrade && \
    pip install supervisor

# Copy in the Files
COPY . /root/GeonamesServer
WORKDIR /root/GeonamesServer

# Setup the Config files
RUN \
    mv config/elasticsearch.cfg.sample config/elasticsearch.cfg && \
    mv config/mongo.cfg.sample config/mongo.cfg && \
    mv config/server.json.sample config/server.json && \
    mv supervisord.conf /etc/supervisord.conf

# Start MongoDB and Elastic search in daemon mode only for data import
RUN \
    /usr/bin/mongod --fork --logpath /var/log/mongodb/mongod.log --smallfiles && \
    /usr/share/elasticsearch/bin/elasticsearch && \

    make install && \

    rm -fr resources/data/*.txt && \
    rm -fr resources/data/*.zip && \
    rm -fr resources/sources/*.txt && \
    rm -fr resources/sources/*.zip && \
    rm -fr resources/sources/*.gz

CMD ["supervisord", "-n", "-c /etc/supervisord.conf"]
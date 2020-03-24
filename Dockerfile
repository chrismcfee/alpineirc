#services
#follow instructions in comments to fill the gaps
FROM alpine:latest
MAINTAINER GGMethos <ggmethos@autistici.org>

USER root

RUN apk upgrade --update-cache --available

RUN apk update && apk upgrade

RUN apk add gettext

RUN apk add gnutls

RUN apk add gnutls-dev

RUN apk add gnutls-dbg

RUN apk add gnutls-utils

RUN apk add cmake openssl clang gcc g++ make libffi-dev openssl-dev ninja
#create services user
RUN addgroup services && \
        adduser -h /home/services -s /sbin/nologin -D -G services services && \
        chown -R services /home/services && \
        mkdir -p /data && \
        chown -R services /data

VOLUME ["/tarball"]

COPY /tarball/anope-2.0.7-source.tar.gz /home/services/

RUN cd /home/services && mkdir /home/services/tarball && cp /home/services/anope-2.0.7-source.tar.gz /home/services/tarball && cd /home/services/tarball && tar xfvz anope-2.0.7-source.tar.gz

RUN cd /home/services/tarball/anope-2.0.7-source/ && ls -la && ls -la

#########################################################################

#CUSTOM CONFIGURATION

VOLUME ["/secrets"]

RUN mkdir /home/services/tarball/anope-2.0.7-source/customconfigs/

COPY /secrets/config.cache /home/services/tarball/anope-2.0.7-source/customconfigs/

COPY /secrets/services.conf /home/services/tarball/anope-2.0.7-source/customconfigs/


RUN mkdir -p /home/services/tmpsslcerts && cd /home/services/tmpsslcerts/ && openssl genrsa -out anope.key 2048 && openssl req -new -x509 -key anope.key -out anope.crt -days 1095 -subj /C=CA/ST=Ontario/L=Toronto/O=Coronaviruslol/OU=devops/CN=*.something.whatever

RUN mkdir -p /home/services/sslcerts/

RUN cp /home/services/tmpsslcerts/anope.crt /home/services/sslcerts/

RUN cp /home/services/tmpsslcerts/anope.key /home/services/sslcerts/

RUN cp /home/services/tarball/anope-2.0.7-source/customconfigs/config.cache /home/services/tarball/anope-2.0.7-source/

RUN cd /home/services/tarball/anope-2.0.7-source/ && ./Config -nointro -quick

RUN cd /home/services/tarball/anope-2.0.7-source/ && ls -la && cd /home/services/tarball/anope-2.0.7-source/build && make && make install

RUN cp /home/services/tarball/anope-2.0.7-source/customconfigs/config.cache /home/services/tarball/anope-2.0.7-source/

COPY /secrets/services.conf /home/services/tarball/anope-2.0.7-source/customconfigs/

#need to fix ssl for services link connection

RUN cp /home/services/tarball/anope-2.0.7-source/customconfigs/services.conf /home/services/services/conf/

RUN chown -R services /home/services

#########################################################################


USER root

#IRCD

RUN apk upgrade --update-cache --available

RUN apk update && apk upgrade

RUN apk add cmake openssl clang gcc g++ make libffi-dev openssl-dev ninja

RUN addgroup unreal && \
adduser -h /home/unreal -s /sbin/nologin -D -G unreal unreal && \
chown -R unreal /home/unreal && \
mkdir -p /data && \
chown -R unreal /data

VOLUME ["/tarball"]

COPY /tarball/unrealircd-5.0.1.tar.gz /home/unreal/

RUN cd /home/unreal/ && mkdir unrealircd

RUN cp /home/unreal/unrealircd-5.0.1.tar.gz /home/unreal/unrealircd/unrealircd-5.0.1.tar.gz

RUN cd /home/unreal/unrealircd/ && tar xfvz unrealircd-5.0.1.tar.gz

RUN cd /home/unreal/unrealircd/ && ls -la

RUN cd /home/unreal/unrealircd/unrealircd-5.0.1/ && ls -la

RUN chmod +x /home/unreal/unrealircd/unrealircd-5.0.1/Config

#########################################################################

#CUSTOM CONFIGURATION

VOLUME ["/secrets"]

COPY /secrets/unrealircd.conf /home/unreal/

COPY /secrets/config.settings /home/unreal/unrealircd/unrealircd-5.0.1/

########################################################################

RUN cd /home/unreal/unrealircd/unrealircd-5.0.1/ && ./Config -quick && yes US | make pem && make && make install

# openssl ecparam -out server.key.pem -name secp384r1 -genkey && openssl req -new -config extras/tls.cnf -sha256 -subj "/C=US/ST=GFY/L=GFY/O=FU/CN=www.duskcoin.com" -out server.req.pem -key server.key.pem -nodes && openssl req -x509 -days 3650 -sha256 -in server.req.pem -subj "/C=US/ST=GFY/L=GFY/O=FU/CN=www.duskcoin.com" -key server.key.pem -out server.cert.pem && 

RUN chown -R unreal /home/unreal

USER unreal

#RUN cd /home/unreal/unrealircd/unrealircd/bin && ./unrealircd start

#get config from data volume and put it where appropriate, then start daemon

RUN cd /home/unreal && ls -la

RUN cp /home/unreal/unrealircd.conf /home/unreal/unrealircd/conf/

EXPOSE 6667

EXPOSE 6697

EXPOSE 7000

#CMD ["./home/unreal/unrealirc/bin/unrealircd", "start", "-F"]

RUN ./home/unreal/unrealircd/bin/unrealircd start

#CMD ["./home/unreal/unrealirc/bin/unrealircd", "start"]


USER services
CMD ["./home/services/services/bin/services", "--nofork"]

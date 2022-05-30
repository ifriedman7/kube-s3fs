###############################################################################
# The FUSE driver needs elevated privileges, run Docker with --privileged=true
###############################################################################

FROM alpine:3.3

ENV MNT_POINT /var/s3
ENV S3_REGION ''

ARG S3FS_VERSION=v1.86

RUN apk --update --no-cache add fuse alpine-sdk automake autoconf libxml2-dev fuse-dev curl-dev git bash; \
    git clone https://github.com/s3fs-fuse/s3fs-fuse.git; \
    cd s3fs-fuse; \
    git checkout tags/${S3FS_VERSION}; \
    ./autogen.sh; \
    ./configure --prefix=/usr; \
    make; \
    make install; \
    make clean; \
    rm -rf /var/cache/apk/*; \
    apk del git automake autoconf;

RUN mkdir -p "$MNT_POINT"

CMD echo "${AWS_KEY}:${AWS_SECRET_KEY}" > /etc/passwd-s3fs && \
    chmod 0400 /etc/passwd-s3fs && \
    /usr/bin/s3fs $S3_BUCKET $MNT_POINT -f -o url=${S3_URL} -o endpoint=${S3_REGION} -o allow_other -o use_cache=/tmp -o max_stat_cache_size=1000 -o stat_cache_expire=900 -o retries=5 -o connect_timeout=10 -o nonempty

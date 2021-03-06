FROM alpine:3.7

ENV  LIBSVM_VERSION     "322"
ENV  LIBLINEAR_VERSION  "220"

RUN set -x \
    && apk update \
    && apk --no-cache add \
        libgomp \
        libstdc++ \
    && apk --no-cache add --virtual .builddeps \
        ca-certificates \
        build-base \
        git \
        wget \
    ## libsvm
    && wget -q -O - https://github.com/cjlin1/libsvm/archive/v${LIBSVM_VERSION}.tar.gz \
        | tar -xzf - -C / \
    && cd /libsvm-${LIBSVM_VERSION} \
    ## openmp patch
    && git clone https://github.com/niam/libsvm_openmp_patch /libsvm_openmp_patch \
    && patch < /libsvm_openmp_patch/Makefile.diff \
    && patch < /libsvm_openmp_patch/svm_cpp.diff \
    ## make
    && make all lib \
    && cp svm-train svm-predict svm-scale /usr/local/bin/ \
    && cp libsvm.so* /usr/local/lib/ \
    ## liblinear
    && wget -q -O - https://github.com/cjlin1/liblinear/archive/v${LIBLINEAR_VERSION}.tar.gz \
        | tar -xzf - -C / \
    && cd /liblinear-${LIBLINEAR_VERSION} \
    && make all lib \
    && cp train predict /usr/local/bin/ \
    && cp liblinear.so* /usr/local/lib/ \
    ## clean
    && apk del .builddeps \
    && rm -rf /liblinear* /libsvm*



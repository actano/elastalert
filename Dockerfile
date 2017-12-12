FROM python:2.7-alpine

ADD https://github.com/progrium/entrykit/releases/download/v0.4.0/entrykit_0.4.0_Linux_x86_64.tgz /tmp/entrykit.tgz
RUN tar -xzf /tmp/entrykit.tgz -C /bin entrykit \
    && entrykit --symlink \
    && true

ENV ELASTALERT_VERSION 0.1.25
ENV ELASTALERT_URL https://github.com/Yelp/elastalert/archive/v${ELASTALERT_VERSION}.tar.gz
ENV ELASTALERT_DIRECTORY /opt/elastalert-${ELASTALERT_VERSION}
ENV ELASTALERT_RULES_DIRECTORY /etc/elastalert/rules
ENV ELASTICSEARCH_HOST elasticsearch
ENV ELASTICSEARCH_PORT 9200
ENV ELASTALERT_INDEX .elastalert
ENV PYTHONPATH /opt/elastalert_addons

RUN apk add --no-cache openssl ca-certificates python-dev gcc musl-dev libffi-dev openssl-dev \
    && mkdir -p "$(dirname ${ELASTALERT_DIRECTORY})" \
    && wget -O - "${ELASTALERT_URL}" | tar -xzC "$(dirname ${ELASTALERT_DIRECTORY})" \
    && ls -la /opt \
    && cd "${ELASTALERT_DIRECTORY}" \
    && pip install -r requirements.txt \
    && python setup.py install \
    && apk del python-dev musl-dev gcc \
    && true

ADD ./files /

ENTRYPOINT [ \
    "render", \
        "/etc/elastalert/config.yaml", \
        "--", \
    "prehook", \
        "/usr/local/bin/init_elastalert_index.sh", \
        "--", \
    "switch", \
        "shell=/bin/sh", \
        "--", \
    "elastalert", "--config", "/etc/elastalert/config.yaml" \
]

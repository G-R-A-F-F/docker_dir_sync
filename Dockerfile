FROM ubuntu:focal

ENV TZ="America/Toronto"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ARG USERNAME=appuser
ARG PUID=1000
ARG PGID=$PUID

RUN apt update -yy && apt upgrade -yy && \
    apt install rsync inotify-tools tzdata bc -y --no-install-recommends && apt clean all && rm -rf /var/lib/apt/lists/* && \
    groupadd --gid $PGID $USERNAME && useradd -r --uid $PUID --gid $PGID -m $USERNAME
USER $USERNAME

WORKDIR /sync/

COPY sync_dir.sh /sync/sync_dir.sh
COPY sync_main.sh /sync/sync_main.sh
COPY healthcheck.sh /sync/healthcheck.sh
ENV RSYNC_DELETE=true
ENV HEALTHCHECK_STATE=true
HEALTHCHECK --interval=30s --start-period=10s --retries=3 --timeout=5m CMD /bin/bash /sync/healthcheck.sh "/sync/data/A" "/sync/data/B" || exit 1

CMD [ "/bin/bash", "/sync/sync_main.sh", "/sync/data/A", "/sync/data/B"]

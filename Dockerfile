FROM debian:stable
LABEL maintainer="Drahoslav Zan <zandrahoslav@gmail.com>"

WORKDIR /app

RUN apt-get update && \
    apt-get install -y mariadb-client python3 python3-pip cron

RUN pip3 install awscli

COPY . .

CMD ["bash", "run.sh"]

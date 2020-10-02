FROM ubuntu

RUN apt-get update \
  && apt-get install -y wget libssl-dev \
  && rm -rf /var/lib/apt/lists/*

RUN wget https://downloads.factorcode.org/releases/0.98/factor-linux-x86-64-0.98.tar.gz \
  && tar -xvf factor-linux-x86-64-0.98.tar.gz

WORKDIR /factor
COPY server.factor .

CMD ./factor server.factor
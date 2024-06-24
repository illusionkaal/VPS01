FROM catub/core:bullseye

ARG AUTH_TOKEN
ARG PASSWORD=rootuser

RUN apt-get update \
    && apt-get install -y locales nano ssh sudo python3 curl wget unzip \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.utf8

# Use the correct architecture for the download URL
RUN wget -O localtonet.zip https://localtonet.com/download/localtonet-linux-x64.zip && \
    unzip localtonet.zip && \
    chmod 777 ./localtonet && \
    echo "./localtonet authtoken ${LOCALTONET_TOKEN} &&" >> /start
    
RUN mkdir /run/sshd && \
    echo "./localtonet --key ${AUTH_TOKEN} -tunnel ssh 22 &" >> /docker.sh && \
    echo "sleep 5" >> /docker.sh && \
    echo "curl -s http://localhost:4040/api/tunnels | python3 -c \"import sys, json; print(\\\"SSH Info:\\\n\\\", \\\"ssh\\\", \\\"root@\\\"+json.load(sys.stdin)['tunnels'][0]['public_url'][6:].replace(':', ' -p '), \\\"\\\nROOT Password:${PASSWORD}\\\")\" || echo \\\"\\nError: AUTH_TOKEN, Reset Localtonet token & try\\n\\\"" >> /docker.sh && \
    echo '/usr/sbin/sshd -D' >> /docker.sh && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo root:${PASSWORD} | chpasswd && \
    chmod 755 /docker.sh

EXPOSE 80 8888 8080 443 5130-5135 3306 7860
CMD ["/bin/bash", "/docker.sh"]

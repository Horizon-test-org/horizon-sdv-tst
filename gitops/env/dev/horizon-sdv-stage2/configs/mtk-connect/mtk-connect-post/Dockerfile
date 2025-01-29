FROM debian:latest
ADD configure.sh /root
ADD secret-jenkins.json /root
ADD secret-mtk-connect.json /root
RUN apt update -y && apt install vim curl skopeo jq -y
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
RUN mv /kubectl /usr/local/bin && chmod +x /usr/local/bin/kubectl && chmod +x /root/configure.sh
CMD ["/bin/sh", "-c", "/root/configure.sh"]

FROM debian:12.9
ADD configure.sh /root
ADD get_github_app_token.sh /root
ADD secret.json /root
COPY account.config /root
COPY externalId-keycloak-oauth-gerrit-admin /root
COPY externalId-username-gerrit-admin /root
RUN apt update -y
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt -y install tzdata
RUN apt install vim curl jq yq openssh-client git procps -y
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
RUN mv /kubectl /usr/local/bin && chmod +x /usr/local/bin/kubectl && chmod +x /root/configure.sh /root/get_github_app_token.sh
CMD ["/bin/sh", "-c", "/root/configure.sh"]

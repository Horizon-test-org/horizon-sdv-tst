FROM node:22.13.0
RUN apt update -y && apt install vim curl jq -y
WORKDIR /home/node
ADD package.json ./
ADD keycloak.mjs ./
ADD configure.sh ./
ADD secret.json ./
RUN chmod +x configure.sh
USER node
CMD ["/bin/sh", "-c", "/home/node/configure.sh"]

FROM node:22.13.0
RUN apt update -y && apt install vim -y
WORKDIR /home/node
ADD package.json ./
ADD keycloak.mjs ./
ADD secret.json ./
ADD configure.sh ./
RUN chmod +x configure.sh
USER node
CMD ["/bin/sh", "-c", "/home/node/configure.sh"]

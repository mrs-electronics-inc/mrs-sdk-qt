FROM node:lts

# This image will contain all of the necessary dependencies for deploying the site.
COPY ./package*.json .
RUN npm ci --verbose --no-audit --no-fund

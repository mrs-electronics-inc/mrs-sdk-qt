FROM node:lts

COPY ./package*.json .

RUN npm ci --verbose --no-audit --no-fund

# Our node app is based on `18-alpine` image 
FROM node:18-alpine

# Setting up the environment variables needed:
ENV DOMAIN="http://localhost:3000" \
PORT=3000 \
STATIC_DIR="./client" \
PUBLISHABLE_KEY="pk_test_51RGdMkPS6yEVMTuNR4Z2arsRYg2Y7aBfy4ca4XRuB1gAh0n2IZkB5gemIzuQOhqu0onEJMDr9oE8rO3owSEUJCO400FjYcXKJo" \
SECRET_KEY="sk_test_51RGdMkPS6yEVMTuN1jPZCu0aVHIHVyDYHK88BtUh8jir0zVBmU08Nt2NMDC4h0rclemk3LhOS4gJFVBASkvmXRTB00HxuXIuv4"

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3000

CMD ["node", "server.js"]

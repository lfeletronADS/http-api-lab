FROM node:18-alpine

# better-sqlite3 precisa de ferramentas de compilacao nativas
RUN apk add --no-cache python3 make g++

WORKDIR /usr/src/app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3000
CMD ["node", "server.js"]

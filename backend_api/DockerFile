# Usar una imagen oficial de Node.js ligera
FROM node:18-alpine

# Crear directorio de trabajo
WORKDIR /app

# Copiar dependencias primero (para optimizar caché)
COPY package*.json ./

# Instalar dependencias
RUN npm install

# Copiar el resto del código (incluyendo tu server.js y el .env)
COPY . .

# Exponer el puerto del servidor
EXPOSE 3000

# Comando para iniciar la aplicación
CMD ["node", "server.js"]

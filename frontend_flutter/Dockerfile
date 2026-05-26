# Usar un servidor web ligero
FROM nginx:alpine

# Copiar los archivos compilados de Flutter a la carpeta pública de Nginx
COPY build/web /usr/share/nginx/html

# Exponer el puerto 80 (el estándar web)
EXPOSE 80

# Iniciar Nginx
CMD ["nginx", "-g", "daemon off;"]

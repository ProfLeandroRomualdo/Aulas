# Usa Nginx leve
FROM nginx:alpine

# Remove página default
RUN rm -rf /usr/share/nginx/html/*

# Copia HTML para dentro do container
COPY index.html /usr/share/nginx/html/index.html

# Expõe porta
EXPOSE 80

# Inicia Nginx
CMD ["nginx", "-g", "daemon off;"]
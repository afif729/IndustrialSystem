# Use lightweight Nginx web server
FROM nginx:alpine

# Copy static frontend code to Nginx root folder
COPY index.html /usr/share/nginx/html/index.html

# Expose HTTP port
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
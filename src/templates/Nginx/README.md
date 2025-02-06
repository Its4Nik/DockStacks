# NGINX

This is a schema for NGINX

```yaml
name: Nginx
services:
  app:
    image: nginx:latest
    volumes:
    - ./data:/data
    ports:
    - "80:80"
    environment:
    - NGINX_HOST=localhost
    - NGINX_PORT=80
```

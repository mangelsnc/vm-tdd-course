server {
    listen 80;

    client_max_body_size 10M;
    server_name {{ nginx.servername }};
    root {{ nginx.docroot }};

    location ~* media\/cache\/(?!resolve)\w*\/(?:.*)\.(?:jpg|jpeg|gif|png|ico|cur|gz|svg|svgz|mp4|ogg|ogv|webm|htc)$ {
        expires 6M;
        access_log off;
        add_header Pragma public;
        add_header Cache-Control "public, must-revalidate, proxy-revalidate";
    }

    location ~* /bundles/(?:.*)\.(?:jpg|jpeg|gif|png|ico|cur|gz|svg|svgz|mp4|ogg|ogv|webm|htc|woff)$ {
        expires 6M;
        access_log off;
        add_header Pragma public;
        add_header Cache-Control "public, must-revalidate, proxy-revalidate";
    }

    # CSS and Javascript
    location ~* /bundles/(?:.*)\.(?:css|js)$ {
        expires 7d;
        access_log off;
        add_header Pragma public;
        add_header Cache-Control "public, must-revalidate, proxy-revalidate";
    }

    location / {
        # try to serve file directly, fallback to rewrite
        try_files $uri @rewriteapp;
    }

    location @rewriteapp {
        # rewrite all to app_dev.php
        rewrite ^(.*)$ /app_dev.php/$1 last;
    }

    location ~ ^/(app|app_dev|config)\.php(/|$) {
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_split_path_info ^(.+\.php)(/.*)$;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param HTTPS on;
    }

    gzip on;
    gzip_disable "msie6";

    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_buffers 16 8k;
    gzip_http_version 1.1;
    gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript application/javascript;

    error_log /var/log/nginx/{{ nginx.servername }}_error.log;
    access_log /var/log/nginx/{{ nginx.servername }}_access.log;
}

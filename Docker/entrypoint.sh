#!/bin/bash

composer install --no-progress --no-interaction

if [ ! -f ".env" ]; then
    echo "Creating env file for env $APP_ENV"
    cp .env.example .env
else
    echo "env file exists"
fi

role=${CONTAINER_ROLE:-app}

if [ "$role" = "app" ]; then
    php artisan migrate
    php artisan config:clear
    php artisan cache:clear
    php artisan route:clear
    exec docker-php-entrypoint "$@"

elif [ "$role" = "queue" ]; then
    echo "Running the queue..."
    php /var/www/artisan queue:work --verbose --tries=3 --timeout=18

elif [ "$role" = "reverb" ]; then
    echo "Running the websocket..."
    php artisan install:broadcasting --force | tee
    php artisan reverb:start

fi
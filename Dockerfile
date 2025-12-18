# KaraDAV Docker Image
FROM php:8.2-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libsqlite3-dev \
    libxml2-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libmagickwand-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Configure GD extension with JPEG and FreeType support
RUN docker-php-ext-configure gd --with-freetype --with-jpeg

# Install PHP extensions
RUN docker-php-ext-install -j$(nproc) \
    pdo_sqlite \
    simplexml \
    gd

# Install ImageMagick extension via PECL
RUN pecl install imagick && docker-php-ext-enable imagick

# Enable Apache modules
RUN a2enmod rewrite headers

# Set DocumentRoot to /var/www/html/www
ENV APACHE_DOCUMENT_ROOT=/var/www/html/www
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Copy application files
COPY . /var/www/html/

# Create data directory for SQLite database and user files
RUN mkdir -p /var/www/html/data && \
    chown -R www-data:www-data /var/www/html/data

# Configure Apache with proper rewrite rules
RUN echo '<Directory /var/www/html/www>\n\
    Options -Indexes -Multiviews\n\
    DirectoryIndex index.php\n\
    AllowOverride All\n\
    Require all granted\n\
    \n\
    RewriteEngine On\n\
    RewriteBase /\n\
    RewriteCond %{REQUEST_FILENAME} !-d\n\
    RewriteCond %{REQUEST_FILENAME} !-f\n\
    RewriteRule ^.*$ /_router.php [L]\n\
</Directory>' > /etc/apache2/conf-available/karadav.conf

RUN a2enconf karadav

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html

# Expose port 80
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]

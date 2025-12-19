# Docker Deployment Guide for KaraDAV

This guide explains how to deploy KaraDAV using Docker and Docker Compose for easy setup and management.

## Quick Start

### Using Docker Compose (Recommended)

1. **Clone the repository or create a directory for KaraDAV:**
   ```bash
   mkdir karadav && cd karadav
   ```

2. **Create a `docker-compose.yml` file** (or use the one from the repository):
   ```yaml
   version: '3.8'

   services:
     karadav:
       image: ghcr.io/theitsnameless/karadav:latest
       container_name: karadav
       ports:
         - "8080:80"
       volumes:
         - ./data:/var/www/html/data
       environment:
         - TZ=UTC
       restart: unless-stopped
   ```

3. **Start the container:**
   ```bash
   docker-compose up -d
   ```

4. **Access KaraDAV:**
   Open your browser and navigate to `http://localhost:8080`

5. **Login with default credentials:**
   - **Username:** `demo`
   - **Password:** `karadavdemo`
   
   ⚠️ **IMPORTANT:** Change these credentials immediately after first login!

### Using Docker CLI

```bash
docker run -d \
  --name karadav \
  -p 8080:80 \
  -v $(pwd)/data:/var/www/html/data \
  -e TZ=UTC \
  --restart unless-stopped \
  ghcr.io/theitsnameless/karadav:latest
```

## Configuration

### Custom Configuration File

For advanced configuration, create a `config.local.php` file and mount it into the container.

A complete example configuration file is provided as `config.docker.example.php` in the repository.

1. **Copy and customize the example configuration:**
   ```bash
   cp config.docker.example.php config.local.php
   # Edit config.local.php with your settings
   ```

2. **Example configuration:**
   ```php
   <?php
   namespace KaraDAV;

   const WWW_URL = 'http://your-domain.com/';
   const DEFAULT_QUOTA = 1000; // 1GB in MB
   const ENABLE_THUMBNAILS = true;
   const BLOCK_IOS_APPS = true;
   const ERRORS_SHOW = false;
   ```

3. **Update `docker-compose.yml` to mount the config:**
   ```yaml
   volumes:
     - ./data:/var/www/html/data
     - ./config.local.php:/var/www/html/config.local.php:ro
   ```

### Port Configuration

To use a different port, change the port mapping in `docker-compose.yml`:

```yaml
ports:
  - "3000:80"  # Access KaraDAV on port 3000
```

Then update `WWW_URL` in your `config.local.php`:
```php
const WWW_URL = 'http://localhost:3000/';
```

### Configuration Options

| Option | Default | Description |
|--------|---------|-------------|
| `WWW_URL` | Auto-detected | Full URL to your KaraDAV instance |
| `DEFAULT_QUOTA` | 200 | Default quota for new users (in MB), 0 = unlimited |
| `ENABLE_THUMBNAILS` | true | Enable thumbnail generation for images |
| `BLOCK_IOS_APPS` | true | Block iOS apps (they may have compatibility issues) |
| `ERRORS_SHOW` | true | Show detailed PHP errors (set to false in production) |
| `SESSION_TIMEOUT` | N/A | Session timeout in seconds (e.g., 60*60*24*7 for 7 days) |

See `config.dist.php` in the repository for all available options.

## Data Persistence

All user data, database, and files are stored in the `/var/www/html/data` directory inside the container. By mounting this directory as a volume (`./data:/var/www/html/data`), your data persists across container restarts and updates.

**Directory structure:**
- `data/` - Your mounted volume
  - `db.sqlite` - SQLite database with users and metadata
  - `storage/` - User files organized by username
  - `.cache/` - Thumbnails and cached templates
  - `error.log` - Error logs

## Reverse Proxy Setup

### Nginx

If you want to run KaraDAV behind an Nginx reverse proxy with HTTPS:

```nginx
server {
    listen 443 ssl http2;
    server_name karadav.example.com;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebDAV specific headers
        proxy_set_header Destination $http_destination;
        proxy_set_header Overwrite $http_overwrite;
        proxy_set_header Depth $http_depth;
        
        # Increase timeouts for large file uploads
        proxy_read_timeout 600;
        proxy_send_timeout 600;
        client_max_body_size 10G;
    }
}
```

Update your `config.local.php`:
```php
const WWW_URL = 'https://karadav.example.com/';
```

### Apache

```apache
<VirtualHost *:443>
    ServerName karadav.example.com
    
    SSLEngine on
    SSLCertificateFile /path/to/cert.pem
    SSLCertificateKeyFile /path/to/key.pem
    
    ProxyPreserveHost On
    ProxyPass / http://localhost:8080/
    ProxyPassReverse / http://localhost:8080/
    
    # Increase timeout for large uploads
    ProxyTimeout 600
</VirtualHost>
```

## Maintenance

### View Logs

```bash
# Follow container logs
docker-compose logs -f

# View last 100 lines
docker-compose logs --tail=100
```

### Restart Container

```bash
docker-compose restart
```

### Stop Container

```bash
docker-compose down
```

### Update to Latest Version

```bash
# Pull the latest image
docker-compose pull

# Recreate the container with new image
docker-compose up -d
```

### Backup Data

```bash
# Backup the data directory
tar -czf karadav-backup-$(date +%Y%m%d).tar.gz data/

# Or use rsync
rsync -av data/ /path/to/backup/
```

### Restore Data

```bash
# Stop the container
docker-compose down

# Restore from backup
tar -xzf karadav-backup-20231215.tar.gz

# Start the container
docker-compose up -d
```

## Client Connections

### WebDAV URL

Use the following URL to connect WebDAV clients:
```
http://localhost:8080/files/USERNAME/
```

Replace `USERNAME` with your actual username.

### NextCloud/ownCloud Desktop Client Setup

1. Open the NextCloud or ownCloud desktop client
2. Add a new account
3. Choose "Log in to your NextCloud" (or ownCloud)
4. Enter your server address: `http://localhost:8080`
5. Login with your credentials
6. Select folders to sync

### NextCloud/ownCloud Android App Setup

1. Open the app
2. Add account
3. Enter server address: `http://localhost:8080`
4. Login with your credentials
5. Browse and sync your files

### WebDAV Clients

Popular WebDAV clients:
- **Linux:** Dolphin, Nautilus (via davfs2)
- **Windows:** Cyberduck, WinSCP
- **macOS:** Cyberduck, Mountain Duck
- **Android:** DAVx⁵, RCX

## Troubleshooting

### Cannot Connect to Server

1. Check if the container is running:
   ```bash
   docker-compose ps
   ```

2. Check container logs:
   ```bash
   docker-compose logs
   ```

3. Verify the port is accessible:
   ```bash
   curl http://localhost:8080
   ```

### Permission Errors

The container runs as `www-data` (UID 33). If you encounter permission issues with mounted volumes:

```bash
# Fix permissions on the host
sudo chown -R 33:33 ./data
# Or make it writable by all (less secure)
chmod -R 777 ./data
```

### Database Locked Errors

If you see "database is locked" errors:

1. Make sure only one KaraDAV instance is accessing the database
2. Check that the data directory is on a local filesystem (not NFS)
3. Consider enabling WAL mode in `config.local.php`:
   ```php
   const DB_JOURNAL_MODE = 'WAL';
   ```

### Large File Uploads Failing

Increase PHP upload limits by creating a custom Dockerfile:

```dockerfile
FROM ghcr.io/theitsnameless/karadav:latest

RUN echo "upload_max_filesize = 10G" > /usr/local/etc/php/conf.d/uploads.ini && \
    echo "post_max_size = 10G" >> /usr/local/etc/php/conf.d/uploads.ini && \
    echo "memory_limit = 512M" >> /usr/local/etc/php/conf.d/uploads.ini
```

Build and use this custom image:
```bash
docker build -t karadav-custom .
docker-compose up -d
```

### Health Check Failing

If the health check shows unhealthy:

1. Check if Apache is running inside the container:
   ```bash
   docker exec karadav service apache2 status
   ```

2. Check if PHP is working:
   ```bash
   docker exec karadav curl -I http://localhost/
   ```

## Security Recommendations

### Change Default Credentials

After first login, immediately:
1. Go to the admin panel
2. Change the password for the `demo` user
3. Or delete the `demo` user and create a new admin account

### Use HTTPS

Always use HTTPS in production:
- Use a reverse proxy (nginx/Apache) with SSL certificates
- Use Let's Encrypt for free SSL certificates
- Update `WWW_URL` to use `https://`

### Restrict Access

Use firewall rules or reverse proxy authentication to restrict access:

```bash
# UFW example - allow only from specific IP
sudo ufw allow from 192.168.1.0/24 to any port 8080
```

### Regular Backups

- Backup the `data/` directory regularly
- Test your backups by restoring to a test instance
- Consider using automated backup tools

### Keep Updated

- Regularly update to the latest KaraDAV Docker image
- Monitor the GitHub repository for security updates
- Subscribe to release notifications

## Included Features

The Docker image includes:
- ✅ PHP 8.3 with all required extensions
- ✅ Apache web server with mod_rewrite and headers
- ✅ SQLite3 support
- ✅ GD and ImageMagick for thumbnails
- ✅ Support for all KaraDAV features
- ✅ Multi-architecture support (AMD64, ARM64)
- ✅ Health checks
- ✅ Automatic database initialization
- ✅ Default demo user for testing

## Using Pre-built Images

### From GitHub Container Registry (GHCR)

```bash
docker pull ghcr.io/theitsnameless/karadav:latest
```

Available tags:
- `latest` - Latest stable release from main branch
- `v1.0.0` - Specific version tag
- `main` - Latest commit on main branch
- `sha-abc123` - Specific commit

## Building from Source

If you want to build the image yourself:

```bash
# Clone the repository
git clone https://github.com/TheItsNameless/karadav.git
cd karadav

# Build the image
docker build -t karadav:local .

# Run with your local build
docker run -d -p 8080:80 -v ./data:/var/www/html/data karadav:local
```

## Support

For issues and questions:
- GitHub Issues: https://github.com/TheItsNameless/karadav/issues
- Documentation: https://github.com/TheItsNameless/karadav/tree/main/doc

## License

KaraDAV is licensed under AGPL v3. See LICENSE file for details.

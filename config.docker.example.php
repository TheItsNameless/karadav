<?php

namespace KaraDAV;

/**
 * Example configuration for Docker deployment
 * 
 * This file should be customized based on your deployment needs.
 * Copy this file and mount it to /var/www/html/config.local.php in your container.
 */

/**
 * WWW_URL is the complete URL of the root of this server
 * Change this to match your deployment URL
 */
const WWW_URL = 'http://localhost:8080/';

/**
 * Users file storage path
 * Using data directory for persistence
 */
const STORAGE_PATH = __DIR__ . '/data/storage/%s';

/**
 * SQLite3 database file
 * Using data directory for persistence
 */
const DB_FILE = __DIR__ . '/data/db.sqlite';

/**
 * Enable or disable thumbnail generation
 * This might consume a lot of CPU and storage if you have a lot of images.
 */
const ENABLE_THUMBNAILS = true;

/**
 * Default quota for new users (in MB)
 * 0 = unlimited
 */
const DEFAULT_QUOTA = 0;

/**
 * Block iOS apps
 * This is enabled by default as they have been reported as not working.
 * Set to FALSE to allow iOS apps (at your own risk).
 */
const BLOCK_IOS_APPS = true;

/**
 * Session timeout (in seconds)
 * Default: 7 days
 */
const SESSION_TIMEOUT = 60*60*24*7;

/**
 * Show PHP errors details to users?
 * Set to FALSE in production for security.
 */
const ERRORS_SHOW = false;

/**
 * Path to a log file for errors
 */
const ERRORS_LOG = __DIR__ . '/data/error.log';

// Randomly generated secret key, please change only if necessary
const SECRET_KEY = 'n8hpQN/1If5bF5LzR+hSZg==';



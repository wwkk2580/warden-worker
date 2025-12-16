-- Users table to store user accounts and their master keys/hashes
CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY NOT NULL,
    name TEXT,
    avatar_color TEXT,
    email TEXT NOT NULL UNIQUE,
    email_verified BOOLEAN NOT NULL DEFAULT 0,
    master_password_hash TEXT NOT NULL,
    master_password_hint TEXT,
    password_salt TEXT,
    key TEXT NOT NULL，
    private_key TEXT NOT NULL, 
    public_key TEXT NOT NULL, 
    kdf_type INTEGER NOT NULL DEFAULT 0, 
    kdf_iterations INTEGER NOT NULL DEFAULT 600000,
    kdf_memory INTEGER,
    kdf_parallelism INTEGER,
    security_stamp TEXT,
    totp_recover TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

-- Ciphers table for storing encrypted vault items
CREATE TABLE IF NOT EXISTS ciphers (
    id TEXT PRIMARY KEY NOT NULL,
    user_id TEXT,
    organization_id TEXT,
    type INTEGER NOT NULL,
    data TEXT NOT NULL，
    favorite BOOLEAN NOT NULL DEFAULT 0,
    folder_id TEXT,
    deleted_at TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (folder_id) REFERENCES folders(id) ON DELETE SET NULL
);

-- Attachments table for cipher file metadata
CREATE TABLE IF NOT EXISTS attachments (
    id TEXT PRIMARY KEY NOT NULL,
    cipher_id TEXT NOT NULL,
    file_name TEXT NOT NULL,
    file_size INTEGER NOT NULL,
    akey TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    organization_id TEXT,
    FOREIGN KEY (cipher_id) REFERENCES ciphers(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_attachments_cipher ON attachments(cipher_id);

-- Pending attachments table for in-flight uploads
CREATE TABLE IF NOT EXISTS attachments_pending (
    id TEXT PRIMARY KEY NOT NULL,
    cipher_id TEXT NOT NULL,
    file_name TEXT NOT NULL,
    file_size INTEGER NOT NULL,
    akey TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    organization_id TEXT,
    FOREIGN KEY (cipher_id) REFERENCES ciphers(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_attachments_pending_cipher ON attachments_pending(cipher_id);
CREATE INDEX IF NOT EXISTS idx_attachments_pending_created_at ON attachments_pending(created_at);

-- TwoFactor table for two-factor authentication
-- Types: 0=Authenticator(TOTP), 1=Email, 5=Remember, 8=RecoveryCode
CREATE TABLE IF NOT EXISTS twofactor (
    uuid TEXT PRIMARY KEY NOT NULL,
    user_uuid TEXT NOT NULL,
    atype INTEGER NOT NULL,
    enabled INTEGER NOT NULL DEFAULT 1,
    data TEXT NOT NULL，
    last_used INTEGER NOT NULL DEFAULT 0, 
    FOREIGN KEY (user_uuid) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE(user_uuid, atype)
);

-- Folders table for organizing ciphers
CREATE TABLE IF NOT EXISTS folders (
    id TEXT PRIMARY KEY NOT NULL,
    user_id TEXT NOT NULL,
    name TEXT NOT NULL, 
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- auth.users definition
CREATE SEQUENCE IF NOT EXISTS {{ index .Options "Namespace" }}.users_sid_seq START 1;
CREATE TABLE IF NOT EXISTS {{ index .Options "Namespace" }}.users (
	instance_id uuid NULL,
	id uuid NOT NULL UNIQUE,
	"sid" varchar(4) NOT NULL UNIQUE DEFAULT lpad((nextval('{{ index .Options "Namespace" }}.users_sid_seq'))::text, 6, '0'),
	aud varchar(255) NULL,
	"role" varchar(255) NULL,
	email varchar(255) NULL UNIQUE,
	encrypted_password varchar(255) NULL,
	confirmed_at timestamptz NULL,
	invited_at timestamptz NULL,
	confirmation_token varchar(255) NULL,
	confirmation_sent_at timestamptz NULL,
	recovery_token varchar(255) NULL,
	recovery_sent_at timestamptz NULL,
	email_change_token varchar(255) NULL,
	email_change varchar(255) NULL,
	email_change_sent_at timestamptz NULL,
	last_sign_in_at timestamptz NULL,
	raw_app_meta_data jsonb NULL,
	raw_user_meta_data jsonb NULL,
	is_super_admin bool NULL,
	created_at timestamptz NULL,
	updated_at timestamptz NULL,
	CONSTRAINT users_pkey PRIMARY KEY (id)
);
CREATE INDEX IF NOT EXISTS users_instance_id_email_idx ON {{ index .Options "Namespace" }}.users USING btree (instance_id, email);
CREATE INDEX IF NOT EXISTS users_instance_id_idx ON {{ index .Options "Namespace" }}.users USING btree (instance_id);
comment on table {{ index .Options "Namespace" }}.users is 'Auth: Stores user login data within a secure schema.';

-- Add trigger to handle empty strings
CREATE OR REPLACE FUNCTION {{ index .Options "Namespace" }}.generate_sid_if_empty()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.sid IS NULL OR trim(NEW.sid) = '' THEN
        NEW.sid := lpad((nextval('{{ index .Options "Namespace" }}.users_sid_seq'))::text, 4, '0');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER users_generate_sid_trigger
    BEFORE INSERT OR UPDATE ON {{ index .Options "Namespace" }}.users
    FOR EACH ROW EXECUTE FUNCTION {{ index .Options "Namespace" }}.generate_sid_if_empty();

-- auth.refresh_tokens definition

CREATE TABLE IF NOT EXISTS {{ index .Options "Namespace" }}.refresh_tokens (
	instance_id uuid NULL,
	id bigserial NOT NULL,
	"token" varchar(255) NULL,
	user_id varchar(255) NULL,
	revoked bool NULL,
	created_at timestamptz NULL,
	updated_at timestamptz NULL,
	CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id)
);
CREATE INDEX IF NOT EXISTS refresh_tokens_instance_id_idx ON {{ index .Options "Namespace" }}.refresh_tokens USING btree (instance_id);
CREATE INDEX IF NOT EXISTS refresh_tokens_instance_id_user_id_idx ON {{ index .Options "Namespace" }}.refresh_tokens USING btree (instance_id, user_id);
CREATE INDEX IF NOT EXISTS refresh_tokens_token_idx ON {{ index .Options "Namespace" }}.refresh_tokens USING btree (token);
comment on table {{ index .Options "Namespace" }}.refresh_tokens is 'Auth: Store of tokens used to refresh JWT tokens once they expire.';

-- auth.instances definition

CREATE TABLE IF NOT EXISTS {{ index .Options "Namespace" }}.instances (
	id uuid NOT NULL,
	uuid uuid NULL,
	raw_base_config text NULL,
	created_at timestamptz NULL,
	updated_at timestamptz NULL,
	CONSTRAINT instances_pkey PRIMARY KEY (id)
);
comment on table {{ index .Options "Namespace" }}.instances is 'Auth: Manages users across multiple sites.';

-- auth.audit_log_entries definition

CREATE TABLE IF NOT EXISTS {{ index .Options "Namespace" }}.audit_log_entries (
	instance_id uuid NULL,
	id uuid NOT NULL,
	payload json NULL,
	created_at timestamptz NULL,
	CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id)
);
CREATE INDEX IF NOT EXISTS audit_logs_instance_id_idx ON {{ index .Options "Namespace" }}.audit_log_entries USING btree (instance_id);
comment on table {{ index .Options "Namespace" }}.audit_log_entries is 'Auth: Audit trail for user actions.';

-- auth.schema_migrations definition

CREATE TABLE IF NOT EXISTS {{ index .Options "Namespace" }}.schema_migrations (
	"version" varchar(255) NOT NULL,
	CONSTRAINT schema_migrations_pkey PRIMARY KEY ("version")
);
comment on table {{ index .Options "Namespace" }}.schema_migrations is 'Auth: Manages updates to the auth system.';
		
-- Gets the User ID from the request cookie
create or replace function {{ index .Options "Namespace" }}.uid() returns uuid as $$
  select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid;
$$ language sql stable;

-- Gets the User ID from the request cookie
create or replace function {{ index .Options "Namespace" }}.role() returns text as $$
  select nullif(current_setting('request.jwt.claim.role', true), '')::text;
$$ language sql stable;

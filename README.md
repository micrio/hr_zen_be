# HR Zen — Backend (Rails API)

Rails 7.2 API-only backend for HR Zen. PostgreSQL 16, Devise + JWT, Pundit,
acts_as_tenant multi-tenancy, Solid Queue/Cache/Cable.

## Endpoints

| Verb | Path | Auth | Purpose |
|------|------|------|---------|
| POST | `/api/v1/sign_up` | public | Create organization + owner user |
| POST | `/api/v1/sign_in` | public | Authenticate, returns user + org + JWT |
| DELETE | `/api/v1/sign_out` | public | No-op (stateless JWT) |
| GET | `/api/v1/users/me` | Bearer JWT | Current user + organization |

All responses use the envelope:

```json
{ "success": true, "data": { }, "meta": { "message": "..." } }
{ "success": false, "error": "...", "details": { "field": ["msg"] } }
```

### Sign in

```bash
curl -X POST http://localhost:3001/api/v1/sign_in \
  -H 'Content-Type: application/json' \
  -d '{"user":{"email":"owner@acme.test","password":"password123"}}'
```

Returns `data.token` (raw JWT). Send it back as `Authorization: Bearer <token>`.

## Request flow

```
request → Api::V1::BaseController (Secured + JsonRenderer + RescueExceptions + Pundit)
        → controller action → Api::V1::*Service → serializer → render_jsonapi
```

- Controllers stay thin; business logic lives in `app/services/api/v1/`.
- Errors: `Api::Error::*` mapped to status codes in `RescueExceptions`.
- `SetupWorkspaceJob` (Solid Queue, `:priority`) provisions the Auth Matrix
  after sign-up.

## Auth notes

- `devise-jwt` with the `Null` revocation strategy (stateless; client discards
  the token on sign-out).
- `devise_for :users, skip: :all` registers the mapping (needed for
  `authenticate_user!` / `current_user`) without exposing Devise HTTP routes.
- **Interim:** `config.allow_unconfirmed_access_for = nil` so unconfirmed users
  can authenticate until the confirmation email flow is wired up.

## Local (Docker)

```bash
docker compose up -d --build      # app: http://localhost:3001, postgres: 5433
docker compose exec app bin/rails c
```

Rebuild after Gemfile changes so the bundler volume picks up new gems.

## Local (no Docker app)

```bash
docker compose up -d db
bin/rails db:prepare
bin/rails s -p 3001
bin/jobs            # Solid Queue worker
```

Env in `.env` (`DB_URL`, `CORS_ORIGINS`, `MAILER_SENDER`, `DEVISE_JWT_SECRET_KEY`).

## Quality

```bash
bundle exec rspec
bundle exec rubocop
bin/rails zeitwerk:check
```

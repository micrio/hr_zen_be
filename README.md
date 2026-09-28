# HR Zen — Backend (Rails API)

Rails 7.2 API-only backend for HR Zen. PostgreSQL 16, Devise + JWT, Pundit,
acts_as_tenant multi-tenancy, Solid Queue/Cache/Cable.

## Screenshots
<img width="1506" height="861" alt="Screenshot 2026-09-29 at 7 14 35 AM" src="https://github.com/user-attachments/assets/1247e153-bf86-4daa-b023-608c311dd70e" />
<img width="1506" height="861" alt="Screenshot 2026-09-29 at 7 15 40 AM" src="https://github.com/user-attachments/assets/1dad2da8-6c74-40fc-aae8-b1b6e8220483" />
<img width="1506" height="861" alt="Screenshot 2026-09-29 at 7 16 05 AM" src="https://github.com/user-attachments/assets/de1ae51d-be47-45e9-bb09-6297560a896e" />
<img width="1506" height="861" alt="Screenshot 2026-09-29 at 7 16 10 AM" src="https://github.com/user-attachments/assets/989e39b0-0883-4714-b8f1-e6cff5455b66" />
<img width="1506" height="861" alt="Screenshot 2026-09-29 at 7 16 15 AM" src="https://github.com/user-attachments/assets/b1b5a76e-dd02-4e0d-b125-0509f8534517" />
<img width="1506" height="861" alt="Screenshot 2026-09-29 at 7 16 18 AM" src="https://github.com/user-attachments/assets/cc2e66ab-caa0-4886-920b-3e3fcae8aed7" />
<img width="1506" height="861" alt="Screenshot 2026-09-29 at 7 16 25 AM" src="https://github.com/user-attachments/assets/73b2350b-6255-4f05-9392-87fae040d8f8" />
<img width="1506" height="861" alt="Screenshot 2026-09-29 at 7 16 29 AM" src="https://github.com/user-attachments/assets/5c3e7175-255f-4fce-9f8f-dd13e450726c" />
<img width="1506" height="861" alt="Screenshot 2026-09-29 at 7 17 10 AM" src="https://github.com/user-attachments/assets/f97167b5-ed4c-42c7-bf6d-2dcdbdc9d54c" />
<img width="1506" height="861" alt="Screenshot 2026-09-29 at 7 17 15 AM" src="https://github.com/user-attachments/assets/6df19c3b-4634-4d54-91fc-04af5e2f4290" />
<img width="1506" height="861" alt="Screenshot 2026-09-29 at 7 17 19 AM" src="https://github.com/user-attachments/assets/aa8b1618-ee3f-4b8e-836a-ffc6eab560ce" />
<img width="1506" height="861" alt="Screenshot 2026-09-29 at 7 17 23 AM" src="https://github.com/user-attachments/assets/4fce2954-5487-45c6-a9b7-eab496cd0212" />
<img width="1506" height="861" alt="Screenshot 2026-09-29 at 7 17 45 AM" src="https://github.com/user-attachments/assets/5fa1d633-437d-4909-8f54-f757e69e6a6f" />
<img width="1506" height="861" alt="Screenshot 2026-09-29 at 7 17 49 AM" src="https://github.com/user-attachments/assets/bd24a305-f5cb-4b66-8c16-9e90b29c0542" />
<img width="1506" height="861" alt="Screenshot 2026-09-29 at 7 17 54 AM" src="https://github.com/user-attachments/assets/127fc779-fba9-4240-aac3-b842b683ec74" />
<img width="1506" height="861" alt="Screenshot 2026-09-29 at 7 17 57 AM" src="https://github.com/user-attachments/assets/07b242db-1582-4778-8fe0-4ebe7770481d" />
<img width="1506" height="861" alt="Screenshot 2026-09-29 at 7 18 12 AM" src="https://github.com/user-attachments/assets/a0339b7a-b77c-4340-ba39-3f2f1f3fbb0e" />
<img width="1506" height="861" alt="Screenshot 2026-09-29 at 7 18 17 AM" src="https://github.com/user-attachments/assets/73f70ad9-274a-4857-a4a5-be50f0ca4eb3" />
<img width="1506" height="861" alt="Screenshot 2026-09-29 at 7 18 21 AM" src="https://github.com/user-attachments/assets/d5bf25c1-2b0a-4a90-9c3c-ac2222233fa1" />
<img width="1506" height="861" alt="Screenshot 2026-09-29 at 7 18 25 AM" src="https://github.com/user-attachments/assets/eb8b95f5-780b-4eb0-bbc8-2ad26e5d4639" />
<img width="1506" height="861" alt="Screenshot 2026-09-29 at 7 18 28 AM" src="https://github.com/user-attachments/assets/c824058b-a696-46f9-8014-6e66ad64cf1b" />
<img width="1506" height="861" alt="Screenshot 2026-09-29 at 7 18 31 AM" src="https://github.com/user-attachments/assets/27d4d10c-5b4a-489d-aba0-147c07f0679d" />
<img width="1506" height="861" alt="Screenshot 2026-09-29 at 7 18 34 AM" src="https://github.com/user-attachments/assets/960778f1-dcdf-4a63-8774-18e43b0d882c" />
<img width="1506" height="861" alt="Screenshot 2026-09-29 at 7 18 37 AM" src="https://github.com/user-attachments/assets/8749c5f3-08ee-47b0-bf29-5cbba1bf1c38" />
<img width="1506" height="861" alt="Screenshot 2026-09-29 at 7 18 44 AM" src="https://github.com/user-attachments/assets/121004fa-f1d0-431d-b487-45e5de5cd524" />
<img width="1506" height="861" alt="Screenshot 2026-09-29 at 7 18 52 AM" src="https://github.com/user-attachments/assets/c2756dfc-023b-4e81-b99a-55e027694673" />
<img width="1506" height="861" alt="Screenshot 2026-09-29 at 7 18 56 AM" src="https://github.com/user-attachments/assets/3a6278b0-8df0-44e9-98aa-dd8bb31e727b" />
<img width="1506" height="861" alt="Screenshot 2026-09-29 at 7 19 28 AM" src="https://github.com/user-attachments/assets/2a7678a8-bc54-4017-8aca-42b9f927936f" />
<img width="1506" height="861" alt="Screenshot 2026-09-29 at 7 19 34 AM" src="https://github.com/user-attachments/assets/0179beef-bd71-45b0-b1ab-d68bd82db4ed" />


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

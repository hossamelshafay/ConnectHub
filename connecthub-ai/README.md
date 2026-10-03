# ConnectHub AI Engine

Standalone AI backend service powering all ConnectHub AI capabilities.

> **Completely independent from the Flutter application.**  
> Can be deployed, scaled, and iterated on without touching the mobile app.

---

## Architecture

```
connecthub-ai/
├── app/
│   ├── config/         # Centralized settings (pydantic-settings)
│   ├── core/           # Logging, Firebase init, exception handlers
│   ├── dependencies/   # FastAPI DI providers (services + auth)
│   ├── middleware/      # Request logging ASGI middleware
│   ├── models/         # Internal domain models (Phase 2+)
│   ├── routers/        # HTTP route handlers (health, ai, portfolio)
│   ├── schemas/        # Pydantic v2 request/response schemas
│   ├── services/       # Business logic (Gemini, PDF, Portfolio, Validation)
│   ├── utils/          # Shared utilities
│   └── main.py         # Application factory & entry point
├── tests/              # pytest test suite
├── requirements.txt    # Python dependencies
├── Dockerfile          # Multi-stage Docker build
├── .env.example        # Environment variable template
└── README.md
```

### Layered Architecture

```
Routers  →  Services  →  Models / Schemas  →  External APIs  →  Firebase
```

Business logic never lives in routers.

---

## Technology Stack

| Component        | Library                  | Version   |
|------------------|--------------------------|-----------|
| Web Framework    | FastAPI                  | 0.115.x   |
| ASGI Server      | Uvicorn                  | 0.32.x    |
| Data Validation  | Pydantic v2              | 2.10.x    |
| AI              | Google Gemini API        | 0.8.x     |
| Database         | Firebase Admin SDK       | 6.6.x     |
| PDF              | PyMuPDF                  | 1.25.x    |
| Logging          | structlog                | 24.4.x    |
| HTTP Client      | httpx                    | 0.28.x    |
| Retries          | tenacity                 | 9.0.x     |

---

## Quick Start

### 1. Prerequisites

- Python 3.13+
- A Google Gemini API key
- A Firebase service account JSON

### 2. Create a virtual environment

```bash
python -m venv .venv
# Windows
.venv\Scripts\activate
# macOS / Linux
source .venv/bin/activate
```

### 3. Install dependencies

```bash
pip install -r requirements.txt
```

### 4. Configure environment variables

```bash
cp .env.example .env
# Edit .env and fill in your real values
```

Required variables:

| Variable                    | Description                              |
|-----------------------------|------------------------------------------|
| `GEMINI_API_KEY`            | Google Gemini API key                    |
| `FIREBASE_CREDENTIALS_PATH` | Path to Firebase service-account JSON    |
| `FIREBASE_PROJECT_ID`       | Firebase project ID                      |

### 5. Run the server

```bash
uvicorn app.main:app --reload
```

The API will be available at `http://localhost:8000`.

Interactive docs: `http://localhost:8000/docs`

---

## API Endpoints

### Phase 1 (current)

| Method | Path      | Description              |
|--------|-----------|--------------------------|
| GET    | `/health` | Service health check     |
| GET    | `/docs`   | Swagger UI (dev only)    |
| GET    | `/redoc`  | ReDoc UI (dev only)      |

### Phase 2 (AI CV Agent — upcoming)

| Method | Path               | Description                   |
|--------|--------------------|-------------------------------|
| POST   | `/ai/cv/parse`     | Upload CV PDF → portfolio     |
| GET    | `/portfolio/{uid}` | Retrieve user portfolio       |
| PATCH  | `/portfolio/{uid}` | Update portfolio              |
| POST   | `/ai/resume/review`| AI resume review              |
| POST   | `/ai/ats/analyze`  | ATS score vs. job description |
| POST   | `/ai/cover-letter` | Generate cover letter         |
| POST   | `/ai/career/advise`| Career advice                 |

---

## Health Check

```bash
curl http://localhost:8000/health
```

```json
{
  "status": "ok",
  "service": "ConnectHub AI Engine",
  "version": "1.0.0"
}
```

---

## Docker

```bash
# Build
docker build -t connecthub-ai .

# Run
docker run -p 8000:8000 --env-file .env connecthub-ai
```

---

## Testing

```bash
pytest tests/ -v
```

---

## Environment Variables Reference

See [`.env.example`](.env.example) for the full list with descriptions.

---

## Project Roadmap

| Phase | Feature                    | Status      |
|-------|----------------------------|-------------|
| 1     | Foundation & Health API    | ✅ Complete  |
| 2     | AI CV Agent                | 🔜 Upcoming |
| 2     | GitHub Repository Import   | 🔜 Upcoming |
| 3     | Resume Reviewer            | 🔜 Planned  |
| 3     | ATS Analyzer               | 🔜 Planned  |
| 3     | Portfolio Optimizer        | 🔜 Planned  |
| 4     | Cover Letter Generator     | 🔜 Planned  |
| 4     | Career Advisor             | 🔜 Planned  |
| 5     | Interview Coach            | 🔜 Planned  |

---

## Security

- API keys and credentials are loaded exclusively from environment variables.
- No secrets are hardcoded anywhere in the codebase.
- The Docker image runs as a non-root user.
- API docs are disabled in production (`APP_ENV=production`).
- File type and size validation are enforced on all uploads.

---

## Code Quality

- **SOLID principles** throughout.
- **Dependency Injection** via FastAPI's `Depends()` system.
- **Type hints** on every function and method.
- **Docstrings** on all public APIs.
- **Structured logging** (no `print()` statements).

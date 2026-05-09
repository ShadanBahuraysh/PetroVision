# PetroVision Backend

The PetroVision backend is responsible for handling APIs, authentication, station analysis, recommendation generation, reporting, loyalty operations, and database communication.

---

# Technologies

* FastAPI
* Python
* Supabase PostgreSQL
* Pandas
* Requests
* APScheduler

---

# Backend Modules

## Authentication

Handles:

* Login
* Signup
* OTP verification
* Password reset
* Role-based access

## Analysis System

Handles:

* Station performance analysis
* Recommendation generation
* AI explanations
* Ranking and overview generation
* Report export

## Loyalty System

Handles:

* Points calculation
* Membership tiers
* Transactions
* Offers and rewards

## Station Services

Handles:

* Station retrieval
* Station map integration
* Station details

---

# Design Patterns Used

* Proxy Pattern
* Template Pattern
* Strategy Pattern

---

# Environment Variables

Create a `.env` file:

```env
DB_HOST=your_database_host
DB_NAME=your_database_name
DB_USER=your_database_user
DB_PASSWORD=your_database_password
DB_PORT=5432
DB_SSLMODE=require

OPENROUTER_API_KEY=your_openrouter_api_key
MODEL_NAME=deepseek/deepseek-chat

SUPABASE_URL=your_supabase_url
SUPABASE_KEY=your_supabase_key

GOOGLE_API_KEY=your_google_maps_api_key

EMAIL_ADDRESS=your_email
EMAIL_PASSWORD=your_email_password
```

---

# Run Backend

```bash
uvicorn app.main:app --reload
```

---

# Run Tests

```bash
pytest
```

---

# API Base URL

```bash
http://localhost:8000
```

---

# Backend Structure

```text
Backend-python/
│
├── app/
│   ├── api/
│   ├── ml/
│   ├── models/
│   ├── patterns/
│   ├── schemas/
│   ├── services/
│   ├── utils/
│   ├── main.py
│   └── supabase_client.py
│
├── tests/
├── .env
├── requirements.txt
└── README.md
```

---

# Contributors

* Shadan Abdullah
* Jehan Meqdad
* Raghad Assalahi
* Raghad Alzahrani

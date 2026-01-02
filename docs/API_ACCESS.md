# Portfolio API Access Guide

This document outlines the valid endpoints for accessing the Portfolio Service in different environments.

## 1. Live Environment (Domain)
**Base URL:** `https://am.munish.org`
**Authentication:** Required (Bearer Token)
**Traefik Route:** `PathPrefix(`/api/portfolio`)` -> Rewrites to `/v1/...`

| Endpoint Type | HTTP Method | Full URL Example | Notes |
| :--- | :--- | :--- | :--- |
| **Summary** | `GET` | `https://am.munish.org/api/portfolio/v1/portfolios/summary?userId=...` | Proxied via Traefik (Port 443) |
| **List** | `GET` | `https://am.munish.org/api/portfolio/v1/portfolios/list?userId=...` | |
| **Holdings** | `GET` | `https://am.munish.org/api/portfolio/v1/portfolios/holdings?userId=...` | |

> **IMPORTANT:**
> - The path **MUST** start with `/api/portfolio/v1/...`
> - Traefik strips `/api/portfolio` and forwards `/v1/...` to the backend.

---

## 2. Local Gateway (Traefik Localhost)
**Base URL:** `http://localhost:8000`
**Authentication:** Required
**Traefik Route:** Same as live

| Endpoint Type | HTTP Method | Full URL Example | Notes |
| :--- | :--- | :--- | :--- |
| **Summary** | `GET` | `http://localhost:8000/api/portfolio/v1/portfolios/summary?userId=...` | Proxied via Traefik (Port 8000) |
| **List** | `GET` | `http://localhost:8000/api/portfolio/v1/portfolios/list?userId=...` | |

---

## 3. Local Direct (Backend Container)
**Base URL:** `http://localhost:8072`
**Authentication:** Required
**Backend Path:** `/v1/...` (No `/api` prefix or `/api/portfolio` prefix)

| Endpoint Type | HTTP Method | Full URL Example | Notes |
| :--- | :--- | :--- | :--- |
| **Summary** | `GET` | `http://localhost:8072/v1/portfolios/summary?userId=...` | Direct access to container |
| **List** | `GET` | `http://localhost:8072/v1/portfolios/list?userId=...` | |

> **WARNING:**
> - Do **NOT** include `/api` or `/api/portfolio` when accessing port `8072` directly.
> - The backend controller is mapped to `/v1/portfolios`.

## Usage Examples (CURL)

### Live Access
```bash
curl --location 'https://am.munish.org/api/portfolio/v1/portfolios/list?userId=e1fd2918-484f-4716-ad5b-d46090891e01' \
--header 'Authorization: Bearer <YOUR_TOKEN>'
```

### Local Direct Access
```bash
curl --location 'http://localhost:8072/v1/portfolios/list?userId=e1fd2918-484f-4716-ad5b-d46090891e01' \
--header 'Authorization: Bearer <YOUR_TOKEN>'
```

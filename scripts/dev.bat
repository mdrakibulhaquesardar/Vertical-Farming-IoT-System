@echo off
setlocal enabledelayedexpansion

if not exist .venv (
  python -m venv .venv
)

call .\.venv\Scripts\activate.bat

if "%APP_ENV%"=="" set APP_ENV=development
if "%SECRET_KEY%"=="" set SECRET_KEY=dev_secret

python -m pip install --upgrade pip >nul 2>nul
pip install -r requirements.txt >nul 2>nul

python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

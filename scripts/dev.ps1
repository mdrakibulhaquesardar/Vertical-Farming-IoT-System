param(
  [string]$HostAddress = "0.0.0.0",
  [int]$Port = 8000
)

$ErrorActionPreference = "Stop"

# Activate venv if not already active
if (-not $env:VIRTUAL_ENV) {
  if (Test-Path ".\.venv\Scripts\Activate.ps1") {
    . ".\.venv\Scripts\Activate.ps1"
  } else {
    python -m venv .venv
    . ".\.venv\Scripts\Activate.ps1"
  }
}

$env:APP_ENV = $env:APP_ENV -as [string]
if (-not $env:APP_ENV) { $env:APP_ENV = "development" }
if (-not $env:SECRET_KEY) { $env:SECRET_KEY = "dev_secret" }

python -m pip install --upgrade pip | Out-Null
pip install -r requirements.txt | Out-Null

python -m uvicorn app.main:app --reload --host $HostAddress --port $Port

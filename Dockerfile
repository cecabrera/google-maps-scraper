## Base image with Python and all Playwright system dependencies preinstalled (Ubuntu Jammy)
FROM mcr.microsoft.com/playwright/python:v1.45.0-jammy

## Ensure Python doesn't write .pyc files and streams logs unbuffered
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

## Set the working directory inside the container
WORKDIR /app

## Copy dependency manifests first to leverage Docker layer caching
COPY requirements.txt setup.py ./

## Install Python dependencies and only Chromium (smaller than all browsers)
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install -e . --no-deps \
    && playwright install chromium

## Copy the rest of the application code
COPY . .

## Expose API port
EXPOSE 8001

## Launch FastAPI app with Uvicorn, binding to all interfaces
CMD ["uvicorn", "gmaps_scraper_server.main_api:app", "--host", "0.0.0.0", "--port", "8001"]
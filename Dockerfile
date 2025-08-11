# Build frontend
FROM node:20.19 AS frontend-build
WORKDIR /app
# Copy everything needed for frontend build
COPY . /app
# Check directory structure to help with debugging
RUN ls -la

# Build frontend if frontend directory exists
RUN if [ -d "frontend" ]; then \
    cd frontend && \
    yarn install && \
    yarn workspace ui build; \
    fi

# Build backend
FROM python:3.13-alpine

# Install system dependencies
RUN apk update && apk add --no-cache \
    linux-headers \
    python3-dev \
    gcc \
    curl \
    libc-dev \
    supervisor \
    imagemagick \
    nginx \
    libpq-dev \
    poppler-utils

WORKDIR /app
COPY . /app
# Check directory structure to help with debugging
RUN ls -la

# Install Python dependencies
RUN pip install poetry==2.0.1 && \
    poetry config virtualenvs.create false && \
    poetry install -E pg -E cloud

# Set up environment variables
ENV PAPERMERGE__DATABASE__URL="postgresql://postgres:${PGPASSWORD}@${DATABASE_URL}"
ENV PAPERMERGE__MAIN__MEDIA_ROOT="/storage"
ENV PAPERMERGE__AUTH__USERNAME="admin"
ENV PAPERMERGE__AUTH__EMAIL="admin@example.com"
ENV PAPERMERGE__OCR__LANG_CODES="eng,deu"
ENV PAPERMERGE__OCR__DEFAULT_LANG_CODE="eng"
ENV PAPERMERGE__MAIN__API_PREFIX="/api"

# Expose port
EXPOSE 8000

# Initialize and start application
CMD ["poetry", "run", "task", "server"]

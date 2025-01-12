# can serve as a standard Dockerfile for Django projects using Python and Django REST Framework.
# It handles production and development environments, sets up a virtual environment, and
# minimizes the image size by removing unnecessary dependencies after installation.

# Base image with Python 3.11 (Alpine for a smaller footprint)
FROM python:3.11.4-alpine
LABEL maintainer="myappdeveloper.com"

# Ensure output is not buffered
ENV PYTHONUNBUFFERED=1

# Copy requirements files
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt

# Copy the application code
COPY ./app /app

# Set working directory
WORKDIR /app

# Expose the port that Django will run on
EXPOSE 8000

# Set the ARG for development mode (default is false)
ARG DEV=false

# Create virtual environment and install dependencies
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    # Install PostgreSQL client and development dependencies for building psycopg2
    # - postgresql-client: Required to connect to PostgreSQL
    # - build-base, postgresql-dev, musl-dev: Required to compile Python packages like psycopg2 that depend on PostgreSQL
    # After installing the required Python packages, remove the temporary build dependencies to minimize the image size
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    # Install additional development dependencies if in development mode
    if [ "$DEV" = "true" ]; then \
        /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    # Remove temporary build dependencies to reduce image size
    rm -rf /tmp && \
    echo "Dev environment setup completed." && \
    apk del .tmp-build-deps && \
    # Create a non-root user for running the application
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# Set the PATH to include the virtual environment
ENV PATH="/py/bin:$PATH"

# Run the application as the django-user
USER django-user

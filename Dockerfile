# Base image
FROM python:3.10-slim as base

# Expose port 5000
EXPOSE 5000

# Prevent Python from generating .pyc files and enable unbuffered output
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install dependencies
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Set working directory
WORKDIR /flask_starterkit

# Copy application code
COPY . /flask_starterkit

# Create a non-root user and set appropriate permissions
RUN adduser --uid 5678 --disabled-password --gecos "" appuser && \
    chown -R appuser /flask_starterkit
USER appuser

# Debugger configuration
FROM base as debugger

RUN pip install debugpy

# Command to run the debugger
CMD ["python", "-m", "debugpy", "--listen", "0.0.0.0:5678", "--wait-for-client", "-m", "flask", "run", "--host", "0.0.0.0", "--port", "5000"]

# Development server
FROM base as debug

# Command to run the development server
CMD ["flask", "run", "--host", "0.0.0.0", "--port", "5000"]

# Test stage
FROM base as test

RUN pip install pytest

# Command to run tests
CMD ["python", "-m", "pytest"]

# Production stage
FROM base as prod

# Command to run the production server
CMD ["flask", "run", "--host", "0.0.0.0", "--port", "5000"]

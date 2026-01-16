# Use slim Python 3.13 image
FROM python:3.13-slim

# Set working directory
WORKDIR /app

# Install system dependencies for psycopg2 and building wheels
RUN apt-get update && apt-get install -y \
    libpq-dev \
    gcc \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy project files
COPY . .

# Upgrade pip
RUN pip install --upgrade pip

# Install Python dependencies
RUN pip install uv pandas pyarrow sqlalchemy requests click psycopg2

# Expose Jupyter port (optional)
EXPOSE 8888

# Default command: bash (interactive container)
CMD ["bash"]

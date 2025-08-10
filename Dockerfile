# Use a specific Python base image version
FROM python:3.8-slim-bullseye

# Set work directory
WORKDIR /usr/src/app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gfortran \
    libgfortran5 \
    python3-dev \
    libopenblas-dev \
    liblapack-dev \
    libatlas-base-dev \
    pkg-config \
    git \
 && rm -rf /var/lib/apt/lists/*

# Upgrade pip and install specific versions of setuptools and wheel (legacy-friendly)
RUN pip install --no-cache-dir --upgrade "pip<25" \
 && pip install --no-cache-dir "setuptools<60" "wheel<0.40"

# Install Python dependencies compatible with legacy SciPy builds
RUN pip install --no-cache-dir numpy==1.19.5 cython==0.29.33 pytest pybind11 nose

# Make legacy builds use the preinstalled deps and be stable
ENV PYTHONUNBUFFERED=1 PYTHONDONTWRITEBYTECODE=1
ENV PIP_NO_BUILD_ISOLATION=1 PIP_DISABLE_PIP_VERSION_CHECK=1

# Fortran/C build flags — key fix is -fallow-argument-mismatch
ENV FFLAGS="-O2 -fPIC -fallow-argument-mismatch"
ENV FCFLAGS="${FFLAGS}" F77FLAGS="${FFLAGS}"
# Help the linker find BLAS/LAPACK explicitly
ENV BLAS=/usr/lib/x86_64-linux-gnu/libopenblas.so
ENV LAPACK=/usr/lib/x86_64-linux-gnu/liblapack.so
ENV LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu

# Bring sources before sed/install
COPY . .

# Modify setup.py to fix the version issue
RUN sed -i 's/ISRELEASED[[:space:]]*=[[:space:]]*False/ISRELEASED = True/' setup.py

# Modify setup.py to remove test_suite option
RUN sed -i '/test_suite/d' setup.py

# Install scipy in editable mode with verbose output (legacy path)
RUN pip install --no-cache-dir --no-use-pep517 -e . -v

# Remove pytest.ini if it exists (to avoid config issues)
RUN rm -f pytest.ini

# Run specified test
CMD ["pytest","-v","-rA","--tb=long","-p","no:cacheprovider","--disable-warnings","scipy/sparse/tests/test_base.py"]

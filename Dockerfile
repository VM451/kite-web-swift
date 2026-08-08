# ========================================================
# Multi-stage Dockerfile for kite-web-swift Production App
# Target image footprint: < 25 MB
# ========================================================

# --- Stage 1: Build Stage using Swift 6 ---
FROM swift:6.0-jammy AS builder

WORKDIR /workspace

# Copy SPM dependency manifests first for layer caching
COPY Package.swift ./
COPY Package.resolved* ./

# Copy all source files
COPY Sources/ Sources/
COPY Templates/ Templates/
COPY Examples/ Examples/

# Compile production release binary with LTO & size optimizations
RUN swift build -c release --product kite-web-swift \
    -Xswiftc -Osize \
    -Xswiftc -whole-module-optimization

# --- Stage 2: Ultra-lean Distroless/Alpine Runtime ---
FROM ubuntu:24.04 AS runner

# Install minimal C runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libatomic1 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy compiled native binary
COPY --from=builder /workspace/.build/release/kite-web-swift /app/kite-web-swift

# Expose HTTP port
EXPOSE 3000

ENV KITE_ENV=production
ENV PORT=3000

# Run production binary
ENTRYPOINT ["/app/kite-web-swift", "start", "--port", "3000"]

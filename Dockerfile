# Stage 1: Build the Co-note application
FROM node:22.14.0-alpine AS builder
WORKDIR /app

# Copy lockfile and workspace manifests first for layer caching
COPY package.json package-lock.json ./
COPY apps/student/package.json apps/student/
COPY apps/admin/package.json apps/admin/
COPY apps/teacher/package.json apps/teacher/
COPY packages/core/package.json packages/core/
COPY packages/domain/package.json packages/domain/
COPY packages/portal/package.json packages/portal/
COPY packages/supabase/package.json packages/supabase/
COPY packages/testing/package.json packages/testing/
COPY packages/ui/package.json packages/ui/

RUN npm ci

COPY . .
RUN npm run build

# Stage 2: Minimal, non-root runtime image
FROM nginx/nginx-unprivileged:1.31.9-alpine3.24 AS runtime

# Copy built static assets from the student portal
COPY --from=builder --chown=101:101 /app/apps/student/dist /usr/share/nginx/html

# Non-root user is enforced by default (UID 101)
USER 101
EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
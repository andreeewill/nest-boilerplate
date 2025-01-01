FROM node:22.12-alpine3.20 AS base

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

RUN corepack enable

# Stage 2
FROM base AS prod

WORKDIR /usr/app

# Docker able to cache dependencies even after changes on package.json, etc (as long as pnpm-lock.yaml is not changed)
COPY pnpm-lock.yaml ./
RUN pnpm fetch

# Dependencies installation fully offline (loaded from pnpm fetch)
COPY package.json ./
RUN pnpm i --offline --frozen-lockfile

COPY . .

RUN pnpm run build

# Production
FROM prod

COPY --from=prod /usr/app/node_modules /usr/app/node_modules
COPY --from=prod /usr/app/dist /usr/app/dist

EXPOSE 8000

CMD [ "pnpm", "start:prod" ]

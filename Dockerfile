FROM debian:bookworm AS base
SHELL ["/bin/bash", "-exo", "pipefail", "-c"]
RUN <<EOT
  apt-get update
  apt-get install --yes wget
EOT

FROM base AS pg_search
ARG VERSION=0.15.20
RUN <<EOT
  package="postgresql-17-pg-search_${VERSION}-1PARADEDB-bookworm_amd64.deb"
  wget "https://github.com/paradedb/paradedb/releases/download/v${VERSION}/${package}"
  dpkg -x "${package}" /
EOT

FROM base AS pg_vector
ARG VERSION=0.3.0
RUN <<EOT
  package="vectors-pg17_${VERSION}_amd64_vectors.deb"
  wget "https://github.com/tensorchord/pgvecto.rs/releases/download/v${VERSION}/${package}"
  dpkg -x "${package}" /
EOT

FROM postgres:17.5
# pg_search
COPY --from=pg_search /usr/lib/postgresql/17/lib /usr/lib/postgresql/17/lib
COPY --from=pg_search /usr/share/postgresql/17/extension /usr/share/postgresql/17/extension
# pg_vector
COPY --from=pg_vector /usr/lib/postgresql/17/lib /usr/lib/postgresql/17/lib
COPY --from=pg_vector /usr/share/postgresql/17/extension /usr/share/postgresql/17/extension

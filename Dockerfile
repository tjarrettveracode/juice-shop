FROM node:12@sha256:01627afeb110b3054ba4a1405541ca095c8bfca1cb6f2be9479c767a2711879e as installer
COPY . /juice-shop
WORKDIR /juice-shop
RUN npm install --production --unsafe-perm
RUN npm dedupe
RUN rm -rf frontend/node_modules

FROM node:12-alpine@sha256:d4b15b3d48f42059a15bd659be60afe21762aae9d6cbea6f124440895c27db68
ARG BUILD_DATE
ARG VCS_REF
LABEL maintainer="Bjoern Kimminich <bjoern.kimminich@owasp.org>" \
    org.opencontainers.image.title="OWASP Juice Shop" \
    org.opencontainers.image.description="Probably the most modern and sophisticated insecure web application" \
    org.opencontainers.image.authors="Bjoern Kimminich <bjoern.kimminich@owasp.org>" \
    org.opencontainers.image.vendor="Open Web Application Security Project" \
    org.opencontainers.image.documentation="https://help.owasp-juice.shop" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.version="12.6.1" \
    org.opencontainers.image.url="https://owasp-juice.shop" \
    org.opencontainers.image.source="https://github.com/bkimminich/juice-shop" \
    org.opencontainers.image.revision=$VCS_REF \
    org.opencontainers.image.created=$BUILD_DATE
WORKDIR /juice-shop
RUN addgroup --system --gid 1001 juicer && \
    adduser juicer --system --uid 1001 --ingroup juicer
COPY --from=installer --chown=juicer /juice-shop .
RUN mkdir logs && \
    chown -R juicer logs && \
    chgrp -R 0 ftp/ frontend/dist/ logs/ data/ i18n/ && \
    chmod -R g=u ftp/ frontend/dist/ logs/ data/ i18n/
USER 1001
EXPOSE 3000
CMD ["npm", "start"]

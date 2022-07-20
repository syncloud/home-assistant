FROM python:3.9-slim-buster
COPY requirements.txt /
COPY core-src /core-src/
COPY build-hass.sh /
RUN /build-hass.sh
RUN rm -rf /var/lib/apt/lists/*

FROM python:3.8-slim-buster
COPY requirements.txt /
COPY build-hass.sh /
RUN /build-hass.sh
RUN rm -rf /var/lib/apt/lists/*

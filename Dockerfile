FROM ubuntu:22.04

ARG APP
ENV DISPLAY=:1
ENV DEBIAN_FRONTEND=noninteractive
ENV APP_COMMAND=$APP
ENV APP_LABEL=$APP

WORKDIR /app

# Base system packages
RUN apt update && apt install -y \
    x11vnc xvfb xauth fonts-dejavu \
    curl ca-certificates \
    python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install GUI payload
RUN if [ -n "$APP" ]; then \
      echo "[*] Installing payload: $APP" && \
      apt update && apt install -y "$APP"; \
    fi

# Unpack noVNC and websockify to /opt
COPY ./vendor/novnc-v1.6.0.tar.gz /tmp/
COPY ./vendor/websockify-v0.13.0.tar.gz /tmp/
RUN mkdir -p /opt/noVNC /opt/websockify && \
    tar -xf /tmp/novnc-v1.6.0.tar.gz -C /opt/noVNC --strip-components=1 && \
    tar -xf /tmp/websockify-v0.13.0.tar.gz -C /opt/websockify --strip-components=1 && \
    ln -s /opt/websockify /opt/noVNC/utils/websockify

# App scripts
COPY ./app/start.sh ./app/wait-for.sh ./
RUN chmod +x start.sh wait-for.sh

EXPOSE 5901 6080
CMD ["./start.sh"]
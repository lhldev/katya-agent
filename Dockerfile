FROM neoplanetz/hermes-desktop-docker:latest
USER root
RUN /usr/local/lib/hermes-agent/venv/bin/pip install --no-cache-dir 'python-telegram-bot[webhooks]==22.6'

FROM hermes-desktop:latest
USER root

# The Hermes venv has no pip binary. The Python 3.11 interpreter that the venv
# was built from does have pip, so install straight into the venv's
# site-packages with --target.
#
# --no-deps is intentional: httpx/certifi/anyio/etc. are already present in the
# venv (httpx 0.28.1 satisfies PTB's <0.29,>=0.27 requirement), and tornado is
# only needed for webhook mode. The gateway uses long polling, and
# python-telegram-bot handles a missing tornado gracefully.
RUN /usr/local/share/uv/python/cpython-3.11-linux-x86_64-gnu/bin/pip install \
        --no-cache-dir \
        --no-deps \
        --target /usr/local/lib/hermes-agent/venv/lib/python3.11/site-packages \
        'python-telegram-bot==22.6'

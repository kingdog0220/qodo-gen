FROM node:24-bookworm-slim

# qodo が必要とする最小ツール
RUN apt-get update && apt-get install -y \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# qodo CLI をグローバルインストール
RUN npm install -g --ignore-scripts @qodo/command \
    && npm cache clean --force

# 非特権ユーザーを作成して作業ディレクトリをセット
RUN useradd -m dev && chown -R dev:dev /home/dev

# entrypoint スクリプトを printf で作成（CRLF 問題を完全に回避）
RUN printf '#!/bin/bash\nif [ -f /work/.env ]; then\n  set -a\n  . /work/.env\n  set +a\nfi\nexec bash -l\n' > /entrypoint.sh && \
    chmod +x /entrypoint.sh

# git へのフルパスを明示的に指定（qodo が必要とする場合に対応）
ENV GIT_EXEC_PATH=/usr/bin
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH

USER dev
WORKDIR /work

# entrypoint スクリプトを使用
ENTRYPOINT ["/entrypoint.sh"]

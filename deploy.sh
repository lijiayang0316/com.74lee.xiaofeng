#!/bin/bash
# 小风桶装水 - 部署脚本

set -e

PROJECT_NAME="com.74lee.xiaofeng"
PORT=9002
DOMAIN="xiaofeng.74lee.com"
PROJECT_DIR="$HOME/Desktop/com.74lee/$PROJECT_NAME"
SERVICE_NAME="$PROJECT_NAME.service"

echo "=== 小风桶装水部署开始 ==="

# 安装依赖
cd "$PROJECT_DIR"
python3 -m venv .venv
.venv/bin/pip install --upgrade pip -q
.venv/bin/pip install flask gunicorn -q

# 配置 systemd 服务
sudo tee /etc/systemd/system/$SERVICE_NAME > /dev/null <<EOF
[Unit]
Description=Xiaofeng bottled water website
After=network.target

[Service]
Type=simple
WorkingDirectory=$PROJECT_DIR
ExecStart=$PROJECT_DIR/.venv/bin/gunicorn -b 127.0.0.1:$PORT app:app
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_NAME
sudo systemctl restart $SERVICE_NAME

# 配置 Nginx
sudo tee /etc/nginx/sites-available/$DOMAIN > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN;
    location / {
        proxy_pass http://127.0.0.1:$PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

# 启用站点
sudo ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx

sudo systemctl --no-pager --full status $SERVICE_NAME

echo "=== 部署完成 ==="
echo "访问地址: http://$DOMAIN"

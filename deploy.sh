#!/bin/bash
# 小凤桶装水 - 部署脚本

PROJECT_NAME="com.74lee.xiaofeng"
PORT=9002
DOMAIN="xiaofeng.74lee.com"

echo "=== 小凤桶装水部署开始 ==="

# 安装依赖
cd ~/Desktop/com.74lee/$PROJECT_NAME
pip3 install flask gunicorn -q

# 停止旧服务
pm2 stop $PROJECT_NAME 2>/dev/null || true
pm2 delete $PROJECT_NAME 2>/dev/null || true

# 启动新服务
pm2 start python3 --name "$PROJECT_NAME" -- serve

# 等待服务启动
sleep 2

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

echo "=== 部署完成 ==="
echo "访问地址: http://$DOMAIN"

#!/bin/bash

# --- 配置 ---
QB_URL=$QBITTORRENT_URL           # qBittorrent Web UI 地址
QB_USERNAME=$$QBITTORRENT_USER    # 替换为你的用户名
QB_PASSWORD=$QBITTORRENT_PASSWORD # 替换为你的密码

# 多个Tracker列表URL (数组)
TRACKERS_LIST_URLS=(
  "https://cf.trackerslist.com/all.txt"
  # 可以添加更多URL
)

# 这里添加自定义tracker，每行一个
CUSTOM_TRACKERS=$(
  cat <<EOF
EOF
)

# --- 获取 tracker 列表 ---
echo "正在获取 tracker 列表..."
ALL_TRACKERS=""

# 遍历每个URL获取trackers
for URL in "${TRACKERS_LIST_URLS[@]}"; do
  echo "从 $URL 获取trackers..."

  if curl -s "$URL" >/dev/null; then # 检测是否可以访问
    NEW_TRACKERS=$(curl -s "$URL" | sed '/^$/d')

    if [ -n "$NEW_TRACKERS" ]; then
      # 将新获取的trackers添加到现有列表
      if [ -z "$ALL_TRACKERS" ]; then
        ALL_TRACKERS="$NEW_TRACKERS"
      else
        ALL_TRACKERS="$ALL_TRACKERS"$'\n'"$NEW_TRACKERS"
      fi
      echo "成功从 $URL 获取tracker列表"
    else
      echo "从 $URL 获取的tracker列表为空"
    fi
  else
    echo "无法访问 $URL，跳过"
  fi
done

# 检查是否成功获取了任何tracker
if [ -z "$ALL_TRACKERS" ]; then
  echo "从所有URL获取Trackers失败，退出"
  exit 1
fi

# 处理自定义trackers
if [ -n "$CUSTOM_TRACKERS" ]; then
  ALL_TRACKERS="$ALL_TRACKERS"$'\n'"$CUSTOM_TRACKERS"
  echo "已添加自定义trackers"
fi

# 去重并排序所有trackers (使用内存中的变量)
TRACKERS=$(echo "$ALL_TRACKERS" | sort -u)

# 统计获取的tracker数量
TRACKER_COUNT=$(echo "$TRACKERS" | wc -l)
echo "总共获取到 $TRACKER_COUNT 个唯一的tracker"

# 创建会话 Cookie 存储（在内存中）
echo "正在登录 qBittorrent..."
QB_COOKIE=$(curl -s -i -d "username=$QB_USERNAME&password=$QB_PASSWORD" "$QB_URL/api/v2/auth/login" | grep -i "set-cookie" | cut -d ":" -f 2-)

if [ -z "$QB_COOKIE" ]; then
  echo "登录失败: 未能获取 Cookie"
  exit 1
fi

QB_VERSION=$(curl -s -H "Cookie: $QB_COOKIE" "$QB_URL/api/v2/app/version")
echo "qBittorrent 版本: $QB_VERSION"

# --- 构建 JSON 体 ---
# qBittorrent 期望 add_trackers 是一个以换行符分隔的字符串
TRACKERS_ESCAPED=$(echo "$TRACKERS" | sed 's/"/\\"/g')
JSON_DATA="{\"add_trackers_enabled\":true,\"add_trackers\":\"$TRACKERS_ESCAPED\"}"

# --- 发送配置 ---
echo "正在更新 Trackers..."
STATUS_CODE=$(curl -s -w "%{http_code}" \
  -X POST \
  -H "Cookie: $QB_COOKIE" \
  -d "json=$JSON_DATA" \
  "$QB_URL/api/v2/app/setPreferences" \
  -o /dev/null)

if [ "$STATUS_CODE" -eq 200 ]; then
  echo "Trackers 更新成功"
else
  echo "Trackers 更新失败，状态码: $STATUS_CODE"
fi

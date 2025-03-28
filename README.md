# qBittorrent Trackers 自动更新脚本

提供了一个自动化脚本，用于更新 qBittorrent 的 Trackers 列表，以提高 BT 下载的连接性和速度，脚本可以配合青龙面板实现定时运行

## 功能特点

- 支持从多个来源获取最新 Trackers 列表
- 支持添加自定义 Trackers
- 支持自动去重 Trackers
- 与 qBittorrent Web API 集成

## 使用教程

### 通过 ql repo 使用脚本（推荐）

在青龙面板里，添加订阅任务：
```bash
ql repo https://github.com/yourusername/qinglong_update_qbittorrent_trackers.git
```

在青龙面板中添加以下环境变量：

1. 进入 **环境变量** 页面
2. 点击 **新建变量** 按钮，添加以下变量：

| 名称                          | 值                                        | 说明                                                                                          |
| ----------------------------- | ----------------------------------------- | --------------------------------------------------------------------------------------------- |
| `QBITTORRENT_URL`             | `http://your-qbittorrent-host:port`       | qBittorrent Web UI 地址                                                                       |
| `QBITTORRENT_USER`            | `用户名`                                  | qBittorrent 登录用户名                                                                        |
| `QBITTORRENT_PASSWORD`        | `密码`                                    | qBittorrent 登录密码                                                                          |
| `QBITTORRENT_TRACKER_URLS`    | `https://url1.com;https://url2.com`       | Tracker 来源列表，使用分号分隔多个 URL (可选，默认值为 `https://cf.trackerslist.com/all.txt`) |
| `QBITTORRENT_CUSTOM_TRACKERS` | `http://tracker1.com;http://tracker2.com` | 自定义 Tracker，使用分号分隔 (可选，默认为空)                                                 |

### 手动添加脚本

1. 登录到青龙面板
2. 进入 **脚本管理** 页面
3. 点击 **添加脚本** 按钮
4. 将 `update_qbittorrent_trackers.sh` 的内容复制粘贴到编辑器中
5. 保存脚本，如 `update_qbittorrent_trackers.sh`

### 定时规则示例

| 示例           | 说明             |
| -------------- | ---------------- |
| `0 3 * * *`    | 每天凌晨3点执行  |
| `0 */12 * * *` | 每12小时执行一次 |
| `0 0 * * 1`    | 每周一凌晨执行   |
| `0 0 1 * *`    | 每月1日凌晨执行  |

### 变量格式说明

1. **QBITTORRENT_URL**: 
    - 格式：`http://主机地址:端口号` 或 `https://主机地址:端口号`
    - 例子：`http://192.168.1.100:8080` 或 `https://qbittorrent.example.com`

2. **QBITTORRENT_TRACKER_URLS**:
    - 格式：使用分号(;)分隔的URL列表
    - 例子：`https://cf.trackerslist.com/all.txt;https://newtrackon.com/api/all`
    - 默认值：`https://cf.trackerslist.com/all.txt`

3. **QBITTORRENT_CUSTOM_TRACKERS**:
    - 格式：使用分号(;)分隔的Tracker URL列表
    - 例子：`udp://tracker.example1.com:6969;http://tracker.example2.com:80`

## 注意事项

- 确保您的 qBittorrent 实例可以从青龙面板所在的网络访问
- Web UI 需要启用，并确保用户名和密码配置正确
- 如果遇到连接问题，请检查 qBittorrent 的 Web UI 设置和防火墙规则

## 排障指南

- 如果脚本无法登录到 qBittorrent，请检查 URL、用户名和密码设置
- 如果无法获取 Trackers，请检查 Tracker URL 是否有效且可访问
- 在青龙面板的日志页面查看脚本执行日志以获取更详细的问题信息
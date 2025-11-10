# 前端架构设计

## 沙盒目录结构

```

/AppSandbox/
├── db/
│   └── app_data.db         ← 主 SQLite 数据库（所有业务数据）
│
├── files/
│   ├── images/             ← 用户拍照或选择的图片文件
│   ├── audio/              ← 用户录音文件
│   └── doc/                ← 文档文件（pdf，word, excel)等
|       |----pdf/
|       |----word/
|       |----execel/
|       ......
│
├── config/
│   └── settings.json       ← 本地配置、偏好设置（语言、主题等）
│
└── secure/
    └── key_store/          ← 加密密钥或敏感数据
```

## 个人健康数据

1. 只需要一张表（目前只考虑单用户）
2. 表的结构如下
3. 用户输入的文本可以存储成文件，同样需要填上标注信息
4. 用户原始文件会把地址存放在书库里面，需要时可以显示原始文件

```sql
CREATE TABLE health_asset (
  id INTEGER PRIMARY KEY AUTOINCREMENT,

  -- 基本文件信息
  filename TEXT NOT NULL,           -- 原始文件名
  path TEXT NOT NULL,               -- 沙盒内相对路径
  mime TEXT,                        -- 文件类型 (image/png, audio/mp3, etc)
  size_bytes INTEGER,               -- 文件大小
  hash_sha256 TEXT,                 -- 文件校验或去重标识

  -- 可检索的“人工标注”字段（关键）
  data_source TEXT,                 -- 来源: camera / wearable / manual / voice / download
  note TEXT,                        -- 用户手动注释
  tags TEXT,                        -- 逗号分隔标签, 例如 "血压, 晚上, 手动"
  -- 其它标注信息待设计

  -- 原始采集方式的附加元信息
  metadata_json TEXT,               -- 存放额外设备数据或原始JSON

  -- 通用时间字段
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

```

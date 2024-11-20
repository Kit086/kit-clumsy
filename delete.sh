#!/bin/bash

# 默认值
IFACE=""

# 解析参数
while getopts ":i:" opt; do
  case $opt in
    i) IFACE="$OPTARG" ;;    # 网卡名
    \?) echo "无效参数: -$OPTARG" >&2; exit 1 ;;
    :) echo "选项 -$OPTARG 需要一个值" >&2; exit 1 ;;
  esac
done

# 检查参数是否齐全
if [ -z "$IFACE" ]; then
  echo "用法: $0 -i <网卡名>"
  exit 1
fi

# 删除所有 tc 和 iptables 规则
sudo tc qdisc del dev $IFACE root
sudo iptables -t mangle -F

echo "已清除 $IFACE 上的所有网络配置"

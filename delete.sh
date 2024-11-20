#!/bin/bash

# 默认值
IFACE=""

# 参数解析
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

# 删除上行规则
echo "清除上行流量规则 (dev $IFACE)..."
sudo tc qdisc del dev $IFACE root 2>/dev/null
sudo tc qdisc del dev $IFACE ingress 2>/dev/null

# 删除下行规则
echo "清除下行流量规则 (ifb0)..."
sudo tc qdisc del dev ifb0 root 2>/dev/null

# 关闭 ifb0 接口
echo "关闭 ifb0 接口..."
sudo ip link set ifb0 down

# 删除 iptables 规则
echo "清除 iptables 规则..."
sudo iptables -t mangle -F

echo "所有网络限制已清除！"

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
if sudo tc qdisc del dev $IFACE root 2>/dev/null; then
  echo "已清除 $IFACE 的 root 配置"
else
  echo "未发现 $IFACE 的 root 配置"
fi

if sudo tc filter del dev $IFACE protocol ip parent 1:0 prio 1 handle 1 fw 2>/dev/null; then
  echo "已清除 $IFACE 的 filter 配置"
else
  echo "未发现 $IFACE 的 filter 配置"
fi

if sudo tc qdisc del dev $IFACE ingress 2>/dev/null; then
  echo "已清除 $IFACE 的 ingress 配置"
else
  echo "未发现 $IFACE 的 ingress 配置"
fi

# 删除下行规则
echo "清除下行流量规则 (ifb0)..."
if sudo tc qdisc del dev ifb0 root 2>/dev/null; then
  echo "已清除 ifb0 的 root 配置"
else
  echo "未发现 ifb0 的 root 配置"
fi

if sudo tc filter del dev ifb0 protocol ip parent 20:0 prio 1 handle 2 fw 2>/dev/null; then
  echo "已清除 ifb0 的 filter 配置"
else
  echo "未发现 ifb0 的 filter 配置"
fi

# 关闭 ifb0 接口
echo "关闭 ifb0 接口..."
if sudo ip link set ifb0 down 2>/dev/null; then
  echo "ifb0 接口已关闭"
else
  echo "ifb0 接口未启用或已关闭"
fi

# 删除 iptables 规则
echo "清除 iptables 规则..."
if sudo iptables -t mangle -F; then
  echo "已清除 iptables 中的 mangle 规则"
else
  echo "未发现 iptables 中的 mangle 规则"
fi

echo "所有网络限制已清除！"

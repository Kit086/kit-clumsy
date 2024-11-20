#!/bin/bash

# 默认值
IFACE=""

# 参数解析
while getopts ":i:" opt; do
  case $opt in
    i) IFACE="$OPTARG" ;;    # 网卡名
    \?) echo "无效参数: -$OPTARG" >&2; exit 1 ;;
    :) echo "选项 -$OPTARG" 需要一个值 >&2; exit 1 ;;
  esac
done

# 检查参数是否齐全
if [ -z "$IFACE" ]; then
  echo "用法: $0 -i <网卡名>"
  exit 1
fi

# 检查上行流量规则
echo "检查上行流量规则 (dev $IFACE):"
UP_RULES=$(sudo tc qdisc show dev "$IFACE" 2>/dev/null)
if [ -n "$UP_RULES" ]; then
  echo "$UP_RULES"
else
  echo "未发现 $IFACE 上的 qdisc 配置"
fi

UP_CLASSES=$(sudo tc class show dev "$IFACE" 2>/dev/null)
if [ -n "$UP_CLASSES" ]; then
  echo "$UP_CLASSES"
else
  echo "未发现 $IFACE 上的 class 配置"
fi

UP_FILTERS=$(sudo tc filter show dev "$IFACE" 2>/dev/null)
if [ -n "$UP_FILTERS" ]; then
  echo "$UP_FILTERS"
else
  echo "未发现 $IFACE 上的 filter 配置"
fi

# 检查下行流量规则
echo ""
echo "检查下行流量规则 (ifb0):"
DOWN_RULES=$(sudo tc qdisc show dev ifb0 2>/dev/null)
if [ -n "$DOWN_RULES" ]; then
  echo "$DOWN_RULES"
else
  echo "未发现 ifb0 上的 qdisc 配置"
fi

DOWN_CLASSES=$(sudo tc class show dev ifb0 2>/dev/null)
if [ -n "$DOWN_CLASSES" ]; then
  echo "$DOWN_CLASSES"
else
  echo "未发现 ifb0 上的 class 配置"
fi

DOWN_FILTERS=$(sudo tc filter show dev ifb0 2>/dev/null)
if [ -n "$DOWN_FILTERS" ]; then
  echo "$DOWN_FILTERS"
else
  echo "未发现 ifb0 上的 filter 配置"
fi

# 检查 iptables 配置
echo ""
echo "检查 iptables 规则 (mangle 表):"
IPTABLES_RULES=$(sudo iptables -t mangle -L -v 2>/dev/null)
if [ -n "$IPTABLES_RULES" ]; then
  echo "$IPTABLES_RULES"
else
  echo "未发现 mangle 表中的 iptables 规则"
fi

#!/bin/bash

# 默认值
IFACE=""
SRC=""
DST=""
DELAY=""
LOSS=""
BANDWIDTH=""

# 解析参数
while getopts ":i:s:d:L:D:B:" opt; do
  case $opt in
    i) IFACE="$OPTARG" ;;    # 网卡名
    s) SRC="$OPTARG" ;;      # 源地址
    d) DST="$OPTARG" ;;      # 目标地址
    L) DELAY="$OPTARG" ;;    # 延迟
    D) LOSS="$OPTARG" ;;     # 丢包率
    B) BANDWIDTH="$OPTARG" ;;# 带宽
    \?) echo "无效参数: -$OPTARG" >&2; exit 1 ;;
    :) echo "选项 -$OPTARG 需要一个值" >&2; exit 1 ;;
  esac
done

# 检查参数是否齐全
if [ -z "$IFACE" ] || [ -z "$SRC" ] || [ -z "$DST" ] || [ -z "$DELAY" ] || [ -z "$LOSS" ] || [ -z "$BANDWIDTH" ]; then
  echo "用法: $0 -i <网卡名> -s <源地址> -d <目标地址> -L <延迟> -D <丢包率> -B <带宽>"
  exit 1
fi

# 配置 iptables 标记流量
sudo iptables -t mangle -A OUTPUT -s $SRC -d $DST -j MARK --set-mark 1

# 配置 tc 规则
sudo tc qdisc add dev $IFACE root handle 1: htb
sudo tc class add dev $IFACE parent 1: classid 1:1 htb rate $BANDWIDTH
sudo tc qdisc add dev $IFACE parent 1:1 handle 10: netem delay $DELAY loss $LOSS

# 将标记流量绑定到队列
sudo tc filter add dev $IFACE protocol ip parent 1:0 prio 1 handle 1 fw flowid 1:1

echo "配置已完成：网卡=$IFACE 源=$SRC 目标=$DST 延迟=$DELAY 丢包率=$LOSS 带宽=$BANDWIDTH"

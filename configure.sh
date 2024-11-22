#!/bin/bash

# 默认值
IFACE=""               # 网络接口
SRC=""                 # 源地址
DST=""                 # 目标地址
UP_DELAY="100ms"       # 上行延迟
DOWN_DELAY="100ms"     # 下行延迟
UP_BANDWIDTH="128kbit" # 上行带宽
DOWN_BANDWIDTH="512kbit" # 下行带宽
LOSS="0%"              # 丢包率
JITTER="0ms"           # 抖动

# 参数解析
while getopts ":i:s:d:U:D:B:b:J:L:" opt; do
  case $opt in
    i) IFACE="$OPTARG" ;;         # 网卡名
    s) SRC="$OPTARG" ;;           # 源地址
    d) DST="$OPTARG" ;;           # 目标地址
    U) UP_DELAY="$OPTARG" ;;      # 上行延迟
    D) DOWN_DELAY="$OPTARG" ;;    # 下行延迟
    B) UP_BANDWIDTH="$OPTARG" ;;  # 上行带宽
    b) DOWN_BANDWIDTH="$OPTARG" ;;# 下行带宽
    J) JITTER="$OPTARG" ;;        # 抖动
    L) LOSS="$OPTARG" ;;          # 丢包率
    \?) echo "无效参数: -$OPTARG" >&2; exit 1 ;;
    :) echo "选项 -$OPTARG 需要一个值" >&2; exit 1 ;;
  esac
done

# 检查参数是否齐全
if [ -z "$IFACE" ] || [ -z "$SRC" ] || [ -z "$DST" ]; then
  echo "用法: $0 -i <网卡名> -s <源地址> -d <目标地址> -U <上行延迟> -D <下行延迟> -B <上行带宽> -b <下行带宽> -J <抖动> -L <丢包率>"
  exit 1
fi

# 调用 delete.sh 清理旧规则
echo "调用 delete.sh 清理旧规则..."
bash delete.sh -i "$IFACE"

# 启用 ifb 模块
sudo modprobe ifb || { echo "无法加载 ifb 模块，请检查内核支持"; exit 1; }
sudo ip link set ifb0 up || { echo "无法启用 ifb0 接口，请检查 ifb 模块是否正常"; exit 1; }

# 配置出站流量限制（船舶 -> 卫星）
echo "配置上行规则（船舶 -> 卫星）..."
sudo iptables -t mangle -A OUTPUT -s "$SRC" -d "$DST" -j MARK --set-mark 1
sudo tc qdisc add dev "$IFACE" root handle 1: htb
sudo tc class add dev "$IFACE" parent 1: classid 1:1 htb rate "$UP_BANDWIDTH" ceil "$UP_BANDWIDTH"
sudo tc qdisc add dev "$IFACE" parent 1:1 handle 10: netem delay "$UP_DELAY" "$JITTER" loss "$LOSS"
sudo tc filter add dev "$IFACE" protocol ip parent 1:0 prio 1 handle 1 fw flowid 1:1

# 配置入站流量限制（卫星 -> 船舶）
echo "配置下行规则（卫星 -> 船舶）..."
sudo iptables -t mangle -A PREROUTING -s "$DST" -d "$SRC" -j MARK --set-mark 2
sudo tc qdisc add dev "$IFACE" ingress
sudo tc filter add dev "$IFACE" parent ffff: protocol ip handle 2 fw action mirred egress redirect dev ifb0
sudo tc qdisc add dev ifb0 root handle 20: htb
sudo tc class add dev ifb0 parent 20: classid 20:1 htb rate "$DOWN_BANDWIDTH" ceil "$DOWN_BANDWIDTH"
sudo tc qdisc add dev ifb0 parent 20:1 handle 30: netem delay "$DOWN_DELAY" "$JITTER" loss "$LOSS"
sudo tc filter add dev ifb0 protocol ip parent 20:0 prio 1 handle 2 fw flowid 20:1

echo "船舶卫星网络环境模拟完成：网卡=$IFACE 源=$SRC 目标=$DST"
echo "上行：延迟=$UP_DELAY 带宽=$UP_BANDWIDTH 丢包率=$LOSS 抖动=$JITTER"
echo "下行：延迟=$DOWN_DELAY 带宽=$DOWN_BANDWIDTH 丢包率=$LOSS 抖动=$JITTER"

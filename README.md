# kit-satnet-simulator

## 用法示例

### 0. 赋予脚本可执行权限
为脚本赋予可执行权限：
```bash
sudo chmod +x configure.sh check.sh delete.sh
```

### 1. 配置网络规则
```bash
bash configure_netem.sh -i ens33 -s 192.168.18.202 -d 192.168.18.204 -L 5000ms -D 90% -B 10kbps
```

### 2. 检查当前网络配置
```bash
bash check_netem.sh -i ens33
```

### 3. 删除网络配置
```bash
bash delete_netem.sh -i ens33
```

---

## TODO

- [ ] 目前上行和下行的带宽、延迟、丢包率等参数是一致的，可以考虑分别配置，以更加贴近真实网络环境
- [ ] 无法模拟动态变化的网络环境（如突发拥塞、瞬时抖动等）

## Other

如果需要更复杂的动态网络条件，可以考虑搭配专用的网络测试工具，如 Chaos Mesh 或 WANem。

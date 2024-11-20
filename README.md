# kit-satnet-simulator

## 用法示例

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

## 赋予脚本可执行权限
为脚本赋予可执行权限：
```bash
sudo chmod +x configure.sh check.sh delete.sh
```

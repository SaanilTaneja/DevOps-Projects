#!/bin/bash

output_file="hang_diagnosis_$(date +%Y%m%d_%H%M%S).log"
echo "=== Server Hang Diagnostic Script ===" | tee "$output_file"

# Reboot time
last_reboot_time=$(who -b | awk '{print $3" "$4}')
reboot_epoch=$(date -d "$last_reboot_time" +%s)
echo "[+] Last reboot time: $last_reboot_time ($reboot_epoch)" | tee -a "$output_file"

# Log file analysis
log_file="/var/log/messages"
keywords=(
  "kernel panic" "Out of memory" "oom-killer" "hung task" "I/O error"
  "segfault" "BUG:" "Call Trace:" "soft lockup" "hard lockup"
  "watchdog" "not tainted" "blocked for more than"
)

echo -e "\n== Analyzing /var/log/messages (pre-reboot) ==" | tee -a "$output_file"
if [[ -f $log_file ]]; then
  while read -r line; do
    ts_string=$(echo "$line" | awk '{print $1" "$2" "$3}')
    log_epoch=$(date -d "$ts_string" +%s 2>/dev/null)
    if [[ ! -z "$log_epoch" && "$log_epoch" -lt "$reboot_epoch" ]]; then
      for keyword in "${keywords[@]}"; do
        if echo "$line" | grep -qi "$keyword"; then
          echo "$line" | tee -a "$output_file"
          break
        fi
      done
    fi
  done < "$log_file"
else
  echo "[-] $log_file not found." | tee -a "$output_file"
fi

# Journal logs (if available)
echo -e "\n== Analyzing journal logs from previous boot ==" | tee -a "$output_file"
if [ -d /var/log/journal ]; then
  journalctl --boot=-1 | grep -iE "$(IFS=\|; echo "${keywords[*]}")" | tee -a "$output_file"
  journalctl --boot=-1 > previous-boot.log
  echo "[+] Saved full previous boot logs to previous-boot.log"
else
  echo "[-] Persistent journal not found. Enable with:" | tee -a "$output_file"
  echo "    sudo mkdir -p /var/log/journal && sudo systemd-tmpfiles --create --prefix /var/log/journal && sudo systemctl restart systemd-journald" | tee -a "$output_file"
fi

# Kdump check
echo -e "\n== Checking for crash dumps ==" | tee -a "$output_file"
if [ -d /var/crash ] && ls /var/crash/*/vmcore &>/dev/null; then
  echo "[!] Crash dump found in /var/crash" | tee -a "$output_file"
  ls -lh /var/crash/ | tee -a "$output_file"
else
  echo "[-] No crash dump found in /var/crash. Is kdump enabled?" | tee -a "$output_file"
fi

# Dmesg scan
echo -e "\n== Scanning dmesg for hardware/kernel issues ==" | tee -a "$output_file"
dmesg | grep -iE "error|warn|fail|hang|timeout|raid|acpi|firmware" | tee -a "$output_file"

# Filesystem/mount issues
echo -e "\n== Checking for EXT or mount errors ==" | tee -a "$output_file"
grep -iE "EXT4-fs|mount|superblock|remount" "$log_file" | tee -a "$output_file"

# Pressure Stall Info
echo -e "\n== Pressure Stall Info (PSI) metrics ==" | tee -a "$output_file"
for type in cpu io memory; do
  echo "[PSI - $type]" | tee -a "$output_file"
  cat /proc/pressure/$type | tee -a "$output_file"
done

# Realtime health checks
echo -e "\n== Realtime System Health Snapshot ==" | tee -a "$output_file"

echo -e "\n[+] Memory & Swap:" | tee -a "$output_file"
free -h | tee -a "$output_file"

echo -e "\n[+] Top CPU processes:" | tee -a "$output_file"
ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%cpu | head -n 6 | tee -a "$output_file"

echo -e "\n[+] Top Memory processes:" | tee -a "$output_file"
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6 | tee -a "$output_file"

# Disk I/O
echo -e "\n[+] Disk I/O Stats:" | tee -a "$output_file"
if command -v iostat &> /dev/null; then
  iostat -xz 1 3 | tee -a "$output_file"
else
  echo "[-] iostat not installed. sudo dnf install sysstat" | tee -a "$output_file"
fi

# SMART
echo -e "\n[+] SMART disk health check:" | tee -a "$output_file"
if command -v smartctl &> /dev/null; then
  for disk in /dev/sd?; do
    echo "== SMART status for $disk ==" | tee -a "$output_file"
    smartctl -H "$disk" | tee -a "$output_file"
  done
else
  echo "[-] smartctl not installed. sudo dnf install smartmontools" | tee -a "$output_file"
fi

# Network errors
echo -e "\n[+] Network stats:" | tee -a "$output_file"
ip -s link | tee -a "$output_file"

# Audit log scan
echo -e "\n== Checking audit logs for segfaults / SELinux AVC ==" | tee -a "$output_file"
grep -iE "segfault|avc:" /var/log/audit/audit.log | tail -n 20 | tee -a "$output_file"

# HPE IML logs
echo -e "\n== Checking HPE Integrated Management Logs (IML) ==" | tee -a "$output_file"
if command -v hpasmcli &>/dev/null; then
  hpasmcli -s "show iml" | tee -a "$output_file"
else
  echo "[-] hpasmcli not found. Install from HPE SDR repo." | tee -a "$output_file"
fi

echo -e "\n[✓] Full diagnostics complete. Summary saved to: $output_file"

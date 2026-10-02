#!/bin/bash
# Profiles the JS thread while scrolling the current tab. Needs a rooted emulator (adb root).
PKG=com.tantie100.rnssetsizerepro
PID=$(adb shell pidof $PKG | tr -d '\r')
JS=$(adb shell "grep -l mqt_v_js /proc/$PID/task/*/comm" | tr -d '\r' | head -1 | sed -E 's#.*/task/([0-9]+)/comm#\1#')
before=$(adb shell "cat /proc/$PID/task/$JS/stat" | awk '{print $14+$15}')
adb shell "simpleperf record -e cpu-clock -p $PID -g -f 4000 --duration 7 -o /data/local/tmp/repro.data >/dev/null 2>&1" &
sleep 0.7
for i in 1 2 3; do adb shell input swipe 540 1700 540 600 250; sleep 0.8; done
for i in 1 2 3; do adb shell input swipe 540 700 540 1800 250; sleep 0.8; done
wait
after=$(adb shell "cat /proc/$PID/task/$JS/stat" | awk '{print $14+$15}')
echo "JS thread CPU during six swipes: $(( (after - before) * 10 )) ms"
adb shell "simpleperf report -i /data/local/tmp/repro.data --tids $JS --children --sort symbol 2>/dev/null" |
  grep -E "fmod$|flushStateUpdates|layoutTree|ShadowTree::commit" | awk '{print $1, $3}'

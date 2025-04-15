from flask import Flask, render_template_string, request, redirect, url_for
import json
import os
import subprocess
import socket
from collections import defaultdict

app = Flask(__name__)
DEVICE_FILE = "devices.json"

def load_devices():
    if not os.path.exists(DEVICE_FILE):
        return []
    with open(DEVICE_FILE) as f:
        return json.load(f)

def save_devices(devices):
    with open(DEVICE_FILE, "w") as f:
        json.dump(devices, f, indent=2)

def is_online(ip):
    try:
        socket.setdefaulttimeout(1)
        socket.create_connection((ip, 22))
        return True
    except:
        return False

def get_status(ip):
    try:
        output = subprocess.check_output(["ssh", f"pi@{ip}", "cat /home/pi/status.json"], timeout=5)
        print(f"✅ JSON from {ip}: {output.decode()}")
        return json.loads(output)
    except Exception as e:
        print(f"❌ Failed to fetch status from {ip}: {e}")
        return {}

HTML = """
<!DOCTYPE html>
<html>
<head>
  <title>Pi Control Panel</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <style>
    body { background: #121212; color: #eee; font-family: sans-serif; padding: 20px; }
    table { width: 100%; border-collapse: collapse; margin-bottom: 30px; }
    th, td { padding: 10px; border: 1px solid #444; text-align: center; }
    th { background: #222; }
    .online { color: #00ff66; }
    .offline { color: #ff4444; }
  </style>
</head>
<body>
  <h1 style="color:#66c0ff;">📡 Raspberry Pi Panel</h1>
  <form method="post" action="/batch">
    <button type="submit" name="action" value="status">📡 Status</button>
    <button type="submit" name="action" value="update">📥 Update</button>
    <button type="submit" name="action" value="reboot">🔁 Reboot</button>
    <button type="submit" name="action" value="sdcheck">💾 SD Check</button>
    {% for region, groups in regions.items() %}
      <h2>📍 {{ region }}</h2>
      {% for group, devs in groups.items() %}
        <h3>🔹 {{ group }}</h3>
        <table>
          <tr><th>✓</th><th>Hostname</th><th>Status</th><th>HDMI</th><th>Ανάλυση</th><th>Ενέργειες</th></tr>
          {% for device in devs %}
          <tr>
            <td><input type="checkbox" name="targets" value="{{ device.hostname }}"></td>
            <td>{{ device.hostname }}</td>
            <td>{% if device.online %}<span class="online">Online</span>{% else %}<span class="offline">Offline</span>{% endif %}</td>
            <td>{{ device.hdmi_port or "-" }}</td>
            <td>{{ device.hdmi_resolution or "-" }}</td>
            <td>
              <form style="display:inline;" action="/action/{{ device.hostname }}/status" method="post"><button>Status</button></form>
              <form style="display:inline;" action="/action/{{ device.hostname }}/reboot" method="post"><button>Reboot</button></form>
              <form style="display:inline;" action="/action/{{ device.hostname }}/update" method="post"><button>Update</button></form>
              <form style="display:inline;" action="/action/{{ device.hostname }}/sdcheck" method="post"><button>SD Check</button></form>
            </td>
          </tr>
          {% endfor %}
        </table>
      {% endfor %}
    {% endfor %}
  </form>
</body>
</html>
"""

@app.route("/", methods=["GET"])
def index():
    devices = load_devices()
    devices = sorted(devices, key=lambda x: x.get("hostname", "").upper())
    regions = defaultdict(lambda: defaultdict(list))

    for d in devices:
        region = d.get("region", "Άγνωστη")
        hostname = d.get("hostname", "").upper()

        # Ομαδοποίηση L/R
        if hostname.endswith("L"):
            group = "Left"
        elif hostname.endswith("R"):
            group = "Right"
        else:
            group = "Other"

        d["group"] = group
        d["online"] = is_online(d["ip"])
        if d["online"]:
            status = get_status(d["ip"])
            d["temperature"] = status.get("temperature", "-")
            d["ram"] = status.get("ram", "-")
            d["uptime"] = status.get("uptime", "-")

            # HDMI προστατευμένο
            hdmi_data = status.get("hdmi", [])
            if hdmi_data and isinstance(hdmi_data, list):
                connected = [x for x in hdmi_data if x.get("status") == "connected"]
                if connected:
                    d["hdmi_port"] = connected[0].get("port", "-")
                    d["hdmi_resolution"] = connected[0].get("resolution", "-")
                else:
                    d["hdmi_port"] = "-"
                    d["hdmi_resolution"] = "-"
            else:
                d["hdmi_port"] = "-"
                d["hdmi_resolution"] = "-"
        regions[region][group].append(d)

    return render_template_string(HTML, regions=regions)

@app.route("/add", methods=["POST"])
def add_device():
    new_device = {
        "hostname": request.form["hostname"],
        "ip": request.form["ip"],
        "group": request.form.get("group", ""),
        "region": request.form["region"]
    }
    devices = load_devices()
    devices.append(new_device)
    save_devices(devices)
    return redirect(url_for("index"))

@app.route("/action/<hostname>/<cmd>", methods=["POST"])
def action(hostname, cmd):
    devices = load_devices()
    for device in devices:
        if device["hostname"] == hostname:
            ip = device["ip"]
            if cmd == "status":
                subprocess.Popen(["ssh", f"pi@{ip}", "/home/pi/status.sh"])
            elif cmd == "reboot":
                subprocess.Popen(["ssh", f"pi@{ip}", "sudo reboot"])
            elif cmd == "update":
                subprocess.Popen(["ssh", f"pi@{ip}", "sudo apt update && sudo apt upgrade -y"])
            elif cmd == "sdcheck":
                subprocess.Popen(["ssh", f"pi@{ip}", "/home/pi/check_sd_health_telegram.sh"])
    return redirect(url_for("index"))

@app.route("/batch", methods=["POST"])
def batch():
    action = request.form["action"]
    targets = request.form.getlist("targets")
    devices = load_devices()
    for device in devices:
        if device["hostname"] in targets:
            ip = device["ip"]
            if action == "status":
                subprocess.Popen(["ssh", f"pi@{ip}", "/home/pi/status.sh"])
            elif action == "reboot":
                subprocess.Popen(["ssh", f"pi@{ip}", "sudo reboot"])
            elif action == "update":
                subprocess.Popen(["ssh", f"pi@{ip}", "sudo apt update && sudo apt upgrade -y"])
            elif action == "sdcheck":
                subprocess.Popen(["ssh", f"pi@{ip}", "/home/pi/check_sd_health_telegram.sh"])
    return redirect(url_for("index"))

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

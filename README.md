# UDP Port 8452 Manager (`port.sh`)

A simple bash utility for Ubuntu to open, close, and verify firewall rules and local listeners for **UDP port 8452**, allowing external players to connect directly without relying on a relay.

## Prerequisites

* **OS:** Ubuntu / Debian-based Linux distribution
* **Permissions:** `sudo` (root) privileges are required to modify firewall rules (`open` and `close` commands)
* **Dependencies:** `ufw` (Uncomplicated Firewall) and `iproute2` (`ss`). *Note: The script will automatically install `ufw` if it is missing.*

## Installation

1. Ensure the script is executable:
   ```bash
   chmod +x port.sh
   ```

## Usage

Run the script with one of the three available arguments: `open`, `close`, or `check`.

### 1. Open the Port
Enables UFW (safely allowing SSH first so you don't get locked out), adds an allow rule for `8452/udp`, and reloads the firewall.
```bash
sudo ./port.sh open
```

### 2. Check Port Status
Verifies whether the UFW firewall rule is active and checks if your game server is actively listening on UDP port 8452.
```bash
sudo ./port.sh check
```
*(Note: Your game or server must be actively hosting/running for a local listener to appear).*

### 3. Close the Port
Removes the `8452/udp` allow rule from UFW and reloads the firewall.
```bash
sudo ./port.sh close
```

---

## Important: Router Port Forwarding

Opening the port on your Ubuntu firewall is only half of the setup. Because UPnP and NAT-PMP are often disabled on home routers, you must also configure **Port Forwarding** in your router's admin panel:

1. Open your browser and navigate to your router's gateway address: `http://10.232.34.43`
2. Locate the **Port Forwarding** (or *Virtual Server / NAT*) section.
3. Add a new rule with the following settings:
   * **Protocol:** `UDP`
   * **External / WAN Port:** `8452`
   * **Internal / LAN IP:** `10.232.34.235`
   * **Internal / LAN Port:** `8452`
4. Save and apply the settings.

*(Remember to remove this rule from your router if you permanently close the port later.)*

## Troubleshooting

* **`check` shows no firewall rule:** Make sure UFW is active by running `sudo ufw status verbose`. If it shows `Status: inactive`, run `sudo ./port.sh open` to initialize it.
* **`check` shows no local listener:** Ensure your game server is currently running. Applications only bind to and listen on a port while they are actively running.
* **Local IP changed:** If your router assigns dynamic IPs via DHCP, verify your machine's IP hasn't changed from `10.232.34.235` by running `ip a`.

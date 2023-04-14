<h1 align="center">MyDNS</h1>
<p align="center">Use your local DNS server on Android</p>

## Disclaimer
I'm not an expert in Android nor in bash scripting.
The module was made mainly for personal use, all this can be done in 5 lines of code, the rest was added for flexibility.
If you have suggestions or improvements, don't hesitate to open an issue or pull request.

## Capabilities
This module allows you to:
- Run your local DNS server with any configuration
- Choose any upstream servers

## Installation
1. Install [Magisk](https://github.com/topjohnwu/Magisk)
2. Install [Termux](https://f-droid.org/packages/com.termux/)
3. Open Termux and install `dnsmasq`:
`pkg install root-repo && pkg install dnsmasq`
4. Download this module from releases tab
5. Install it via Magisk (make sure there's no warnings)
6. Reboot

## Configuration
- Open Termux and run `su`. Allow root access for Termux.
- Run `mydns config` and update the file to your needs.
- Run `mydns restart` for changes to take effect.
- Run `mydns` to check resource usage. If CPU usage is high, wait a minute and check again. If it's still high, please open an issue in this repository.

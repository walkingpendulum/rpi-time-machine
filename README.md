# rpi-time-machine

sources:
https://thatvirtualboy.com/2016/11/03/send-time-machine-backups-to-a-vm-hosted-in-windows/
https://www.howtogeek.com/276468/how-to-use-a-raspberry-pi-as-a-networked-time-machine-drive-for-your-mac/

### wi-if
sudo vi /etc/wpa_supplicant/wpa_supplicant.conf

here you insert something like
network={
    ssid="The_ESSID_from_earlier"
    psk="Your_wifi_password"
}
and then 
sudo wpa_cli reconfigure

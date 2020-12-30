

#disable_power_well:Disable display power wells when possible (-1=auto [default], 0=power wells always on, 1=power wells disabled when possible) (int)
echo "options i915 enable_fbc=1 enable_psr=1 enable_guc=2 edp_vswing=1 disable_power_well=1" >> /etc/modprobe.d/i915.conf

echo "options iwlwifi power_save=1 11n_disable=8 uapsd_disable=0 power_level=1" >> /etc/modprobe.d/iwlwifi.conf
echo "options iwlmvm power_scheme=3" >> /etc/modprobe.d/iwlwifi.conf
echo "options iwldvm force_cam=0" >> /etc/modprobe.d/iwlwifi.conf

echo "options snd_hda_intel power_save=1" >> /etc/modprobe.d/audio_powersave.conf
echo "options snd_ac97_codec power_save=1" >> /etc/modprobe.d/audio_powersave.conf
echo "blacklist snd_hda_codec_hdmi" >> /etc/modprobe.d/audio_powersave.conf

echo "w /sys/devices/system/cpu/cpufreq/policy?/energy_performance_preference - - - - balance_power" >> /etc/tmpfiles.d/energy_performance_preference.conf
echo "vm.dirty_writeback_centisecs = 1500" >> /etc/sysctl.d/dirty.conf
echo 'ACTION=="add", SUBSYSTEM=="net", KERNEL=="wl*", RUN+="/usr/bin/iw dev $name set power_save on"' >> /etc/udev/rules.d/81-wifi-powersave.rules
echo 'SUBSYSTEM=="pci", ATTR{power/control}="auto"' >> /etc/udev/rules.d/pci_pm.rules
echo 'ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"' >> /etc/udev/rules.d/50-usb_power_save.rules
echo 'ACTION=="add", SUBSYSTEM=="scsi_host", KERNEL=="host*", ATTR{link_power_management_policy}="med_power_with_dipm"' >> /etc/udev/rules.d/hd_power_save.rules
#iw dev wlp0s20f3 get power_save

echo "OPENCV_LOG_LEVEL=ERROR" >> /etc/environment
echo "LIBVA_DRIVER_NAME=iHD" >> /etc/environment
echo "MOZ_X11_EGL=1" >> /etc/environment
echo "MOZ_ACCELERATED=1" >> /etc/environment
echo "MOZ_WEBRENDER=1" >> /etc/environment
echo "MOZ_ENABLE_WAYLAND=1" >> /etc/environment

grubby --update-kernel=ALL --args="nmi_watchdog=0"
grubby --update-kernel=ALL --args="pcie_aspm.policy=powersupersave"
grubby --update-kernel=ALL --args="drm.vblankoffdelay=1"
grubby --update-kernel=ALL --args="usbcore.autosuspend=2"

grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
dracut --force

rpm --import https://packages.microsoft.com/keys/microsoft.asc
sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

curl -sL https://rpm.nodesource.com/setup_15.x | bash -

dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-33.noarch.rpm -y
dnf install https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-33.noarch.rpm -y
dnf install rpmfusion-free-release-tainted -y
dnf install rpmfusion-nonfree-release-tainted -y

dnf groupupdate core -y

dnf check-update
dnf install -y intel-gpu-tools powertop zsh mpv ffmpeg ffmpeg-libs remmina intel-media-driver libva libva-utils nodejs code gnome-power-manager util-linux-user acpica-tools sysfsutils iw btrfs-progs
gcc gcc-c++ glib glib-devel glibc glibc-devel glib2 glib2-devel libusb libusb-devel nss-devel pixman pixman-devel libX11 libX11-devel libXv libXv-devel gtk-doc libgusb libgusb-devel gobject-introspection gobject-introspection-devel cairo-devel ninja-build

dnf install -y gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel
dnf install -y lame\* --exclude=lame-devel
dnf group upgrade --with-optional Multimedia  -y

#Run below as user not root
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
#cp zshrc /home/bensanders/.zshrc 
#chown bensanders:bensanders .zshrc

export DISPLAY=:0
mpv
touch /home/bensanders/.config/mpv/mpv.conf
echo "profile=gpu-hq" >> /home/bensanders/.config/mpv/mpv.conf
echo "gpu-context=wayland" >> /home/bensanders/.config/mpv/mpv.conf
echo "hwdec=auto" >> /home/bensanders/.config/mpv/mpv.conf
echo "hwdec-codecs=all" >> /home/bensanders/.config/mpv/mpv.conf


sudo systemctl enable --now thermald

sudo usermod -a -G power bensanders

git clone https://github.com/intel/dptfxtract.git
cd dptfxtract
sudo acpidump > acpi.out
acpixtract -a acpi.out
sudo ./dptfxtract *.dat

sudo systemctl restart thermald.service
cd

sudo su
mkdir /opt/messages
cd /opt/messages
npm install -g nativefier

curl https://raw.githubusercontent.com/jiahaog/nativefier-icons/gh-pages/files/google-messages.png -o messages.png

nativefier --name 'Messages' 'https://messages.google.com/web/' --icon /opt/messages/messages.png --ignore-gpu-blacklist --enable-es3-apis 
chmod -R 755 /opt/messages/Messages-linux-x64/

touch /usr/share/applications/messages.desktop
echo "[Desktop Entry]" >> /usr/share/applications/messages.desktop
echo "Type=Application" >> /usr/share/applications/messages.desktop
echo "Encoding=UTF-8" >> /usr/share/applications/messages.desktop
echo "Name=Messages" >> /usr/share/applications/messages.desktop
echo "Comment=Messages" >> /usr/share/applications/messages.desktop
echo "Exec=/opt/messages/Messages-linux-x64/Messages" >> /usr/share/applications/messages.desktop
echo "Icon=/opt/messages/messages.png" >> /usr/share/applications/messages.desktop
echo "Terminal=false" >> /usr/share/applications/messages.desktop
echo "Categories=Network;GNOME" >> /usr/share/applications/messages.desktop
echo "StartupWMClass=messages-nativefier-ffa865" >> /usr/share/applications/messages.desktop
chmod +x /usr/share/applications/messages.desktop
chmod 644 /usr/share/applications/messages.desktop

mkdir /usr/share/fonts/WindowsFonts
cp Fonts/* /usr/share/fonts/WindowsFonts/
chmod 644 /usr/share/fonts/WindowsFonts/*
fc-cache --force

mkdir /usr/lib/x86_64-linux-gnu
mkdir /usr/lib/x86_64-linux-gnu/dri/
cp /home/bensanders/intel-media-driver-20.1.1/usr/lib/x86_64-linux-gnu/dri/iHD_drv_video.so /usr/lib/x86_64-linux-gnu/dri/iHD_drv_video.so

sudo sed -i 's/Exec=gnome-power-statistics/Exec=env GTK_THEME=Adwaita:light gnome-power-statistics/g' /usr/share/applications/org.gnome.PowerStats.desktop
sudo sed -i 's+Exec=firefox+Exec=env LIBVA_DRIVERS_PATH=/usr/lib/x86_64-linux-gnu/dri firefox+g' /usr/share/applications/firefox.desktop
#sudo sed -i 's+Exec=env LIBVA_DRIVERS_PATH=/usr/lib/x86_64-linux-gnu/dri firefox+Exec=firefox+g' /usr/share/applications/firefox.desktop

https://github.com/rafaelmardojai/firefox-gnome-theme


MOZ_LOG="PlatformDecoderModule:5" LIBVA_DRIVERS_PATH=/usr/lib/x86_64-linux-gnu/dri MOZ_ENABLE_WAYLAND=1 firefox



FROM ubuntu

# 设置时区为上海
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y tzdata && ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && dpkg-reconfigure --frontend noninteractive tzdata

# 安装必要的软件包
RUN apt update && apt upgrade -y && apt install -y \
    tzdata wine qemu-kvm fonts-wqy-zenhei xz-utils dbus-x11 curl firefox gnome-system-monitor mate-system-monitor git xfce4 xfce4-terminal tightvncserver wget sudo nano net-tools ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential \
    bzip2 ccache cmake cpio curl device-tree-compiler fastjar flex gawk gettext gcc-multilib g++-multilib \
    git gperf haveged help2man intltool libc6-dev-i386 libelf-dev libglib2.0-dev libgmp3-dev libltdl-dev \
    libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libreadline-dev libssl-dev libtool lrzsz \
    mkisofs msmtp nano ninja-build p7zip p7zip-full patch pkgconf python2.7 python3 python3-pyelftools \
    libpython3-dev qemu-utils rsync scons squashfs-tools subversion swig texinfo uglifyjs upx-ucl unzip \
    vim wget xmlto xxd zlib1g-dev python3-setuptools

# 配置 VNC
RUN wget https://github.com/novnc/noVNC/archive/refs/tags/v1.2.0.tar.gz
RUN tar -xvf v1.2.0.tar.gz
RUN mkdir  $HOME/.vnc
RUN echo 'fuckyou' | vncpasswd -f > $HOME/.vnc/passwd
RUN echo '/bin/env  MOZ_FAKE_NO_SANDBOX=1  dbus-launch startxfce4 &'  > $HOME/.vnc/xstartup
RUN chmod 600 $HOME/.vnc/passwd
RUN chmod 755 $HOME/.vnc/xstartup

# 设置默认键盘布局为美国英语
# RUN localectl set-keymap us

# 设置SSH服务
RUN apt install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:fuckyou' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN echo 'X11UseLocalhost no' >> /etc/ssh/sshd_config
CMD /usr/sbin/sshd -D

# 启动命令
RUN echo 'whoami ' >>/x.sh
RUN echo 'cd ' >>/x.sh
RUN echo "su -l -c 'vncserver :2000 -geometry 1360x768' "  >>/x.sh
RUN echo 'cd /noVNC-1.2.0' >>/x.sh
RUN echo './utils/launch.sh  --vnc localhost:7900 --listen 8900 ' >>/x.sh

# 启动Xfce桌面环境和Firefox
RUN echo 'startxfce4 &' >> /x.sh
RUN echo 'sleep 2' >> /x.sh
RUN echo 'firefox &' >> /x.sh

RUN chmod 755 /x.sh
EXPOSE 8900
CMD  /x.sh

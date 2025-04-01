# 基础镜像
FROM ubuntu:22.04

#定义时区参数
ENV TZ=Asia/Shanghai
#设置时区
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo '$TZ' > /etc/timezone

# 更换阿里云镜像源
RUN sed -i 's@http://archive.ubuntu.com/ubuntu/@http://mirrors.aliyun.com/ubuntu/@g' /etc/apt/sources.list && \
    sed -i 's@http://security.ubuntu.com/ubuntu/@http://mirrors.aliyun.com/ubuntu/@g' /etc/apt/sources.list

# 安装依赖
RUN apt-get update && apt-get install -y \
    # X11 
    xorg xauth \
    # 编译工具
    build-essential gdb cmake \
    # Qt 核心开发库
    qtbase5-dev qttools5-dev qtmultimedia5-dev qtdeclarative5-dev \
    # 其他必要依赖
    openssh-server \
    # OpenGL 支持
    mesa-common-dev libgl1-mesa-dev\
    # 清除缓存, 非必要可注释
    && rm -rf /var/lib/apt/lists/*

# 设置root密码
RUN echo 'root:0' | chpasswd 

# 设置SSH 
RUN mkdir /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    # sed -i 's/#AddressFamily any/AddressFamily inet/' /etc/ssh/sshd_config && \
    sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding yes/' /etc/ssh/sshd_config && \
    # sed -i 's/#X11UseLocalhost yes/X11UseLocalhost no/' /etc/ssh/sshd_config && \
    sed -i 's/#X11Forwarding yes/X11Forwarding yes/' /etc/ssh/sshd_config && \
    sed -i 's/#X11DisplayOffset 10/X11DisplayOffset 10/' /etc/ssh/sshd_config 
RUN rm -f /etc/ssh/ssh_host_rsa_key && \
    ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' && \
    mkdir -p /root/.ssh && \
    touch /root/.ssh/authorized_keys 

# 指定工作目录, 按需修改
RUN mkdir /home/code
# WORKDIR /home/code

# x11转发-ssh
RUN echo "export DISPLAY=host.docker.internal:0" >> ~/.bashrc \
    && echo "export XDG_RUNTIME_DIR=/run/user/$(id -u)" >> ~/.bashrc \
    && echo "export RUNLEVEL=3" >> ~/.bashrc

# x11转发-docker
ENV DISPLAY=host.docker.internal:0

# 容器启动时启动SSH服务
CMD ["/usr/sbin/sshd", "-D"]
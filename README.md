# win11 docker qt 环境, 基于 ubuntu 22.04, 生成的镜像可以直接通过vsc ssh 连接
# build
```
docker build -t qt_dev:ubuntu .
```

# run 按需修改 bind_path 和 /home/code
```
docker run  -it -d --name qt_dev -p 10022:22 -v $HOME\.ssh\id_rsa.pub:/root/.ssh/authorized_keys -v bind_path:/home/code qt_dev:ubuntu
```
*-it* 允许用户通过终端与容器交互

*-d* 以分离模式(Detached)运行容器, 使其在后台运行

*--name qt_dev* 将容器命名为 *qt_dev*

*-p 10022:22* 端口映射: 将宿主机的 *10022* 端口映射到容器的 *22* 端口(SSH 服务端口)

*-v $HOME\.ssh\id_rsa.pub:/root/.ssh/authorized_keys*

挂载宿主机的 *SSH* 公钥到容器的 *authorized_keys* 文件, Linux 改为 *$HOME/.ssh/id_rsa.pub*

*-v bind_path:/home/code* 将宿主机的目录 bind_path 挂载到容器的 /home/code 目录

*qt_dev:ubuntu* 指定使用的镜像名称及标签

# use ssh
```
ssh -XY root@localhost -p 10022
```

# ssh config
```
HostName 127.0.0.1
User root
Port 10022
ForwardX11 yes
ForwardX11Trusted yes
ForwardAgent yes
```
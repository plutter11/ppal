# 使用基础镜像
FROM ghcr.nju.edu.cn/parkervcp/installers:debian
# 将当前目录下的 install.sh 拷贝到容器内
COPY install.sh /root/install.sh

# 运行 install.sh
RUN chmod +x /root/install.sh && /root/install.sh

# 声明容器启动时执行的命令
CMD ["/bin/bash"]
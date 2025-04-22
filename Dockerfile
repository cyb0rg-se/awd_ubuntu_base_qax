FROM ubuntu:20.04

ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo '$TZ' > /etc/timezone

# 更新apt源为清华大学镜像源
RUN sed -i 's/http:\/\/archive.ubuntu.com\/ubuntu\//http:\/\/mirrors.tuna.tsinghua.edu.cn\/ubuntu\//g' /etc/apt/sources.list

# 更新软件包列表并安装软件
RUN apt-get update && \
    apt-get install -y openssh-server vim mysql-server apache2 php7.4 php7.4-mysql libapache2-mod-php7.4 net-tools iputils-ping curl python3

# 配置Apache以支持PHP
RUN a2enmod php7.4

# 配置 SSH
RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config

# 添加新用户ctf并设置密码为123456
RUN useradd -g www-data ctf -m && \
    echo "ctf:123456" | chpasswd

# 重置root密码为ikun666
RUN echo "root:ikun666" | chpasswd

# 更改/var/www/html目录及其内容的所有权为www-data用户和组，并设置权限
RUN chown -R ctf:www-data /var/www/html && \
    chmod 755 -R /var/www/html/*

# 设置MySQL用户权限
RUN service mysql start && \
    mysql -uroot -proot -e "CREATE USER 'ctf'@'%' IDENTIFIED BY '123456';" && \
    mysql -uroot -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'ctf'@'%' WITH GRANT OPTION;" && \
    mysql -uroot -proot -e "FLUSH PRIVILEGES;"

# 修改my.cnf，添加innodb_use_native_aio = 0配置项
RUN printf "\n[mysqld]\ninnodb_use_native_aio = 0\n" >> /etc/mysql/my.cnf
RUN sed -i 's/^bind-address/#bind-address/' /etc/mysql/my.cnf

# 提升系统AIO最大值
RUN echo "fs.aio-max-nr = 262144" >> /etc/sysctl.conf

EXPOSE 22 3306 80

# 删除Apache默认页面
RUN rm -rf /var/www/html/index.html

# 解析.开头隐藏文件
RUN echo '<FilesMatch "^\\.">\n    Require all granted\n</FilesMatch>' | tee -a /etc/apache2/apache2.conf

# 没有下面这行mysql报错，很诡异
RUN mkdir /nonexistent

COPY update_flag.sh /root/update_flag.sh
RUN chmod +x /root/update_flag.sh

# 启动脚本
CMD ["/root/update_flag.sh"]
# awd_ubuntu_base_qax

本镜像适用于所有awd竞赛的flag通过访问平台某接口获取，例如通过执行`curl -k https://${IP}/Getkey/index/index 2>/dev/null`来获取flag

镜像仅支持php题目

环境配置信息如下：

ssh端口22，支持远程登录

root/ikun666

ctf/123456

mysql端口3306

ctf/123456

能够解析.开头的隐藏文件，例如`.index.php`

容器运行自动调用update_flag.sh检测ssh，mysql以及apache2服务是否正常

之后每5s调用请求flag命令，将flag保存在环境变量$QAXFLAG和/flag文件中
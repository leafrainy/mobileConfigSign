# mobileConfigSign
主要用于iOS获取UDID的描述文件mobileconfig的签名
# 依赖

openssl

# 食用

```
#仅支持nginx下的ssl证书
#使用前请将https站点的对应证书key和crt文件放置到sign文件夹下，均重命名为server
#将生成的原始的moblieconfig文件放置到sign文件夹下，命名为unsigned.mobileconfig

chmod +x mobileConfigSign.sh
./mobileConfigSign.sh

```

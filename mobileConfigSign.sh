#!/bin/bash
#leafrainy
#leafrainy.cc
#仅支持nginx下的ssl证书
#使用前请将https站点的对应证书key和crt文件放置到sign文件夹下，均重命名为server
#将生成的原始的moblieconfig文件放置到sign文件夹下，命名为unsigned.mobileconfig

#检查文件是否存在
checkFiles(){
	#检查文件夹是否存在
	if [ ! -x "sign" ];then
		echo "当前sign文件夹不存在或者无可执行权限"
	else
		if [ ! -f "sign/server.key" ];then
			echo "server.key文件不存在，请按照要求放置"
			exit
		fi
		if [ ! -f "sign/server.crt" ];then
			echo "server.crt文件不存在，请按照要求放置"
			exit
		fi

		if [ ! -f "sign/unsigned.mobileconfig" ];then
			echo "unsigned.moblieconfig文件不存在，请按照要求放置"
			exit
		fi

		#echo "检测完成，key和crt文件均存在"
		echo 1
	fi
}

#签名
pemSign(){
	cat "sign/server.crt" "sign/server.key" > "sign/server.pem"
	if [ ! -f "sign/server.pem" ];then
		echo "server.pem文件合成失败"
		exit
	else
		openssl rsa -in "sign/server.key" -out "sign/servernopass.key"
		if [ ! -f "sign/servernopass.key" ];then
			#echo "servernopass.key文件合成失败"
			exit
		else
			openssl smime -sign -in "sign/unsigned.mobileconfig" -out "sign/server.mobileconfig" -signer "sign/server.crt" -inkey "sign/servernopass.key" -certfile "sign/server.pem" -outform der -nodetach
			if [ ! -f "sign/server.mobileconfig" ];then
				#echo "server.mobileconfig文件签名失败"
				exit
			else
				echo "server.mobileconfig文件签名成功"

			fi
		fi
	fi
}

isFiles=$(checkFiles)
if [ isFiles==1 ];then
	pemSign
fi












#!/bin/bash
#leafrainy
#leafrainy.cc
#2019-08-26
#主要用于生成mobileconfig文件并加密

if [ $# -ne 4 ];then
	echo "usage: argument 1:回调地址 2:组织名称 3:主要名称 4:描述"
	echo "e.g. ${0} https://baidu.com 哈哈 呵呵 这是个udid获取器"
	exit 1
fi

#创建uuid
createUUID(){
	UUID1= openssl rand -hex 4 | tr '\n' '-'
	UUID2= openssl rand -hex 2 | tr '\n' '-'
	UUID3= openssl rand -hex 2 | tr '\n' '-'
	UUID4= openssl rand -hex 2 | tr '\n' '-'
	UUID5= openssl rand -hex 6 | tr '\n' '<'

	echo "${UUID1}${UUID2}${UUID3}${UUID4}${UUID5}"
}


URL=$1
PayloadOrganization=$2
PayloadDisplayName=$3
PayloadUUID=$(createUUID) #自动生成个 8-4-4-4-12
PayloadDescription=$4

#生成mobileconfig文件
createMobieleconfig(){

	echo "准备生成 unsigned.mobileconfig..."

	cat <<EOF >unsigned.mobileconfig
<?xml version="1.0" encoding="utf-8"?>
<plist version="1.0">
  <dict>
    <key>PayloadContent</key>
    <dict>
      <key>URL</key>
      <string>${URL}</string>
      <key>DeviceAttributes</key>
      <array>
        <string>DEVICE_NAME</string>
        <string>UDID</string>
        <string>IMEI</string>
        <string>ICCID</string>
        <string>VERSION</string>
        <string>PRODUCT</string>
        <string>SERIAL</string>
        <string>MAC_ADDRESS_EN0</string>
      </array>
    </dict>
    <key>PayloadOrganization</key>
    <string>${PayloadOrganization}</string>
    <key>PayloadDisplayName</key>
    <string>${PayloadDisplayName}</string>
    <key>PayloadVersion</key>
    <integer>1</integer>
    <key>PayloadUUID</key>
    <string>${PayloadUUID}/string>
    <key>PayloadIdentifier</key>
    <string>com.pgyer.profile-service</string>
    <key>PayloadDescription</key>
    <string>${PayloadDescription}</string>
    <key>PayloadType</key>
    <string>Profile Service</string>
  </dict>
</plist>
EOF

	echo "unsigned.moblieconfig文件生成成功"
		
	if [ ! -x "sign" ];then
		echo "当前sign文件夹不存在或者无可执行权限，创建修改中"
		mkdir sign
		chmod +x sign
	fi

	mv unsigned.mobileconfig sign


	if [ ! -f "sign/unsigned.mobileconfig" ];then
		echo "unsigned.moblieconfig文件不存在，请检查"
		exit
	fi

}

#检查文件是否存在
checkFiles(){
	#检查文件夹是否存在
	if [ ! -x "sign" ];then
		echo "当前sign文件夹不存在或者无可执行权限，创建修改中"
		mkdir sign
		chmod +x sign
	else
		if [ ! -f "sign/server.key" ];then
			echo "server.key文件不存在，请按照要求放置"

			exit
		fi
		if [ ! -f "sign/server.crt" ];then
			echo "server.crt文件不存在，请按照要求放置"

			exit
		fi

		echo "检测完成，key和crt文件均存在"

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


createMobieleconfig
checkFiles
pemSign


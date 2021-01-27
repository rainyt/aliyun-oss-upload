## 安装
环境需要安装nodejs，库初次使用时，需要安装：
```shell
sudo npm install ali-oss -g --save
```

## 需要使用haxelib安装
将当前github的zip下载，并使用命令行安装：
```haxe
haxelib install *.zip
```
安装完成后可使用haxelib命令，直接运行。

## 配置OSS
安装完成后，在安装目录下，新建一个oss.json文件，填入：
```json
{
    "bucket": "Bucket名称",
    "region": "oss-cn-hangzhou",
    "accessKeyId": "用户accessKeyId",
    "accessKeySecret": "用户accessKeySecret"
}
```
相关参数请参考阿里云文档。

## 使用命令
```haxe
haxelib run aliyun-oss-upload 上传目录 线上项目文件夹:版本号
```
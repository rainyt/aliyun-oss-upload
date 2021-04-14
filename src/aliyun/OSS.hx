package aliyun;

import js.lib.Promise;

/**
 * 阿里云OSS库node.js
 */
@:jsRequire('ali-oss')
extern class OSS {
    
    public function new(data:{bucket:String,region:String,accessKeyId:String,accessKeySecret:String,timeout:Float});

    /**
     * 上传文件
     * @param 'object-name' 
     * @param 'local-file' 
     * @return Int
     */
    public function put(saveName:String, data:String):Int;

    /**
     * 判断文件是否存在
     * @param name 
     * @return Bool
     */
    public function head(name:String,opt:Dynamic=null):Promise<String>;

}
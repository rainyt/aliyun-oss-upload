package;

import js.html.File;
import haxe.Json;
import sys.FileSystem;
import jsasync.JSAsyncTools.jsawait;
import js.lib.Promise;
import haxe.Exception;
import aliyun.OSS;

@:build(jsasync.JSAsync.build())
class Main {
	/**
	 * 要上传的目标目录
	 */
	public static var targetDir:String;

	/**
	 * 上传到阿里云OSS后台目标目录
	 */
	public static var aliyunTargetDir:String;

	/**
	 * 上传的所有文件
	 */
	public static var allfile:Array<String> = [];

	public static var allUploadCount:Int = 0;

	/**
	 * 开始上传时间
	 */
	public static var startTime:Float = Date.now().getTime();

	@:jsasync static function main() {
		targetDir = Sys.args()[0];
		aliyunTargetDir = Sys.args()[1];
		if (aliyunTargetDir.indexOf(":") == -1) {
			throw "无效格式，请使用[文件夹:版本号]的格式";
		}
		aliyunTargetDir = StringTools.replace(aliyunTargetDir, ":", "/");
		trace("OSS启动");
		var oss = new OSS(Json.parse(sys.io.File.getContent(StringTools.replace(Sys.programPath(), "ali-upload.js", "../oss.json"))));
		// 判断一下阿里云是否存在当前目录
		startUpload(oss);
	}

	public static function startUpload(oss:OSS):Void {
		Sys.setCwd(Sys.args()[Sys.args().length - 1]);
		trace("检索目录..." + Sys.getCwd());
		readDir(targetDir);
		trace("总文件数量：" + allfile.length + "个，开始上传...");
		var tcount = 30;
		var len = Std.int(allfile.length / tcount);
		if (len == 0)
			len = 1;
		trace(tcount + "线程上传：" + len);
		for (i in 0...tcount) {
			if (i == tcount - 1) {
				upload(oss, i * len, allfile.length);
			} else {
				upload(oss, i * len, (i * len + len));
			}
		}
	}

	/**
	 * 上传完成
	 */
	public static function onSuccess():Void {
		trace("上传完成，远程地址：https://static.kdyx.cn/" + aliyunTargetDir);
		var date = DateTools.format(Date.fromTime(Date.now().getTime() - startTime), "%M:%S");
		trace("总耗时：" + date + "秒");
	}

	/**
	 * 开始上传
	 */
	@:jsasync public static function upload(oss:OSS, start:Int, end:Int) {
		// 传输前先收集目标目录下的所有文件
		for (i in start...end) {
			var file = allfile[i];
			if (file == null || file.indexOf(".") == 0) {
				if (file != null)
					allUploadCount++;
				continue;
			}
			var bf = Std.int((allUploadCount) / allfile.length * 100);
			try {
				jsawait(js.lib.Promise.resolve(aliyunUpload(oss, aliyunTargetDir + "/" + file, targetDir + "/" + file)));
				allUploadCount++;
				trace("上传进度[" + (allUploadCount) + "/" + allfile.length + "]" + bf + "% :" + file);
				if (allUploadCount == allfile.length) {
					onSuccess();
				}
			} catch (e:Exception) {
				trace("上传文件失败：" + file, "原因：" + e);
			}
		}
	}

	/**
	 * 阿里云上传
	 * @param oss
	 * @param target
	 * @param to
	 */
	public static function aliyunUpload(oss:OSS, target:String, to:String):Int {
		var result = oss.put(target, to);
		return result;
	}

	/**
	 * 读取目录资源
	 * @param dir
	 */
	public static function readDir(dir:String):Void {
		if (!FileSystem.isDirectory(dir)) {
			targetDir = dir.substr(0, dir.lastIndexOf("/") + 1);
			allfile.push(dir.substr(dir.lastIndexOf("/") + 1));
			return;
		}
		var files = sys.FileSystem.readDirectory(dir);
		for (file in files) {
			var path = dir + "/" + file;
			if (sys.FileSystem.isDirectory(path)) {
				readDir(path);
			} else {
				allfile.push(StringTools.replace(path, targetDir + "/", ""));
			}
		}
	}
}

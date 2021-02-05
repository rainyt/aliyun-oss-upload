class NekoRun {
    
    static function main() {
        trace("Sys.args()",Sys.args());
        Sys.command("node " + StringTools.replace(Sys.programPath(),"run.n","bin/ali-upload.js ") + Sys.args()[0] + " " + Sys.args()[1] + " " + Sys.args()[2]);
    }

}
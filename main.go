package main

import (
	"github.com/astaxie/beego"
	tools "oDir/Tools"
	_ "oDir/routers"
)


func main() {
	if beego.AppConfig.String("datapath")=="" {
		dataPath:=tools.TransPath(tools.GetCurrentPath()+"/data")
		tools.MkDir(dataPath)
		beego.AppConfig.Set("datapath",""+dataPath+"")
		beego.AppConfig.SaveConfigFile("conf/app.conf")

	}
	beego.SetStaticPath("/data",""+beego.AppConfig.String("datapath")+"")
	beego.Run()
}


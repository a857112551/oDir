package routers

import (
	"github.com/astaxie/beego"
	"oDir/controllers"
)

func init() {
    beego.Router("/", &controllers.IndexController{})
	beego.Router("/index/*", &controllers.IndexController{})
	beego.Router("/login/*", &controllers.LoginController{})
	beego.Router("/upload/*", &controllers.Recfile{})
	beego.Router("/download/*", &controllers.Download{})
}

package controllers

import (
	"github.com/astaxie/beego"
	tools "oDir/Tools"
	"path/filepath"
)

/***
 *Description:Download
 *@User:MC
 *@Date:2021/8/2
 */
type Download struct {
	beego.Controller
}

func (c *Download) Get() {
	if tools.CheckCookie(c.Ctx) == false {
		c.Ctx.WriteString(tools.IllegalAccess())
	} else {
		r:=c.Ctx.Request
		r.ParseForm()
		if r.Form.Get("path")!="" {
			downloadPath:=tools.TransPath(beego.AppConfig.String("datapath")+"/"+r.Form.Get("path"))
			c.Ctx.Output.Download(downloadPath,""+filepath.Base(downloadPath)+"")
		}
	}
}

func (c *Download) Post() {
	if tools.CheckCookie(c.Ctx) == false {
		c.Ctx.WriteString(tools.IllegalAccess())
	} else {
		r:=c.Ctx.Request
		r.ParseForm()
		if r.Form.Get("path")!="" {
			downloadPath:=tools.TransPath(beego.AppConfig.String("datapath")+"/"+r.Form.Get("path"))
			c.Ctx.Output.Download(downloadPath,""+filepath.Base(downloadPath)+"")
		}
	}
}
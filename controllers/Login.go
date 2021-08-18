package controllers

import (
	"github.com/astaxie/beego"
	tools "oDir/Tools"
)

/***
 *Description:LoginController
 *@User:MC
 *@Date:2021/7/28
 */
type LoginController struct {
	beego.Controller
}

func (c *LoginController) Get() {
	r:=c.Ctx.Request
	r.ParseForm()
	if r.Form.Get("type")=="" || r.Form.Get("type")=="login" {
		c.TplName = "login.html"
	} else if r.Form.Get("type")=="changepwd" {
		//if beego.AppConfig.String("lock")=="locked" {
		//	c.TplName = "login.html"
		//} else {
			c.TplName = "changepwd.html"
		//}
	} else {
		c.TplName = "login.html"
	}
}

func (c *LoginController) Post() {
	r:=c.Ctx.Request
	r.ParseForm()
	if r.Form.Get("type")=="login" {
		userName:=c.GetString("name")
		userPwd:=c.GetString("pwd")
		if userName!=beego.AppConfig.String("user") {
			resultStr:=tools.MakePublicStr("10089","用户名不正确","")
			c.Ctx.WriteString(resultStr)
		} else if userName==beego.AppConfig.String("user") && tools.GetPWDMD5(userPwd)=="2ac801adc4bfdef596d93ec8eea9c05b" {
			resultStr:=tools.MakePublicStr("302","首次登录修改密码","/login/?type=changepwd")
			c.Ctx.WriteString(resultStr)
		} else if userName==beego.AppConfig.String("user") && tools.GetPWDMD5(userPwd)!=beego.AppConfig.String("pwd") {
			resultStr:=tools.MakePublicStr("10090","密码不正确","")
			c.Ctx.WriteString(resultStr)
		} else if userName==beego.AppConfig.String("user") && tools.GetPWDMD5(userPwd)==beego.AppConfig.String("pwd") {
			tokenStr:=tools.GetToken(userName+tools.GetTime())
			beego.AppConfig.Set("token",""+tokenStr+"")
			beego.AppConfig.SaveConfigFile("conf/app.conf")
			c.Ctx.SetCookie("token",""+tokenStr+"")
			resultStr:=tools.MakePublicStr("302","验证通过","/index")
			c.Ctx.WriteString(resultStr)
		}
	} else if r.Form.Get("type")=="changepwd"{
		userName:=c.GetString("name")
		userPwd1:=c.GetString("pwd1")
		userPwd2:=c.GetString("pwd2")
		if userName=="" {
			resultStr:=tools.MakePublicStr("10086","用户名不正确","")
			c.Ctx.WriteString(resultStr)
		} else if userPwd1=="" || userPwd2=="" {
			resultStr:=tools.MakePublicStr("10087","密码不能为空","")
			c.Ctx.WriteString(resultStr)
		} else if userPwd1!=userPwd2 {
			resultStr:=tools.MakePublicStr("10088","两次输入密码不一致","")
			c.Ctx.WriteString(resultStr)
		} else {
			c.Ctx.SetCookie("token",""+"")
			c.Ctx.SetCookie("token_d",""+"")
			beego.AppConfig.Set("user",""+userName+"")
			beego.AppConfig.Set("pwd",""+tools.GetPWDMD5(userPwd1)+"")
			beego.AppConfig.Set("token",""+userName+"")
			//beego.AppConfig.Set("lock","locked")
			beego.AppConfig.SaveConfigFile("conf/app.conf")
			resultStr:=tools.MakePublicStr("302","验证通过，去登陆","/login")
			c.Ctx.WriteString(resultStr)
		}
	} else if r.Form.Get("type")=="logout"{
		c.Ctx.SetCookie("token",""+"")
		c.Ctx.SetCookie("token_d",""+"")
		beego.AppConfig.Set("token",""+"")
		beego.AppConfig.SaveConfigFile("conf/app.conf")
		c.Ctx.WriteString(tools.MakePublicStr("0","下次再见",""))
	} else {
		resultStr:=tools.MakePublicStr("302","去登陆","/login")
		c.Ctx.WriteString(resultStr)
	}
}
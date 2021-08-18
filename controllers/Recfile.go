package controllers

import (
	"github.com/astaxie/beego"
	tools "oDir/Tools"
)

/***
 *Description:Recfile
 *@User:MC
 *@Date:2021/8/2
 */
type Recfile struct {
	beego.Controller
}

func (c *Recfile) Get() {
	c.Ctx.WriteString(tools.IllegalAccess())
}

func (c *Recfile) Post() {
	if tools.CheckCookie(c.Ctx)==false {
		c.Ctx.WriteString(tools.IllegalAccess())
	} else {
		r:=c.Ctx.Request
		r.ParseForm()
		if r.Form.Get("type")=="file" {
			savePath:=tools.TransPath(beego.AppConfig.String("datapath")+"/"+c.GetString("tardir"))
			f, h, _ := c.GetFile("file")
			defer f.Close()
			fileName:=h.Filename
			if tools.PathExists(tools.TransPath(savePath+"/"+fileName)) {
				savePath=tools.TransPath(savePath+"/"+tools.GetTime()+" "+fileName)
			} else {
				savePath=tools.TransPath(savePath+"/"+fileName)
			}
			err := c.SaveToFile("file", savePath)
			//buf := bytes.NewBuffer(nil)
			//io.Copy(buf, f)
			//data:=buf.Bytes()
			//file, _ := os.OpenFile(savePath, os.O_WRONLY|os.O_CREATE|os.O_TRUNC, 0666)
			//defer file.Close()
			//reader := bytes.NewReader(data)
			//_,err:=io.Copy(file, reader)
			if err == nil {
				c.Ctx.WriteString(tools.MakePublicStr("0","上传完成！",""))
				//fileMd5:=tools.GetFileMd5(savePath)
				//if strings.EqualFold(fileHash,fileMd5) {
				//	resultStr="yes"
				//} else{
				//	c.Ctx.WriteString(tools.MakePublicStr("10093","上传失败：文件验证失败",""))
				//}
			} else {
				c.Ctx.WriteString(tools.MakePublicStr("10092","上传失败："+err.Error(),""))
			}
		} else if r.Form.Get("type")=="dir" {
			err:=tools.MkDir(tools.TransPath(beego.AppConfig.String("datapath")+"/"+c.GetString("path")))
			if err==nil {
				c.Ctx.WriteString(tools.MakePublicStr("0","创建成功！",""))
			} else {
				c.Ctx.WriteString(tools.MakePublicStr("10093","创建失败！",""))
			}
		}
	}
}
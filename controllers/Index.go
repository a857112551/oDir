package controllers

import (
	"fmt"
	"github.com/astaxie/beego"
	"io/ioutil"
	tools "oDir/Tools"
	"strings"
)

/***
 *Description:IndexController
 *@User:MC
 *@Date:2021/7/28
 */

type IndexController struct {
	beego.Controller
}

func (c *IndexController) Get() {
	if tools.CheckCookie(c.Ctx) == false {
		c.Ctx.Redirect(302, "/login")
	} else {
		noticeStr := beego.AppConfig.String("notice")
		c.Data["notice"] = noticeStr

		r := c.Ctx.Request
		r.ParseForm()
		dirStr := tools.UrlDecode(r.Form.Get("dir"))
		if dirStr == "" {
			dirStr = "/"
		}
		if dirStr[0:1] == "/" || dirStr[0:1] == "\\" {
			dirStr = dirStr[1:]
		}
		//cookie存当前路径
		c.Ctx.SetCookie("token_d", ""+dirStr+"")

		mapHtmlStr := ""
		if dirStr == "/" || dirStr == "" {
			mapHtmlStr = mapHtmlStr + "<a href=\"/index?dir=/\">首页/</a>"
		} else {
			dirArr := strings.Split(dirStr, "/")
			mapHtmlStr = mapHtmlStr + "<a href=\"/index?dir=/\">首页/</a>"
			for i := 0; i < len(dirArr); i++ {
				tmpMapHtmlStr := ""
				for j := 0; j < i+1; j++ {
					tmpMapHtmlStr = tmpMapHtmlStr + dirArr[j] + "/"
				}
				tmpMapHtmlStr = tmpMapHtmlStr[0 : len(tmpMapHtmlStr)-1]

				mapHtmlStr = mapHtmlStr + "<a href=\"/index?dir=/" + tmpMapHtmlStr + "\">" + dirArr[i] + "/</a>"
			}
		}
		c.Data["map"] = strings.ReplaceAll(mapHtmlStr, "//", "/")
		c.TplName = "index.html"
	}
}

func (c *IndexController) Post() {
	if tools.CheckCookie(c.Ctx) == false {
		c.Ctx.WriteString(tools.IllegalAccess())
	} else {
		resultStr := ""
		r := c.Ctx.Request
		r.ParseForm()
		if r.Form.Get("type")=="txt" {
			txtPath := tools.TransPath(beego.AppConfig.String("datapath") + "/"+tools.UrlDecode(c.GetString("txt")))
			txtStr,err:=tools.ReadTxt(txtPath)
			if err==nil {
				resultStr=tools.MakePublicStr("0","成功",txtStr)
			} else {
				resultStr=tools.MakePublicStr("0","文件读取失败","")
			}
		} else if r.Form.Get("type")=="del" {
			txtPath := tools.TransPath(beego.AppConfig.String("datapath") + "/"+tools.UrlDecode(c.GetString("path")))
			err:=tools.RMFile(txtPath)
			if err==nil {
				resultStr=tools.MakePublicStr("0","删除成功","")
			} else {
				resultStr=tools.MakePublicStr("0","删除失败：文件或文件夹被占用","")
			}
		} else {
			dirStr := tools.UrlDecode(r.Form.Get("dir"))
			if dirStr == "" {
				dirStr = "/"
			}
			if dirStr[0:1] == "/" || dirStr[0:1] == "\\" {
				dirStr = dirStr[1:]
			}
			pathStr := beego.AppConfig.String("datapath") + "/" + dirStr
			pathStr = tools.TransPath(pathStr)

			resultStr = getFileList(pathStr)
		}
		c.Ctx.WriteString(resultStr)
	}
}

func getFileList(path string) string {
	count := 0
	var strDirInfoB strings.Builder
	var strFileInfoB strings.Builder
	var strDataB strings.Builder

	fs, _ := ioutil.ReadDir(path)
	if path != tools.TransPath(beego.AppConfig.String("datapath")+"/") {
		strDirInfoB.WriteString("{")
		strDirInfoB.WriteString("\"filename\":\"" + getPrePath(path) + "\",")
		strDirInfoB.WriteString("\"filetime\":\"\",")
		strDirInfoB.WriteString("\"filesize\":\"\",")
		strDirInfoB.WriteString("\"filetype\":\"999\"")
		strDirInfoB.WriteString("},")
	}
	for _, file := range fs {
		if file.IsDir() {
			//0 文件夹
			fmt.Println(path + file.Name())
			strDirInfoB.WriteString("{")
			strDirInfoB.WriteString("\"filename\":\"" + file.Name() + "\",")
			strDirInfoB.WriteString("\"filetime\":\"" + tools.TimeToStr(file.ModTime()) + "\",")
			strDirInfoB.WriteString("\"filesize\":\"" + tools.FormatFileSize(file.Size()) + "\",")
			strDirInfoB.WriteString("\"filetype\":\"0\"")
			strDirInfoB.WriteString("},")
		} else {
			//1 文本文档
			//2 图片
			//3 视屏
			//4 音频
			//5 压缩文件
			fmt.Println(path + file.Name())
			strFileInfoB.WriteString("{")
			strFileInfoB.WriteString("\"filename\":\"" + file.Name() + "\",")
			strFileInfoB.WriteString("\"filetime\":\"" + tools.TimeToStr(file.ModTime()) + "\",")
			strFileInfoB.WriteString("\"filesize\":\"" + tools.FormatFileSize(file.Size()) + "\",")
			strFileInfoB.WriteString("\"filetype\":\"" + tools.FileTypeNum(file.Name()) + "\"")
			strFileInfoB.WriteString("},")
		}
		count = count + 1
	}
	strInfo := strDirInfoB.String() + strFileInfoB.String()
	if strInfo != "" {
		strInfo = strInfo[0 : len(strInfo)-1]
	}
	strDataB.WriteString("{")
	strDataB.WriteString("\"code\": 0,")
	strDataB.WriteString("\"msg\": \"\",")
	strDataB.WriteString("\"count\": " + tools.IntToString(int64(count)) + ",")
	strDataB.WriteString("\"data\": [")
	strDataB.WriteString(strInfo)
	strDataB.WriteString("]}")
	strData := strDataB.String()
	return strData
}

func getPrePath(cuPath string) string {
	resultStr := ""
	cuPath = strings.ReplaceAll(cuPath, tools.TransPath(beego.AppConfig.String("datapath")), "")
	cuPath = strings.ReplaceAll(cuPath, "\\", "/")

	cuPathArr := strings.Split(cuPath, "/")
	for i := 0; i < len(cuPathArr)-1; i++ {
		resultStr = resultStr + cuPathArr[i] + "/"
	}
	resultStr = resultStr[0 : len(resultStr)-1]
	return resultStr
}

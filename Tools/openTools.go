package tools

import (
	"crypto/md5"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"github.com/astaxie/beego"
	"github.com/astaxie/beego/context"
	"io"
	"io/ioutil"
	"math/rand"
	"net/url"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strconv"
	"strings"
	"time"
)

type PublicJson struct {
	Errcode string `json:"errcode"`
	Errmsg  string `json:"errmsg"`
	DataStr string `json:"dataStr"`
}

/***
 *Description:生成通用返回字符串
 *@User:MC
 *@Date:2021/7/29
 */
func MakePublicStr(errcode string, errmsg string, dataStr string) string {
	resultStr := ""
	resultJson, _ := json.Marshal(PublicJson{
		Errcode: errcode,
		Errmsg:  errmsg,
		DataStr: dataStr,
	})
	resultStr = string(resultJson)
	return resultStr
}

/***
*2021/7/27*
*mc*
*map转字符串*
 */
func MapToString(mapStr interface{}) string {
	dataType, _ := json.Marshal(mapStr)
	resultStr := string(dataType)
	if resultStr[0:1] == "\"" {
		resultStr = resultStr[1:]
	}
	if resultStr[len(resultStr)-1:] == "\"" {
		resultStr = resultStr[0 : len(resultStr)-1]
	}
	return resultStr
}

/***
*2021/7/27*
*mc*
*判断路径或文件是否存在*
 */
func PathExists(path string) bool {
	_, err := os.Stat(path)
	if err == nil {
		return true
	}
	if os.IsNotExist(err) {
		return false
	}
	return false
}

/***
*2021/7/27*
*mc*
*时间格式化字符串*
 */
func GetTimeFormatStr() string {
	layout := "2006-01-02 15-04-05"
	return layout
}

/***
*2021/7/27*
*mc*
*获取当前时间*
 */
func GetTime() string {
	resultStr := ""
	resultStr = time.Now().Format(GetTimeFormatStr())
	return resultStr
}

/***
*2021/7/27*
*mc*
*获取相差时间*
 */
func GetTimeDiffer(start_time, end_time string) string {
	var hour int64
	var minutes int64
	minutes = 0
	t1, err := time.ParseInLocation(GetTimeFormatStr(), start_time, time.Local)
	t2, err := time.ParseInLocation(GetTimeFormatStr(), end_time, time.Local)
	if err == nil {
		diff := t1.Unix() - t2.Unix()
		hour = diff / 3600
		minutes = hour * 60
		return strconv.FormatInt(minutes, 10)
	} else {
		return strconv.FormatInt(minutes, 10)
	}
}

/***
*2021/7/27*
*mc*
*格式化时间*
 */
func FormatTime(timeStr string) string {
	t, _ := time.ParseInLocation(GetTimeFormatStr(), timeStr, time.Local)
	resultStr := t.Format(GetTimeFormatStr())
	return resultStr
}

/***
*2021/7/27*
*mc*
*时间转字符串*
 */
func TimeToStr(timeStr time.Time) string {
	resultStr := timeStr.Format(GetTimeFormatStr())
	return resultStr
}

/***
*2021/7/27*
*mc*
*Numeric转字符串*
 */
func NumericToStr(data []uint8) float64 {
	//tmpFloat, _ :=strconv.ParseFloat(string(data.([]byte)),64)
	tmpFloat, _ := strconv.ParseFloat(string(data), 64)
	return tmpFloat
}

/***
*2021/7/27*
*mc*
*float转字符串*
 */
func FloatToString(input_num float64) string {
	// to convert a float number to a string
	return strconv.FormatFloat(input_num, 'f', 6, 64)
}

/***
*2021/7/27*
*mc*
*int转字符串*
 */
func IntToString(input_num int64) string {
	// to convert a float number to a string
	return strconv.FormatInt(input_num, 10)
}

/***
*2021/7/27*
*mc*
*获取文件md5*
 */
func GetFileMd5(filename string) string {
	// 文件全路径名
	path := fmt.Sprintf("./%s", filename)
	pFile, err := os.Open(path)
	if err != nil {
		fmt.Errorf("打开文件失败，filename=%v, err=%v", filename, err)
		return ""
	}
	defer pFile.Close()
	md5h := md5.New()
	io.Copy(md5h, pFile)
	return strings.ToLower(hex.EncodeToString(md5h.Sum(nil)))
}

/***
*2021/7/27*
*mc*
*map转json*
 */
func MapToJson(param []map[string]interface{}) string {
	dataType, _ := json.Marshal(param)
	dataString := string(dataType)
	return dataString
}

/***
获取当前可执行文件的路径
*/
func GetCurrentPath() string {
	file, err := exec.LookPath(os.Args[0])
	if err != nil {
		return ""
	}
	path, err := filepath.Abs(file)
	if err != nil {
		return ""
	}
	i := strings.LastIndex(path, "/")
	if i < 0 {
		i = strings.LastIndex(path, "\\")
	}
	if i < 0 {
		//return "", errors.New(`error: Can't find "/" or "\".`)
		return ""
	}
	return string(path[0:i])
}

/***
判断当前系统类型
*/
var LINUX int = 1
var WINDOWS int = 2

func GetSysType() int {
	resultType := 0
	sysType := runtime.GOOS
	if sysType == "linux" {
		resultType = LINUX
	}

	if sysType == "windows" {
		resultType = WINDOWS
	}
	return resultType
}

/***
转换路径到系统对应格式
*/
func TransPath(pathStr string) string {
	resultStr := ""
	if GetSysType() == LINUX {
		resultStr = strings.ReplaceAll(pathStr, "\\", "/")
		//for strings.LastIndexAny(pathStr,"//")!=-1 {
		//	resultStr = strings.ReplaceAll(pathStr, "//", "/")
		//}
		resultStr = strings.ReplaceAll(resultStr, "//", "/")
	} else if GetSysType() == WINDOWS {
		resultStr = strings.ReplaceAll(pathStr, "/", "\\")
		//for strings.IndexAny(pathStr,"\\\\")!=-1 {
		//	resultStr = strings.ReplaceAll(pathStr, "\\\\", "\\")
		//}
		resultStr = strings.ReplaceAll(resultStr, "\\\\", "\\")
	}
	return resultStr
}

/***
创建文件夹
*/
func MkDir(path string) error{
	err:=os.MkdirAll(path, os.ModeDir)
	return err
}

/***
*2021/7/28*
*mc*
*删除文件*
 */
func RMFile(path string) error {
	err := os.RemoveAll(path)
	return err
}

/***
读取文件
*/
func ReadTxt(filePth string) (string, error) {
	f, err := ioutil.ReadFile(filePth)
	if err != nil {
		return "", err
	}
	return string(f), nil
}

/***
 *Description:验证cookie
 *@User:MC
 *@Date:2021/7/28
 */
func CheckCookie(ctx *context.Context) bool {
	cookieStr := ctx.GetCookie("token")
	if cookieStr == "" {
		return false
	} else if cookieStr != beego.AppConfig.String("token") {
		return false
	} else {
		return true
	}
}

/***
 *Description:生成token
 *@User:MC
 *@Date:2021/7/29
 */
func GetToken(srcStr string) string {
	data := []byte("oDir" + srcStr + "login" + strconv.Itoa(rand.Intn(10)))
	s := fmt.Sprintf("%x", md5.Sum(data))
	fmt.Println(s)

	// 也可以用这种方式
	h := md5.New()
	h.Write(data)
	s = hex.EncodeToString(h.Sum(nil))
	return s
}

/***
 *Description:生成密码加密后字符串
 *@User:MC
 *@Date:2021/7/29
 */
func GetPWDMD5(pwd string) string {
	data := []byte("oDir" + pwd + "pwd" + beego.AppConfig.String("accesstoken"))
	//s := fmt.Sprintf("%x", md5.Sum(data))
	//fmt.Println(s)

	// 也可以用这种方式
	h := md5.New()
	h.Write(data)
	s := hex.EncodeToString(h.Sum(nil))
	return s
}

/***
 *Description:字节的单位转换 保留两位小数
 *@User:MC
 *@Date:2021/7/30
 */
func FormatFileSize(fileSize int64) (size string) {
	if fileSize < 1024 {
		return fmt.Sprintf("%.2fB", float64(fileSize)/float64(1))
	} else if fileSize < (1024 * 1024) {
		return fmt.Sprintf("%.2fKB", float64(fileSize)/float64(1024))
	} else if fileSize < (1024 * 1024 * 1024) {
		return fmt.Sprintf("%.2fMB", float64(fileSize)/float64(1024*1024))
	} else if fileSize < (1024 * 1024 * 1024 * 1024) {
		return fmt.Sprintf("%.2fGB", float64(fileSize)/float64(1024*1024*1024))
	} else if fileSize < (1024 * 1024 * 1024 * 1024 * 1024) {
		return fmt.Sprintf("%.2fTB", float64(fileSize)/float64(1024*1024*1024*1024))
	} else {
		//if fileSize < (1024 * 1024 * 1024 * 1024 * 1024 * 1024)
		return fmt.Sprintf("%.2fEB", float64(fileSize)/float64(1024*1024*1024*1024*1024))
	}
}

/***
 *Description:根据文件类型返回
 *@User:MC
 *@Date:2021/7/30
 */

func FileTypeNum(fileName string) string {
	//1 文本文档
	//2 图片
	//3 视屏
	//4 音频
	//5 压缩文件
	//6 office
	//7 未知
	result := ""
	if len(fileName) > 0 {
		exStr := ""
		fileNameByteArr := []byte(fileName)
		for i := 0; i < len(fileNameByteArr); i++ {
			if string(fileName[i]) == "." || exStr != "" {
				exStr = exStr + string(fileName[i])
			}
		}
		exStr = exStr[1:]
		exStr = strings.ToLower(exStr)
		if exStr == "txt" || exStr == "md"  || exStr == "log"  || exStr == "xml"  || exStr == "html"  || exStr == "htm" {
			return "1"
		} else if exStr == "jpg" || exStr == "jpep" || exStr == "png" || exStr == "gif" || exStr == "bmp" || exStr == "icon" || exStr == "webp" || exStr == "psd" {
			result = "2"
		} else if exStr == "mp4" || exStr == "avi" || exStr == "rmvb" || exStr == "m3u8" {
			result = "3"
		} else if exStr == "mp3" || exStr == "wma" || exStr == "acc" {
			return "4"
		} else if exStr == "rar" || exStr == "rar2" || exStr == "zip" || exStr == "7z" {
			return "5"
		} else if exStr == "doc" || exStr == "docx" || exStr == "xls"  || exStr == "xlsx"  || exStr == "ppt"  || exStr == "pptx" {
			return "6"
		}else {
			return "7"
		}

		//mineType := mime.TypeByExtension(exStr)
		//result=mineType
		if result == "" {
			result = "1"
		}
	} else {
		result = "1"
	}

	return result
}

/***
 *Description:url中文解码
 *@User:MC
 *@Date:2021/7/30
 */
func UrlDecode(urlStr string) string {
	resultStr := ""
	resultStr, _ = url.QueryUnescape(urlStr)
	return resultStr
}

/***
 *Description:非法请求
 *@User:MC
 *@Date:2021/8/2
 */
func IllegalAccess() string {
	resultStr:=MakePublicStr("10091","非法请求！","")
	return resultStr
}
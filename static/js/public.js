function httpRequest(paramObj,fun,errFun) {
    var xmlhttp = null;
    /*创建XMLHttpRequest对象，
     *老版本的 Internet Explorer（IE5 和 IE6）使用 ActiveX 对象：new ActiveXObject("Microsoft.XMLHTTP")
     * */
    if(window.XMLHttpRequest) {
        xmlhttp = new XMLHttpRequest();
    }else if(window.ActiveXObject) {
        xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
    }
    /*判断是否支持请求*/
    if(xmlhttp == null) {
        alert('你的浏览器不支持XMLHttp');
        return;
    }
    /*请求方式，并且转换为大写*/
    var httpType = (paramObj.type || 'GET').toUpperCase();
    /*数据类型*/
    var dataType = paramObj.dataType || 'json';
    /*请求接口*/
    var httpUrl = paramObj.httpUrl || '';
    /*是否异步请求*/
    var async = paramObj.async || true;
    /*请求参数--post请求参数格式为：foo=bar&lorem=ipsum*/
    var paramData = paramObj.data || [];
    var requestData = '';
    for(var name in paramData) {
        requestData += name + '='+ paramData[name] + '&';
    }
    requestData = requestData == '' ? '' : requestData.substring(0,requestData.length - 1);
    console.log(requestData)

    /*请求接收*/
    xmlhttp.onreadystatechange = function() {
        if(xmlhttp.readyState == 4 && xmlhttp.status == 200) {
            /*成功回调函数*/
            fun(xmlhttp.responseText);
        }else{
            /*失败回调函数*/
            errFun;
        }
    }

    /*接口连接，先判断连接类型是post还是get*/
    if(httpType == 'GET') {
        xmlhttp.open("GET",httpUrl,async);
        xmlhttp.send(null);
    }else if(httpType == 'POST'){
        xmlhttp.open("POST",httpUrl,async);
        //发送合适的请求头信息
        xmlhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        xmlhttp.send(requestData);
    }
};
function getErrMsg(xmlStr,ok,err){
    try //Internet Explorer
    {
        xmlDoc=new ActiveXObject("Microsoft.XMLDOM");
        xmlDoc.async="false";
        xmlDoc.loadXML(xmlStr);
    }
    catch(e)
    {
        try //Firefox, Mozilla, Opera, etc.
        {
            parser=new DOMParser();
            xmlDoc=parser.parseFromString(xmlStr,"text/xml");
        }
        catch(e) {
            err("创建解析对象失败");
        }
    }
    try
    {
        var errcode=xmlDoc.getElementsByTagName("errcode")[0].childNodes[0].nodeValue
        var errmsg=xmlDoc.getElementsByTagName("errmsg")[0].childNodes[0].nodeValue
        ok(errcode,errmsg)
    }
    catch(e) {
        err("解析失败");
    }
};

function isMobile() {
    let flag = navigator.userAgent.match(
        /(phone|pad|pod|iPhone|iPod|ios|iPad|Android|Mobile|BlackBerry|IEMobile|MQQBrowser|JUC|Fennec|wOSBrowser|BrowserNG|WebOS|Symbian|Windows Phone)/i
    );
    if(flag == null){
        return false;
    }else{
        return true;
    }
};

// 获取指定名称的cookie
function getCookie(name){
    var strcookie = document.cookie;//获取cookie字符串
    var arrcookie = strcookie.split("; ");//分割
    //遍历匹配
    for ( var i = 0; i < arrcookie.length; i++) {
        var arr = arrcookie[i].split("=");
        if (arr[0] == name){
            return arr[1];
        }
    }
    return "";
}


function GetQueryString(name)
{
    var urlStr=decodeURIComponent(window.location.href)
    // var reg = new RegExp("(^|&)"+ name +"=([^&]*)(&|$)");
    // var r = window.location.search.substr(1).match(reg);
    // if(r!=null)return  unescape(r[2]); return "";
    var arr1=urlStr.split("?")
    if (arr1.length>1){
        var arr2=arr1[1].split("&")
        if (arr2.length>1){
            for (let i = 0; i < arr2.length; i++) {
                var arr3=arr2[i].split("=")
                if (arr3[0]===name)
                {
                    return arr3[1]
                }
            }
        } else {
            var arr4=arr2[0].split("=")
            if (arr4[0]===name)
            {
                return arr4[1]
            }
        }
    } else {
        return ""
    }
}
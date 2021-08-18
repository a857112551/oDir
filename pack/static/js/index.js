// 文件列表加载
layui.use('table', function () {
    var table = layui.table;
    table.render({
        elem: '#dirlist'
        , method: 'post'
        , url: window.location.href
        , height: 'full-200'
        , cols: [[
            {
                field: 'filename', width: '55%', title: '文件名', style: 'cursor: pointer;', templet: function (d) {
                    var urlStr = window.location.origin + "/"
                    var dirStr = GetQueryString("dir")
                    urlStr = urlStr + "index/?dir=" + dirStr
                    if (urlStr.substring(urlStr.length - 1) !== "/") {
                        urlStr = urlStr + "/"
                    }
                    var returnStr = ""

                    if (d.filetype !== "0" && d.filetype !== "999") {
                        urlStr = urlStr.replaceAll("index/?dir=", "download/?path=")
                        returnStr = "<a href='" + urlStr + d.filename + "'"
                        returnStr = returnStr + " download=\"" + d.filename + "\"><i class=\"fa "
                    } else if (d.filetype === "0") {
                        returnStr = "<a href='" + urlStr + d.filename + "'"
                        returnStr = returnStr + "><i class=\"fa "
                    } else if (d.filetype === "999") {
                        returnStr = "<a href='" + urlStr.split("=")[0] + "=" + d.filename + "'"
                        returnStr = returnStr + "><i class=\"fa "
                    }
                    var iconTypeStr = ""
                    if (d.filetype === "0") {
                        iconTypeStr = "fa-folder-open"
                        returnStr = returnStr + iconTypeStr + "\">&nbsp;" + d.filename + "</i></a>"
                    } else if (d.filetype === "1" || d.filetype === "6") {
                        iconTypeStr = "fa-file-text-o"
                        returnStr = returnStr + iconTypeStr + "\">&nbsp;" + d.filename + "</i></a>"
                    } else if (d.filetype === "2") {
                        iconTypeStr = "fa-file-picture-o"
                        returnStr = returnStr + iconTypeStr + "\">&nbsp;" + d.filename + "</i></a>"
                    } else if (d.filetype === "3") {
                        iconTypeStr = "fa-file-movie-o"
                        returnStr = returnStr + iconTypeStr + "\">&nbsp;" + d.filename + "</i></a>"
                    } else if (d.filetype === "4") {
                        iconTypeStr = "fa-file-audio-o"
                        returnStr = returnStr + iconTypeStr + "\">&nbsp;" + d.filename + "</i></a>"
                    } else if (d.filetype === "5") {
                        iconTypeStr = "fa-file-archive-o"
                        returnStr = returnStr + iconTypeStr + "\">&nbsp;" + d.filename + "</i></a>"
                    } else if (d.filetype === "7") {
                        iconTypeStr = "fa-file"
                        returnStr = returnStr + iconTypeStr + "\">&nbsp;" + d.filename + "</i></a>"
                    } else if (d.filetype === "999") {
                        iconTypeStr = "fa-folder-open"
                        returnStr = returnStr + iconTypeStr + "\">&nbsp;" + "..." + "</i></a>"
                    }
                    return returnStr
                }
            }
            , {field: 'filetime', width: '15%', title: '修改时间'}
            , {field: 'filesize', width: '15%', title: '文件大小'}
            , {
                field: 'filetype', width: '15%', title: '操作', templet: function (d) {
                    var urlStr = window.location.origin + "/"
                    var dirStr = GetQueryString("dir")
                    urlStr = urlStr + "index/?view=" + dirStr
                    if (urlStr.substring(urlStr.length - 1) !== "/") {
                        urlStr = urlStr + "/"
                    }
                    urlStr = urlStr + d.filename
                    var returnStr = ""
                    if (d.filetype === "1") {
                        returnStr = "<a href=\"javascript:;\" onclick=\"viewtxt('" + d.filename + "\')\"><i class=\"fa fa-eye\"></i></a>"+"&nbsp;&nbsp;<a href=\"javascript:;\" onclick=\"del('" + d.filename + "\')\"><i class=\"fa fa-trash\"></i></a>"
                    } else if (d.filetype === "2") {
                        returnStr = "<a href=\"javascript:;\" onclick=\"viewpic('" + d.filename + "\')\"><i class=\"fa fa-eye\"></i></a>"+"&nbsp;&nbsp;<a href=\"javascript:;\" onclick=\"del('" + d.filename + "\')\"><i class=\"fa fa-trash\"></i></a>"
                    } else if (d.filetype === "3" || d.filetype === "4") {
                        returnStr = "<a href=\"javascript:;\" onclick=\"viewvideo('" + d.filename + "\')\"><i class=\"fa fa-eye\"></i></a>"+"&nbsp;&nbsp;<a href=\"javascript:;\" onclick=\"del('" + d.filename + "\')\"><i class=\"fa fa-trash\"></i></a>"
                    } else if (d.filetype !== "999") {
                        returnStr = "<a href=\"javascript:;\" onclick=\"del('" + d.filename + "\')\"><i class=\"fa fa-trash\"></i></a>"
                    }
                    return returnStr
                }
            }
        ]]
    });
});

//预览图片
function viewpic(picname) {
    var urlStr = window.location.origin + "/"
    var dirStr = GetQueryString("dir")
    urlStr = urlStr + "data" + dirStr
    if (urlStr.substring(urlStr.length - 1) !== "/") {
        urlStr = urlStr + "/"
    }
    urlStr = urlStr + picname
    getImageWidth(urlStr, function (w, h) {
        layui.use('layer', function () {
            var layer = layui.layer;
            layer.open(
                {
                    type: 1,
                    title:false,
                    offset: 'auto',
                    area: [w+'px',h+'px'],
                    skin: 'layui-layer-nobg', //没有背景色
                    shadeClose: true,
                    content: '<div style=\"width: 100%; height: 100%;\"><img src=' + urlStr + ' style=\"width:100%;height:100%;\"></div>'
                })
        });
    });
}
// 获取图片真实高度
function getImageWidth(url, callback) {
    var img = new Image();
    img.src = url;
    // 如果图片被缓存，则直接返回缓存数据
    if (img.complete) {
        callback(img.width, img.height);
    } else {
        img.onload = function () {
            callback(img.width, img.height);
        }
    }
}

// 预览视频
function viewvideo(videoname) {
    var urlStr = window.location.origin + "/"
    var dirStr = GetQueryString("dir")
    urlStr = urlStr + "data" + dirStr
    if (urlStr.substring(urlStr.length - 1) !== "/") {
        urlStr = urlStr + "/"
    }
    urlStr = urlStr + videoname
    var loadstr = '<div style=\"text-align: center;width:100%;height:100%\"><video controls preload=\"auto\" width=\"99%\" height=\"99%\"><source src=\"'+urlStr+ '\"></video></div>'
    layui.use('layer', function () {
        var layer = layui.layer;
        layer.open(
            {
                type: 1,
                title:false,
                offset: 'auto',
                area: ['80%','80%'],
                skin: 'layui-layer-nobg', //没有背景色
                shadeClose: true,
                content: loadstr
            })
    });
}

//预览txt
function viewtxt(txtname) {
    var urlStr = window.location.origin + "/"
    var dirStr = GetQueryString("dir")
    urlStr = urlStr + "index/?type=txt"
    if (dirStr.substring(dirStr.length - 1) !== "/") {
        dirStr = dirStr + "/"
    }
    dirStr = dirStr + txtname
    var paramObj = {
        httpUrl: urlStr,
        type: 'post',
        async:false,
        data:{
            txt:dirStr
        }
    }
    /*请求调用*/
    httpRequest(paramObj, function (respondDada) {
        var jsonObj=JSON.parse(respondDada)
        if (jsonObj.errcode==="0"){
            layui.use('layer', function () {
                var layer = layui.layer;
                layer.open(
                    {
                        type: 1,
                        title:false,
                        offset: 'auto',
                        area: ['80%','80%'],
                        skin: 'layui-layer-nobg', //没有背景色
                        shadeClose: true,
                        content: '<div class=\"layui-bg-gray layui-font-black\" style=\"width: 100%;height: 100%\">'+jsonObj.dataStr+'</div>'
                    })
            });
        } else {
            layui.use('layer', function () {
                var layer = layui.layer;
                layer.open(
                    {
                        type: 1,
                        title:false,
                        offset: 'auto',
                        area: ['80%','80%'],
                        skin: 'layui-layer-nobg', //没有背景色
                        shadeClose: true,
                        content: '<div class=\"layui-bg-gray layui-font-black\" style=\"width: 100%;height: 100%\">'+jsonObj.errmsg+'</div>'
                    })
            });
        }
    }, function () {
        layer.msg("修改失败，可能是网断了")
    })
}
//删除文件或文件夹
function del(txtname) {
    var urlStr = window.location.origin + "/"
    var dirStr = GetQueryString("dir")
    urlStr = urlStr + "index/?type=del"
    if (dirStr.substring(dirStr.length - 1) !== "/") {
        dirStr = dirStr + "/"
    }
    dirStr = dirStr + txtname
    var paramObj = {
        httpUrl: urlStr,
        type: 'post',
        async:false,
        data:{
            path:dirStr
        }
    }
    /*请求调用*/
    httpRequest(paramObj, function (respondDada) {
        var jsonObj=JSON.parse(respondDada)
        layer.msg(jsonObj.errmsg)
        if (jsonObj.errcode === "0") {
            location.reload();
        }
    }, function () {
        layer.msg("操作失败，可能是网断了")
    })
}
// 滚动通知
    function ScrollImgLeft() {
        var speed = 50;
        var MyMar = null;
        var scroll_begin = document.getElementById("scroll_begin");
        var scroll_end = document.getElementById("scroll_end");
        var scroll_div = document.getElementById("scroll_div");
        scroll_end.innerHTML = scroll_begin.innerHTML;

        function Marquee() {
            if (scroll_end.offsetWidth - scroll_div.scrollLeft <= 0)
                scroll_div.scrollLeft -= scroll_begin.offsetWidth;
            else
                scroll_div.scrollLeft++;
        }

        MyMar = setInterval(Marquee, speed);
        scroll_div.onmouseover = function () {
            clearInterval(MyMar);
        }
        scroll_div.onmouseout = function () {
            MyMar = setInterval(Marquee, speed);
        }
    }

    ScrollImgLeft();


    <!--上传文件-->
    function createXmlHttpRequest() {
        if (window.ActiveXObject) { //如果是IE浏览器
            return new ActiveXObject("Microsoft.XMLHTTP");
        } else if (window.XMLHttpRequest) { //非IE浏览器
            return new XMLHttpRequest();
        }
    }

    function uploadFile() {
        var loading = document.getElementById('proshadow')
        loading.style.display = 'block'
        var fileObj = document.getElementById("flFile").files[0]; // js 获取文件对象
        var url = window.location.origin + "/upload/?type=file"; // 接收上传文件的后台地址
        var form = new FormData(); // FormData 对象
        form.append("file", fileObj); // 文件对象
        form.append("tardir", getCookie("token_d")) //上传到的文件夹
        var xhr = createXmlHttpRequest();  // XMLHttpRequest 对象
        xhr.open("post", url, true); //post方式，url为服务器请求地址，true 该参数规定请求是否异步处理。
        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4 && xhr.status === 200) {
                loading.style.display = 'none'
                var jsonObj = JSON.parse(xhr.responseText)
                if (jsonObj.errcode === "0") {
                    layer.msg(jsonObj.errmsg)
                    location.reload();
                } else {
                    layer.msg(jsonObj.errmsg)
                }
            }
        } //设置回调函数
        xhr.upload.onprogress = function (ev) {
            if (ev.lengthComputable) {
                var precent = Math.round((100 * ev.loaded / ev.total) * 100) / 100;
                console.log(precent);
                layui.use('element', function () {
                    var $ = layui.jquery
                        , element = layui.element; //Tab的切换功能，切换事件监听等，需要依赖element模块
                    element.progress('proshadow', precent + '%');
                });
            }
        }
        xhr.send(form); //开始上传，发送form数据
    }

    function realChoose() {
        var inputObj;
        inputObj = document.getElementById("flFile");
        if (inputObj == null) {
            inputObj = document.createElement('input')
            inputObj.setAttribute('id', 'flFile');
            inputObj.setAttribute('type', 'file');
            inputObj.setAttribute('name', 'file');
            inputObj.setAttribute("style", 'visibility:hidden');
            document.body.appendChild(inputObj);
            inputObj.value = '';
        }
        inputObj.click();
        inputObj.addEventListener('change', ev => {
            var fileObj = inputObj.files[0]; // js 获取文件对象
            var fileName = document.getElementById("flFile").value.substr(document.getElementById("flFile").value.lastIndexOf("\\") + 1);
            uploadFile()
        })
        console.log(inputObj);
    }

    <!--创建文件夹-->
    function makeDir() {
        layer.prompt({title: '输入要新建的文件夹名字'}, function (val, index) {
            layer.close(index);
            var paramObj = {
                httpUrl: window.location.origin + "/upload/?type=dir",
                type: 'post',
                async: false,
                data: {
                    path: getCookie("token_d") + "/" + val,
                }
            }
            /*请求调用*/
            httpRequest(paramObj, function (respondDada) {
                var jsonObj = JSON.parse(respondDada)
                if (jsonObj.errcode === "0") {
                    layer.msg(jsonObj.errmsg)
                    location.reload()
                } else {
                    layer.msg(jsonObj.errmsg)
                }
            }, function () {
                layer.msg("创建文件夹失败，可能是网断了")
            })
        });
    }

// 退出
    function logout() {
        layer.confirm('真的要退出吗？', {
            btn: ['确定', '点错了'] //按钮
        }, function () {
            var paramObj = {
                httpUrl: window.location.origin + "/login?type=logout",
                type: 'post',
                async: false,
            }
            /*请求调用*/
            httpRequest(paramObj, function (respondDada) {
                var jsonObj = JSON.parse(respondDada)
                if (jsonObj.errcode === "0") {
                    layer.msg(jsonObj.errmsg)
                    location.reload()
                } else {
                    layer.msg(jsonObj.errmsg)
                }
            }, function () {
                layer.msg("没有退出，可能是网断了")
            })
        }, function () {
            layer.msg("好吧，我原谅你了", {
                time: 1000
            })
        });
    }

// 头像下拉框
    layui.use(['dropdown', 'util', 'layer', 'table'], function () {
        var dropdown = layui.dropdown
        //初演示 - 绑定文字
        dropdown.render({
            elem: '#me'
            , data: [{
                title: '上传文件'
                , id: 100
            }, {
                title: '新建文件夹'
                , id: 101
            }, {
                title: '修改密码'
                , id: 102
            }, {
                title: '退出登陆'
                , id: 103
            }]
            , click: function (obj) {
                this.elem.val(obj.title);
                if (obj.id === 100) {
                    realChoose()
                } else if (obj.id === 101) {
                    makeDir()
                } else if (obj.id === 102) {
                    var urlstr = window.location.origin + "/login?type=changepwd"
                    window.location.href = urlstr
                } else if (obj.id === 103) {
                    logout()
                }
            }
        });
    });
function login(){
    var username=document.getElementById('username').value
    var password=document.getElementById('password').value
    if (username === null || username === "") {
        layer.msg("用户名不能为空")
    } else {
        var paramObj = {
            httpUrl: window.location.origin+'/login/?type=login',
            type: 'post',
            async:false,
            data: {
                name: username,
                pwd: password
            }
        }
        /*请求调用*/
        httpRequest(paramObj, function (respondDada) {
            var jsonObj=JSON.parse(respondDada)
            if (jsonObj.errcode==="302"){
                window.location.href=jsonObj.dataStr
            } else {
                layer.msg(jsonObj.errmsg)
            }
        }, function () {
            layer.msg("登录失败，可能是网断了")
        })
    }
}

function changepwd() {
    var username=document.getElementById('username').value
    var password1=document.getElementById('password1').value
    var password2=document.getElementById('password2').value
        var paramObj = {
            httpUrl: window.location.origin+'/login/?type=changepwd',
            type: 'post',
            async:false,
            data: {
                name: username,
                pwd1: password1,
                pwd2: password2
            }
        }
        /*请求调用*/
        httpRequest(paramObj, function (respondDada) {
            var jsonObj=JSON.parse(respondDada)
            if (jsonObj.errcode==="302"){
                window.location.href=jsonObj.dataStr
            } else {
                layer.msg(jsonObj.errmsg)
            }
        }, function () {
            layer.msg("修改失败，可能是网断了")
        })
}
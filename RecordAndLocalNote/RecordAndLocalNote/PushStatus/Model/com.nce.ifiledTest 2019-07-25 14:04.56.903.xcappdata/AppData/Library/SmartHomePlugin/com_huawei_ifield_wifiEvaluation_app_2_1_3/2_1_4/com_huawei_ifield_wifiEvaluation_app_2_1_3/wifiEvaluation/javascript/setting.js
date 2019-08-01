//国际化资源(JSON)
var resource = null;

//淡入淡出时间（就、毫秒）
const fadeTime = 1000

function load() {
	console.log("show")
	hwPluginService.getResource(function(data) {
		var errorCode = data.errorCode;
		if (errorCode == 0) {
			resource = data.data;
			initPage();
			queryParam();
		}
});
}

function queryParam(){
	hwPluginService.getSetting(function (v) {
		var errorCode = v.errorCode;
		if (errorCode == 0) {
			/****** setting: {ping: {pingTarget: "www.baidu.com"}} ******/
			var setting = v.data;
			
			$("#webLink").html(setting.pingTarget);
		} else {
			var errorMessage = v.errorMessage;
		}
	});
	
}

function resetting(index) {
	var openUrl = "wifiEvaluation/html/resetting.html";
	hwPluginService.openUrl({url: openUrl}, function (v) {});
}

function getResource() {
	return resource;
}

function initPage() {
	var spanArray = document.getElementsByTagName("span");
	for (var i = 0; i < spanArray.length; i++) {
		if (spanArray[i].getAttribute("locale_key")) {
			var key = spanArray[i].getAttribute("locale_key")
			spanArray[i].innerHTML = getResource()[key];
		}
	}
}

function goBack(){
	hwPluginService.goBack(function(){});
}

function reset() {
	hwPluginService.getResource(function(data) {
		var errorCode = data.errorCode;
		if (errorCode == 0) {
			resource = data.data;
			initPage();
		}
});
}

function onInput(e){
	$("#clearButton").css("display",
		"block");
}

function confirmSet(){
	var value = $("#setValue").val();
	value = $.trim(value);
	//检查值，不能为空，必须是数字
	if(value == ""){
		return;
	}
//因为现在的域名可以有很多形式，所以这个验证暂时去掉。
//	var reg=/((\/{0,3})[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&:/~\+#]*[\w\-\@?^=%&/~\+#])?)|((25[0-5]|2[0-4]\d|((1\d{2})|([1-9]?\d)))\.){3}(25[0-5]|2[0-4]\d|((1\d{2})|([1-9]?\d)))/; 
//	if(!reg.test(value)){  
//		debug("value = "+value);
//        $("#marked_words").fadeIn(fadeTime)
//        .html(getResource()["PLEASE_ENTER_RIGHT_URL"]).fadeOut(fadeTime);
//		return;
//	}
	hwPluginService.modifySetting({pingTarget: value}, function (v) {
		debug("modifySetting success: "+JSON.stringify(v));
		var errorCode = v.errorCode;
		if (errorCode == 0) {
			goBack();
		} else {
			var errorMessage = v.errorMessage;
		}
	});
}

function clearText(){
	$("#setValue").val("");
	$("#clearButton").css("display",
		"none");
}

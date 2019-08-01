//function getResource() {
//	return resource;
//}

/**
 * 卡片/应用 加载中
 */
function loading() {
	$("#Loading_div").show();
	$("#Loading").show();
	$("#Loading_fail").hide();
	$("#LoadingFail").hide();
}

/**
 * 卡片/应用 加载失败
 */
function loading_fail() {
	$("#Loading_div").show();
	$("#LoadingStart").hide();
	$("#Loading_fail").show();
	$("#LoadingFail").show();
}

/**
 * 卡片/应用 加载成功
 */
function loading_success() {
	$("#Loading_div").hide();
}

function getUrlParams(url) {
	var params = {};
	url.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(str, key, value) {
		params[key] = value;
	});
	return params;
}


/**
 * 获取手机的IP
 */
function getLocalHostIp() {
	AppJsBridge.service.socketService.getLocalHostIp({
		success : function(localHostIpInfo) {
			localHostIp = localHostIpInfo.localHostIp;
		},
		error : function(res) {
		}
	})
}

/**
 * 将信号强度从数字转换为等级
 */
function transPowerLevel(powerLevel) {
	var wifiSignal;
	if (powerLevel > -63) {
		wifiSignal = "best";
	} else if (powerLevel <= -63 && powerLevel > -69 ) {
		wifiSignal = "good";
	} else if (powerLevel <= -69 && powerLevel > -75) {
		wifiSignal = "average";
	} else {
		wifiSignal = "weak";
	}
	return wifiSignal;
}

/**
 * 国际化显示信号强度
 */
function transWifiSignal(signal) {
	var signals = [ "weak", "average", "good", "best" ];
	var arr = [ getResource()['SIGNAL_WEAK'], getResource()['SIGNAL_AVERAGE'],
			getResource()['SIGNAL_GOOD'], getResource()['SIGNAL_BEST'] ];
	for (var i = 0; i < signals.length; i++) {
		if (signal == signals[i])
			return arr[i];
	}
}

// 传来的datetime 得到结果：06-12 17:18
function dateToStr(mstime) {
	var datetime = new Date(mstime);
	var year = datetime.getFullYear();
	var month = datetime.getMonth() + 1;// js从0开始取
	var date = datetime.getDate();
	var hour = datetime.getHours();
	var minutes = datetime.getMinutes();
	var second = datetime.getSeconds();

	if (month < 10) {
		month = "0" + month;
	}
	if (date < 10) {
		date = "0" + date;
	}
	if (hour < 10) {
		hour = "0" + hour;
	}
	if (minutes < 10) {
		minutes = "0" + minutes;
	}
	if (second < 10) {
		second = "0" + second;
	}
	var time = month + "-" + date + " " + hour + ":" + minutes; // 06-12 17:18
	return time;
}

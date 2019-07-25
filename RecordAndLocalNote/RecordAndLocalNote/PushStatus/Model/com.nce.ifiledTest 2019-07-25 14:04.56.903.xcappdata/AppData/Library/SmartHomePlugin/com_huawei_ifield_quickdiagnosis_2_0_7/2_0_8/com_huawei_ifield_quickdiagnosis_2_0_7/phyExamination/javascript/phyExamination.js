// 当前体检任务ID
var currentCheckTaskId = "";
var switchFlag = "cancel";
// 未检测天数
var days = 0;
// 正在检测时候的定时器，用于等待结束后，继续检测
var waitCheck = null;
/**
 * 是否需要取消体检的标记。加上这个标记的意义在于:点击【开始体检】按钮之后有3个步骤，第一个步骤在查询所有体检项，
 * 在这个步骤进行中是不需要取消体检的；第二个步骤才是开始体检，只有开始体检且成功之后，才会返回一个体检任务ID,
 * 拿到这个id之后才开始真正的体检，且如果要取消体检，也是需要传入这个ID作为参数去取消这个体检任务。
 */
var isNeedCancel = "false";

// 一键体检定时查询
var queryInterval = null;

var checkingList = {};
// 定时查询时间间隔，单位ms
var intervalTime = 2000;

// 超时时间，默认为10分钟(5*120/60=10)
var maxIntervalTimes = 120;

// 当前查询次数
var currentTimes = 0;
// 有些体检子项的优化ID是一样的，因此需要区别
var SUB_EXTEND_TAG = "_SUB999_";

var troubleInfoObjList = [];

var classifictionList = [];

// 正在优化中的项列表
var optimizingList = [];

var classFinishNum = 0;
// 新的体检框架参数end

// 优化状态 NOTSTARTED : 未启动 OPTIMIZING : 正在优化 SUCCESS : 成功 FAILED : 失败
var OptimizationStatus = {
	NOTSTARTED: "NOTSTARTED",
	OPTIMIZING: "OPTIMIZING",
	CHECKING: "CHECKING",
	SUCCESS: "SUCCESS",
	FAILED: "FAILED"
};

// 设置一键优化超时时间为2分钟
var TIME_MINUTE = 2;

var checkItemList = [];
var supportedCheckItemList = null;
var CheckClassification = {
	WifiInterfernce: "WIFI_INTERFERENCE",// WIFI干扰类型
	WifiCoverage: "WIFI_COVERAGE",// WIFI覆盖类型
	NetworkConnect: "NETWORK_CONNECTION",// 网络连接类型
	Equipment: "DEVICE",// 设备类型
	Configuration: "CONFIGURATION",// 配置类型
	// OtherClassifiction : "OTHER_CALSSIFICTION"//
}

var GlobalTroubleTypeEmun = {
	Info: "INFO",
	Warning: "WARNING",
	Error: "ERROR"
}
var resource = null;

// 检测状态,用于展示各状态，检测提示
var checkStatus = {
	NotStart: "NOT_START",
	StartCheck: "START_CHECK",
	UserCancel: "USER_CANCEL",
	CheckFailed: "CHECK_FAILED",
	Recheck: "RECHECK",
	CheckFinished: "CHECK_FINISHED"
};

// 检测过程中错误信息
var errorContent = "";
const successCode = "0";
// 检测完成后显示多少项需要处理
var totalNeedDealWith = 0;

// 页面js的加载方法
$(function () {
	console.log("load......");
	// 调用隐藏标题的方法
	// window.AppJsBridge.service.applicationService.hideTitleBar();
	// 禁用长按弹出复制
	document.documentElement.style.webkitTouchCallout = "none";
	document.documentElement.style.webkitUserSelect = "none";
	hwPluginService.getResource(function (data) {
		var errorCode = data.errorCode;
		if (successCode == errorCode) {
			resource = data.data;
			// 初始化资源文件
			initPage();
			getLastCheckedTime();
			initStartCheckStatus();
		}
	});
});

// 根据国际化资源初始化界面
function initPage() {
	var spanArray = document.getElementsByTagName("span");
	for (var i = 0; i < spanArray.length; i++) {
		if (spanArray[i].getAttribute("local_key")) {
			var key = spanArray[i].getAttribute("local_key");
			if (getResource()[key]) {
				spanArray[i].innerHTML = getResource()[key];
			}
		}
	}
}
// 资源文件信息
function getResource() {
	return resource;
}

// 初始化开始检测时候的页面状态
function initStartCheckStatus() {
	$("#checkStatus").text(getResource()["START_CHECK"]);
	initDynamicCircle();
	initWifiName();
	initCheckClassification();

}

// 初始化显示进度的圆点
function initDynamicCircle() {
	"use strict";
	var sign = window.screen.width / 3.75;
	let
		ox = sign * 3.38 / 2.82;
	let
		oy = sign * 3.38 / 2.82;
	let
		degree = 0;
	for (var i = 0; i < 60; i++) {
		degree = i * 6;
		// 计算弧度
		let
			rad = Math.PI / 180 * degree;
		// 计算大圆上每一个A的x,y
		let
			x = Math.sin(rad) * ox - 4;
		let
			y = -(Math.cos(rad) * oy) - 4;
		$(
			'<div class="div" style="top:' + (ox + y) + 'px;left:'
			+ (ox + x) + 'px">.<div>').appendTo($("#banner"));
	}
}

// 控制代表进度的圆点
function controlCircle(nowHasChecked) {
	var checkOverCount = 0;
	for (var i in classifictionList) {
		var obj = classifictionList[i];
		if (obj == undefined || obj.checkItemList == undefined) {
			continue;
		}
	}
	var items = Math.ceil((nowHasChecked / checkItemList.length) * 60);

	$('.div').each(function (j, e) {
		if (j < items) {
			$('.div').eq(j).css('color', '#ffffff');
		}
		console.log(items);
	});
}

// 初始化检测分类
function initCheckClassification() {
	var html = "";
	var checkList = {};
	for (var item in CheckClassification) {
		html += appendCheckClassifiction(CheckClassification[item]);
		html += "</ul></li>";
	}
	$(".port_ul").html(html);

}

// 获取当前连接WIFI的名称
function initWifiName() {
	hwPluginService.getNativeWifiInfo(function (data) {
		console.log("getNativeWifiInfo:" + JSON.stringify(data));
		var ssid = data.data.SSID;
		var radioType = data.data.RadioType;
		if(ssid){
			document.getElementById("wifi_ssid").innerHTML = ssid;
		}else{
			return;
		}
	})
}

// 最后一次检测时间
function getLastCheckedTime() {
	var params = {
		"applicationName": "com.huawei.smarthome.homenetworkmanagement.NetworkManagementApplicationV2",
		"serviceName": "gatewayCheck",
		"action": "getLastCheckedTime",
	}
	hwPluginService.doAction(params, function (data) {
		if (data.success) {
			var res = data.success;
			if (res.Status == 0) {
				var status = res.result.status;
				if (status == 0) {
					var days = res.result.days;
					if (days == 0) {
						$("#count").text("");
						$("#unit").text("");
						$("#content_state").text(
							getResource()["HAS_CHECKED"]);
					} else if (days == -1) {
						$("#count").text("");
						$("#unit").text("");
						$("#content_state").text(
							getResource()["NEVER_CHECKED"]);
					} else {
						$("#count").text(res.result.days);
						if (res.result.days == 1) {
							$("#unit").text(getResource()["ONE_DAY"]);
						} else {
							$("#unit").text(getResource()["DAYS"]);
						}
						$("#content_state").text(
							getResource()["HAS_NOT_BEEN_TEST"]);
					}
				} else {
					showFailedView(getResource()["INVALID_APPLICATION_NAME"]);
				}
			} else {
				showFailedView(getResource()["NETWORK_ABNORMAL"]);
				$("#count").css("display", "none");
				$("#unit").css("display", "none");
				return;
			}
		} else if (data.failed) {
			var res = data.failed;
			if (res.errorCode == "020") {
				showGateWayOffline();
			} else {
				showErrorDes();
			}
		}

	});
}

// 开始检测
function startCheck() {
	switchFlag = "check";
	initCheckDatas();
	initCheckClassification();
	console.log("startCheck  checkItemList.length=" + checkItemList.length);
	getNewSupportedCheckItemList();
}

// 初始化检测过程中记录的各种数据的初始化
function initCheckDatas() {
	troubleInfoObjList = [];
	optimizingList = [];
	totalNeedDealWith = 0;
	$("#content_problem").text(getResource()["CHECKING"]);
	$("#content_problem").css("display", "block");
	$("#content_problem").css("font-size", "0.26rem");
	$("#checkStatus").text(getResource()["CHECK_CANCEL"]);
	$("#content_result").css("display", "none");
	$("#content_state").css("display", "none");
	$('.div').each(function () {
		$(this).css('color', '#66a5e4');
	});
	// 初始化时候，将classifictionList还原 配合 startCheck
	if (classifictionList != null) {
		for (var x in classifictionList) {
			var oldCheckList = classifictionList[x].checkItemList;
			var itemsLi = "#itemsTable_" + classifictionList[x].classifiction
				+ "_li";
			if ($(itemsLi).length > 0) {
				$(itemsLi).remove();
			}
		}
	}
	checkItemList = [];
	classifictionList = [];
	classFinishNum = 0;
}

/**
 * 查询新的体检插件的体检项
 */
function getNewSupportedCheckItemList() {
	var params = {
		"applicationName": "com.huawei.smarthome.homenetworkmanagement.NetworkManagementApplicationV2",
		"serviceName": "gatewayCheck",
		"action": "getSupportedCheckItemList"
	}
	hwPluginService.doAction(params, function (data) {
		if (data.success) {
			var res = data.success;
			if (res.Status == "0") {
				supportedCheckItemList = res.result.supportedCheckItemList;
				checkItemListCallback(supportedCheckItemList);
			}
		} else if (data.failed) {
			var res = data.failed;
			if (res.errCode == "020") {
				showGateWayOffline();
			} else {
				showErrorDes();
			}
		} else {
			showErrorDes();
		}
	});
}

// 网络异常的提示
function showGateWayOffline() {
	switchFlag = "cancel";
	$("#checkStatus").text(getResource()["CHECK_SUBITEM_AGAIN"]);
	showCancelView(false, true);
	// 隐藏所有的体检项,展示异常
	$('#content_problem').text(getResource()["GATEWAY_OFFLINE_TIP"]);
}

// 检测大类的资源文件中的国际化显示内容
function getClassification(checkClassification) {
	if (CheckClassification.WifiInterfernce == checkClassification) {
		return getResource()["WIFI_INTERFERENCE"];
	} else if (CheckClassification.WifiCoverage == checkClassification) {
		return getResource()["WIFI_COVERAGE"];
	} else if (CheckClassification.NetworkConnect == checkClassification) {
		return getResource()["NETWORK_CONNECTION"];
	} else if (CheckClassification.Equipment == checkClassification) {
		return getResource()["DEVICE"];
	} else if (CheckClassification.Configuration == checkClassification) {
		return getResource()["CONFIGURATION"];
	} else {
		return getResource()["CONFIGURATION"];
	}

}

// 获取到检测项之后，初始化优化列表和异常信息列表
function checkItemListCallback(supportedCheckItemList) {
	if (supportedCheckItemList == undefined
		|| supportedCheckItemList.length == 0) {
		showErrorDes();
		return;
	}
	try {
		// 将每个检测大项画到页面上，并将检测大项和检测项ID放到JSON对象数组中
		checkItemList = drawNewHealthCheckView(supportedCheckItemList);
		startNewCheck();
	} catch (e) {
		console.log(e);
	}
}

/**
 * 开始检测
 */
function startNewCheck() {
	currentTimes = 0;
	var params = {
		"applicationName": "com.huawei.smarthome.homenetworkmanagement.NetworkManagementApplicationV2",
		"serviceName": "gatewayCheck",
		"action": "startCheck",
		"parameters": {
			"checkItemInfoList": checkItemList
		},
	}
	hwPluginService.doAction(params, function (data) {
		if (data.success) {
			var res = data.success;
			if (res.Status == "0") {
				isNeedCancel = "true";
				// 当前检测任务ID
				currentCheckTaskId = res.result.checkTaskId;
				if(currentCheckTaskId === undefined){
					showErrorDes();
					return;
				}
				if (waitCheck != null) {
					clearInterval(waitCheck);
				}
				queryInterval = setInterval(getCurrentCheckResult,
					intervalTime);
			} else if (res.Status == "-9") {
				showWaitErrorDes();
			} else {
				showErrorDes();
			}
		} else if (data.failed) {
			showErrorDes();
		} else {
			showCancelView(false, true);
		}

	});
}

/**
 * 将支持查询的大项画到页面
 */
function drawNewHealthCheckView(supportedCheckItemList) {
	// wifi干扰类型
	var wifiInterferenceList = {};
	// wifi覆盖类型
	var wifiCoverageList = {};
	// 网络连接类型
	var networkConnectList = {};
	// 设备类型
	var equipmentList = {};
	// 配置类型
	var configurationList = {};
	// 其他类型
	var otherClassictionList = {};

	for (var index in supportedCheckItemList) {
		var supportedCheckItem = supportedCheckItemList[index];
		// 检查项ID WIFI_BANDWIDTH,WIFI_STA_SIGNAL_INTENSITY
		var checkItemId = supportedCheckItem.checkItemId;
		// 检查项所属分类 WIFI_COVERAGE, CONFIGURATION
		var checkClassification = supportedCheckItem.checkClassification;
		var checkItem = {};
		checkItem.checkItemId = checkItemId;
		checkItem.checkClassification = checkClassification;
		checkItemList.push(checkItem);
		if (CheckClassification.WifiInterfernce == checkClassification) {
			// 当前体检大项的所有体检项有没有结束，用于判断大项下的子项已全部完成体检，
			// 全部结束后再判断是大项下否有异常问题，如果没有异常问题则显示“正常”
			wifiInterferenceList[checkItemId] = "false";
		} else if (CheckClassification.WifiCoverage == checkClassification) {
			wifiCoverageList[checkItemId] = "false";
		} else if (CheckClassification.NetworkConnect == checkClassification) {
			networkConnectList[checkItemId] = "false";
		} else if (CheckClassification.Equipment == checkClassification) {
			equipmentList[checkItemId] = "false";
		} else if (CheckClassification.Configuration == checkClassification) {
			configurationList[checkItemId] = "false";
		} else {
			otherClassictionList[checkItemId] = "false";
		}
	}

	// 添加所有的体检项到体检大类里面
	var html = "";
	html = addCheckItemToView(html, wifiInterferenceList,
		CheckClassification.WifiInterfernce);
	html = addCheckItemToView(html, wifiCoverageList,
		CheckClassification.WifiCoverage);
	html = addCheckItemToView(html, networkConnectList,
		CheckClassification.NetworkConnect);
	html = addCheckItemToView(html, equipmentList,
		CheckClassification.Equipment);
	html = addCheckItemToView(html, configurationList,
		CheckClassification.Configuration);
	$(".port_ul").html(html);
	// checkItemList用于查询体检结果的入参
	return checkItemList;
}

/**
 * 把每个体检大项以及检查项列表画到页面上
 */
function addCheckItemToView(html, checkClassList, classifiction) {
	// 添加主项
	var keysList = Object.getOwnPropertyNames(checkClassList);
	if (keysList == undefined || keysList.length == 0) {
		return html;
	}
	// 用于判断是否检测完成，是否有优化内容
	var classObje = {};
	classObje.classifiction = classifiction;
	classObje.checkItemList = checkClassList;
	classObje.needOptimizationCount = 0;
	classObje.hasTrouble = 0;
	classObje.hasError = false;
	classifictionList.push(classObje);
	html += appendCheckClassifiction(classifiction);
	for (var item in checkClassList) {
		html += appendCheckItem(item);
	}
	html += "</ul></li>";
	return html;
}

/**
 * 添加检测大项
 */
function appendCheckClassifiction(classifiction) {
	var html = "<li class='out_li' id='" + classifiction
		+ "'><img class='img_bg' src='"
		+ getClassificationImg(classifiction, "init") + "' alt=''><p>"
		+ getClassification(classifiction)
		+ "</p><ul class='inner_ul' id='itemsTable_" + classifiction + "'>"
		+ "<li id='" + classifiction + "_prepare'>"
		+ getResource()["PREPARATION"] + "</li>";
	return html;
}

/**
 * 添加检测项
 */
function appendCheckItem(item) {
	return "<li class='checkItems' id='tr_" + item + "'><img id='" + item
		+ "_img' src='../image/checking.gif' alt=''><p>" + resource[item]
		+ "</p></li>"
}

/**
 * 修改检测项图标
 * 
 * @param item
 * @param result
 */
function changeItemResult(item, result) {
	$("#" + item + "_img").attr("src", "../image/" + result + ".png");
}

/**
 * 根据体检项添加大图标
 * 
 * @param checkClassification
 * @returns {*}
 */
function getClassificationImg(checkClassification, imgStatus) {
	var iconPrefix = "../image/detection_icon";
	var middle = "";
	var iconSuffix = ".png";
	if (CheckClassification.WifiInterfernce == checkClassification) {
		middle = getMiddle("1", imgStatus);
	} else if (CheckClassification.WifiCoverage == checkClassification) {
		middle = getMiddle("2", imgStatus);
	} else if (CheckClassification.NetworkConnect == checkClassification) {
		middle = getMiddle("3", imgStatus);
	} else if (CheckClassification.Equipment == checkClassification) {
		middle = getMiddle("4", imgStatus);
	} else {
		middle = getMiddle("5", imgStatus);
	}
	return (iconPrefix + middle + iconSuffix);
}

// 拼接图片名称
function getMiddle(intx, imgStatus) {
	if (imgStatus == "init") {
		return intx;
	} else if (imgStatus == "nomal") {
		return intx + "_hover";
	} else if (imgStatus == "warning") {
		return intx + "_warning";
	} else {
		return intx + "_error";
	}
}

/**
 * 获取体检结果
 */
function getCurrentCheckResult() {
	currentTimes++;
	if (currentTimes >= maxIntervalTimes) {
		showCancelView(false, false);
		return;
	}
	var params = {
		"applicationName": "com.huawei.smarthome.homenetworkmanagement.NetworkManagementApplicationV2",
		"serviceName": "gatewayCheck",
		"action": "getCheckResult",
		"parameters": {
			"checkTaskId": currentCheckTaskId
		},
	}
	hwPluginService.doAction(params, function (data) {
		if (data.success) {
			var res = data.success;
			if ("0" == res.Status) {
				updateNewHealthCheckResult(res.result);
			}

			if (res.errCode != undefined) {
				if (res.errCode == "-3") {
					showErrorMsg(getResource()["CONNECT_FAILED3"]);
				} else if (res.errCode == "-6") {
					showErrorMsg(getResource()["CONNECT_FAILED6"]);
				}
			}
		} else if (data.failed) {
			showGetCurrentCheckResultError(data.failed);
		}

	});
}

/**
 * {"errCode":"-3","errMsg":"connect failed"}
 *  {"errCode":"-6","errMsg":"empty return"}
 */
function showErrorMsg(errMsg) {
	switchFlag = "cancel";
	$("#checkStatus").text(getResource()["CHECK_SUBITEM_AGAIN"]);
	$("#content_problem").css("font-size", "0.14rem");
	$("#content_problem").text(errMsg);
	return;
}


function showGetCurrentCheckResultError(error) {
	switchFlag = "cancel";
	$("#checkStatus").text(getResource()["CHECK_SUBITEM_AGAIN"]);
	// 隐藏所有的体检项,展示异常
	$('.port_ul').html(error);
}

/**
 * 将取到的global问题（总体问题）和SUB问题（global问题的问题详情），转换成一个统一的对象
 * 
 * @param globalTroubleInfo
 * @param isGlobalTrouble
 * @returns {___anonymous41536_41537}
 */
function getTroubleInfoObj(classifiction, checkItemId, globalTroubleInfo,
	isGlobalTrouble) {
	var troubleInfoObj = {};

	troubleInfoObj.classifiction = classifiction;
	troubleInfoObj.checkItemId = checkItemId;
	troubleInfoObj.optimizationId = '';
	// 用于标记该问题是否被统计
	troubleInfoObj.isCount = false;
	if (isGlobalTrouble) {
		// 总体问题唯一ID
		troubleInfoObj.troubleId = deletePointInId(globalTroubleInfo.globalTroubleId);

		// 总体问题描述ID宏定义(资源ID)
		troubleInfoObj.troubleDescId = globalTroubleInfo.globalTroubleDescriptionId;

		// 是否为表格
		troubleInfoObj.isTable = ("TABLE" == globalTroubleInfo.globalTroubleForm) ? true
			: false;

		// 问题描述涉及的参数
		troubleInfoObj.troubleParam = globalTroubleInfo.troubleParam;

		// 问题类型
		troubleInfoObj.troubleType = globalTroubleInfo.globalTroubleType;

		// 是否为总问题
		troubleInfoObj.isGlobalTrouble = true;

		// 是否支持优化
		var tag = ("true" == globalTroubleInfo.isSupportGlobalOptimization);
		troubleInfoObj.isSupportOptimization = tag;

		if (tag) {
			var globalOptimizationInfo = globalTroubleInfo.globalOptimizationInfo;
			// 一键优化项ID
			troubleInfoObj.optimizationId = globalOptimizationInfo.globalOptimizationId;

			// 一键优化项资源ID
			troubleInfoObj.optimizationDescId = globalOptimizationInfo.globalOptimizationDescriptionId;

			// 所需权限
			troubleInfoObj.jurisdiction = globalOptimizationInfo.globalJurisdiction;

			// 优化类型
			// 取值PLUGIN、PAGE_FORWARDING
			troubleInfoObj.optimizationType = globalOptimizationInfo.globalOptimizationType;

			// 是否支持参数
			var hasParam = ("true" == globalOptimizationInfo.isSupportGlobalOptimizationParam);
			troubleInfoObj.isSupportOptimizationParam = hasParam;

			if (hasParam) {
				// 一键优化所需参数
				troubleInfoObj.optimizationParam = globalOptimizationInfo.globalOptimizationParam;
			}

			troubleInfoObj.optimizationPromptId = globalOptimizationInfo.globalOptimizationPromptId;
		}

		// 是否有问题详情
		var troubleDetailList = globalTroubleInfo.troubleDetailList;
		if (troubleDetailList && troubleDetailList.length > 0) {
			troubleInfoObj.hasDetails = true;
			troubleInfoObj.troubleDetailList = troubleDetailList;
		} else {
			troubleInfoObj.hasDetails = false;
		}
	} else {

		// 详情下的问题唯一ID
		troubleInfoObj.troubleId = deletePointInId(globalTroubleInfo.subTroubleId);

		// 问题描述ID宏定义(资源ID)
		troubleInfoObj.troubleDescId = globalTroubleInfo.troubleDescriptionId;

		// 是否为表格
		troubleInfoObj.isTable = ("TABLE" == globalTroubleInfo.troubleForm) ? true
			: false;

		// 问题描述涉及的参数
		troubleInfoObj.troubleParam = globalTroubleInfo.troubleParam;

		// 问题详情下面是没有问题类型的
		troubleInfoObj.troubleType = "";

		// 是否为总问题
		troubleInfoObj.isGlobalTrouble = false;

		// 是否支持优化
		var tag = ("true" == globalTroubleInfo.isSupportOptimization);
		troubleInfoObj.isSupportOptimization = tag;

		if (tag) {
			var optimizationInfo = globalTroubleInfo.optimizationInfo;
			// 一键优化项ID
			troubleInfoObj.optimizationId = optimizationInfo.optimizationId;

			// 一键优化项资源ID
			troubleInfoObj.optimizationDescId = optimizationInfo.optimizationDescriptionId;

			// 优化类型
			// 取值PLUGIN、PAGE_FORWARDING
			troubleInfoObj.optimizationType = optimizationInfo.optimizationType;

			// 所需权限
			troubleInfoObj.jurisdiction = optimizationInfo.jurisdiction;

			// 是否支持参数
			var hasParam = ("true" == optimizationInfo.isSupportOptimizationParam);

			troubleInfoObj.isSupportOptimizationParam = hasParam;

			if (hasParam) {
				// 一键优化所需参数
				troubleInfoObj.optimizationParam = optimizationInfo.optimizationParam;

			}
			troubleInfoObj.optimizationPromptId = optimizationInfo.optimizationPromptId;
		}

		// 问题详情里面不会再嵌套问题详情
		troubleInfoObj.hasDetails = false;
	}
	updateTroubleInfoObjList(troubleInfoObj);
	return troubleInfoObj;
}

/**
 * 将troubleId中的小点，转成短杠
 * 
 * @param id
 * @returns {*}
 */
function deletePointInId(id) {
	if (id && id.indexOf('.') > -1) {
		return id.replace('.', '-');
	} else {
		return id;
	}
}

/**
 * 将troubleId中的短杠，转回去成小点
 * 
 * @param id
 *            如2.4G的小点
 * @returns {*}
 */
function addPointIntoId(id) {
	if (id && id.indexOf('-') > -1) {
		return id.replace('-', '.');
	} else {
		return id;
	}
}

/**
 * 刷新可优化的项目列表
 * 
 * @param checkItemId
 * @param troubleInfoObj
 */
function updateTroubleInfoObjList(troubleInfoObj) {
	// troubleInfoObjList为所有问题的列表，当优化时，从该对象中取到其他的参数
	var hasDetailsCount = 0;
	for (var i in troubleInfoObjList) {
		if (troubleInfoObj.checkItemId == troubleInfoObjList[i].checkItemId
			&& troubleInfoObj.optimizationId == troubleInfoObjList[i].optimizationId
			&& addPointIntoId(troubleInfoObj.troubleId) == addPointIntoId(troubleInfoObjList[i].troubleId)) {
			if (troubleInfoObjList[i].isCount) {
				troubleInfoObj.isCount = true;
			}
			troubleInfoObjList.splice(i, 1);
		}
	}

	troubleInfoObjList.push(troubleInfoObj);
	// 每次新添加一个问题点，与标识检测是否完成的对象对比，如果该大类下此问题点未被统计过，统计数加一
	for (var x in classifictionList) {
		var obj = classifictionList[x];
		if (obj == undefined || obj.checkItemList == undefined) {
			continue;
		}
		for (var j in troubleInfoObjList) {
			if (troubleInfoObjList[j].classifiction == obj.classifiction
				&& !troubleInfoObjList[j].isCount) {
				if (troubleInfoObjList[j].isSupportOptimization) {
					obj.needOptimizationCount++;
				} else {
					// 提示性问题
					obj.hasTrouble++;
				}
				troubleInfoObjList[j].isCount = true;
			}

			if (troubleInfoObjList[j].classifiction == obj.classifiction
				&& troubleInfoObjList[j].hasDetails) {
				hasDetailsCount++;
				//				console.log("updateTroubleInfoObjList   hasDetailsCount :  j" + j+";"
				//						+ JSON.stringify(troubleInfoObjList[j]));
			}
		}
		// 更新每个问题点对应的检测大类下，需要优化的项
		var optimizationCount = obj.needOptimizationCount + obj.hasTrouble;
		if (optimizationCount > 0) {
			$('#' + obj.classifiction + "_prepare").text(
				getDealWithContent(optimizationCount));
			$('#' + obj.classifiction + "_prepare").css("color", "#E54545");
		}
	}
	totalNeedDealWith = troubleInfoObjList.length - hasDetailsCount;
	//	console.log("updateTroubleInfoObjList  : "
	//			+ JSON.stringify(troubleInfoObjList));
}

/**
 * 更新新的插件的体检项
 * 
 * @param checkResultInfo
 */
function updateNewHealthCheckResult(result) {
	if (result) {
		classFinishNum = 0;
		var status = result.status;
		if ("0" != status) {
			// 如果status不为0，则表示体检任务已失败，则需要把“预备中”、“正在检测：XXX”的项目刷成完成的状态，提示：检测任务已失败，请稍候重试。
			showCancelView(false, true);
			return;
		}
		var nowHasChecked = 0;

		// var checkResultList = result.checkResultList;
		var checkResultList = result.checkResultList;
		if (checkResultList && checkResultList.length > 0) {
			for (i in checkResultList) {
				var checkItem = checkResultList[i];

				// 检查项ID
				var checkItemId = checkItem.checkItemId;

				// 检查状态。 未启动 NOTSTARTED、正在检查 CHECKING、成功 SUCCESS、失败 FAILED
				var checkStatus = checkItem.checkStatus;

				// 本项检查成功，则去解析是否存在问题，其他均不解析
				var classifiction = getClassifiction(checkItemId);

				if (OptimizationStatus.SUCCESS == checkStatus) {
					// 单个检查项的问题列表
					var checkResultInfoList = checkItem.checkResultInfoList;
					for (j in checkResultInfoList) {

						// 总体问题信息(对象)
						var globalTroubleInfo = checkResultInfoList[j].globalTroubleInfo;
						if (globalTroubleInfo == undefined) {
							continue;
						}
						var _troubleObj = getTroubleInfoObj(classifiction,
							checkItemId, globalTroubleInfo, true);
						var _troubleDescId = _troubleObj.troubleDescId;
						var _troubleId = _troubleObj.troubleId;
						var _optimizationId = _troubleObj.optimizationId;

						// 外部异常ID使用_troubleDescId和_troubleId拼接成一个唯一的ID
						if ($('#' + _troubleDescId + _troubleId).length == 0) {
							var globalHtml = addGlobalTroubleInfoView(
								_troubleObj, true);
							if ($('#itemsTable_' + classifiction + ' .'
								+ _troubleId + _optimizationId).length == 0) {
								$('#itemsTable_' + classifiction).append(
									globalHtml);
							} else {
								$(
									'#itemsTable_' + classifiction + ' .'
									+ _troubleId + _optimizationId
									+ ':last').after(globalHtml);
							}
							console.log("globalHtml: "
								+ JSON.stringify(globalHtml));
						}

						/*
						 * 先判断是否有问题详情？此处添加详情之后，在问题对象里，统计需要优化的项目，对检测大类做标记
						 * 如果有问题详情，问题详情需要用单独页面显示
						 */
						var troubleDetailList = globalTroubleInfo.troubleDetailList;
						if (troubleDetailList && troubleDetailList.length > 0) {
							console.log("troubleDetailList  : "
								+ JSON.stringify(troubleDetailList));
							for (var index in troubleDetailList) {
								var subTroubleObj = troubleDetailList[index];
								if (subTroubleObj) {
									var _subTroubleObj = getTroubleInfoObj(
										classifiction, checkItemId,
										subTroubleObj, false);
									// 问题详情，用同样的方法，不同参数标识
									var detailhHtml = addGlobalTroubleInfoView(
										_subTroubleObj, false);
									if ($('#itemsTable_' + classifiction + ' .'
										+ _troubleId + _optimizationId).length > 0) {
										var detailsId = "#"
											+ _subTroubleObj.troubleDescId
											+ _subTroubleObj.troubleId;
										if ($(detailsId).length == 0) {
											$('#itemsTable_' + classifiction
												+ ' .' + _troubleId + _optimizationId
												+ ':last').after(detailhHtml);
											// console.log("detailhHtml" +
											// detailhHtml);
										}
									}

								}
							}
						}
					}
					if (checkingList[classifiction]) {
						var _pos = $.inArray(checkItemId,
							checkingList[classifiction]);
						if (_pos > -1) {
							checkingList[classifiction].splice(_pos, 1);
						}
					}
					// 判断是否已全部检查完了，显示对应的结果
					isClassifictionFinished(checkItemId);
				} else if (OptimizationStatus.FAILED == checkStatus) {
					console.log("check failed : " + JSON.stringify(checkItem));
					// 检测失败了，把检测失败的检测项显示出来
					updateHasError(classifiction, checkItemId);
					isClassifictionFinished(checkItemId);
				} else if (OptimizationStatus.CHECKING == checkStatus) {
					// 正在检测中的检测项标记为检测中，并修改对应样式
					updateCheckingStaus();
					if (checkingList[classifiction] == undefined) {
						checkingList[classifiction] = [];
						checkingList[classifiction].push(checkItemId);
						console.log("checkingList:"
							+ JSON.stringify(checkingList));
					} else {
						if ($.inArray(checkItemId, checkingList[classifiction]) == -1) {
							checkingList[classifiction].push(checkItemId);
						}
					}
				}
			}
			try {
				// 判断是否检测完成
				checkItmesIsSuccess();
			} catch (e) {
				console.log("checkItemsError : " + e);
			}
		}
	}
}

/**
 * 检测失败之后，更新页面样式
 */
function updateHasError(classifiction, checkItemId) {
	for (var x in classifictionList) {
		var obj = classifictionList[x];
		if (obj == undefined || obj.checkItemList == undefined) {
			continue;
		}
		if (obj.classifiction == classifiction) {
			obj.hasError = true;
		}
	}
	var imgPath = getClassificationImg(classifiction, "error");
	$("#" + classifiction + " .img_bg").attr('src', imgPath);
	changeItemResult(checkItemId, "netcheck_err");
	$("#tr_" + checkItemId).css("display", "flex");
	$("#" + classifiction + "_prepare").text(getResource()["CHECKING"]);
	$("#" + classifiction + "_prepare").css("color", "#2193FC");
}

/**
 * 检测过程中，更新页面样式
 */
function updateCheckingStaus(classifiction, checkItemId) {
	var imgPath = getClassificationImg(classifiction, "nomal");
	$("#" + classifiction + " .img_bg").attr('src', imgPath);
	$("#" + classifiction + "_prepare").text(getResource()["CHECKING"]);
	$("#" + classifiction + "_prepare").css("color", "#2193FC");
}

/**
 * 启动带参数的优化操作
 */
function startOptimization(optimizationInfoList, newIds) {
	console.log("startOptimizationWithPara : "
		+ JSON.stringify(optimizationInfoList));
	if (optimizationInfoList.length > 0) {
		$('#win_warning').remove();
		// 优化按钮先隐藏
		$('#' + newIds).css("visibility", "hidden");
		var params = {
			"applicationName": "com.huawei.smarthome.homenetworkmanagement.NetworkManagementApplicationV2",
			"serviceName": "gatewayCheck",
			"action": "startOptimization",
			"parameters": {
				"checkTaskId": currentCheckTaskId,
				"optimizationInfoList": optimizationInfoList
			},
		}
		hwPluginService.doAction(params, function (data) {
			if (data.success) {
				var result = data.success;
				console.log("optimizationResult = "
					+ JSON.stringify(result));
				$('#mask').remove();
				// {"errCode":"-2","errMsg":"timeout"}
				// {"errCode":"-3","errMsg":"connect failed"}
				// {"result":{"optimizationResultList":[{"optimizationId":"OPTIMIZATION_RESELECT_WHOLE_NETWORK_CHANNEL","troubleId":"3C15FB42DB3B_2.4G","optimizationStatus":"SUCCESS","checkItemId":"WIFI_INTERFERENCE_TRAFFIC"}],"status":"0"},"Status":"0","errCode":"0","error_Desc":"SUCCESS","errorMessage":"","errorCode":"0","CmdType":"applicationManager.doAction","SequenceId":"0x00000153"}
				var errCode = result.errCode;
				if (errCode == "-2") {
					var message = getResource()["OPTIMIZATION_TIME_OUT"];
					showFailedView(message);
					return;
				}
				if (errCode == "-3") {
					var message = getResource()["CONNECT_FAILED"];
					showFailedView(message);
					return;
				}
				var status = result.result.status;
				if (status != null && status == "0") {
					var optimizationResult = result.result.optimizationResultList;
					// 1、多个优化项和单个优化项的按钮隐藏，子项或者无关联的检测项，优化完成直接隐藏检测项
					if (optimizationResult
						&& optimizationResult.length > 0) {
						for (j in optimizationResult) {
							var _checkItemId = optimizationResult[j].checkItemId;
							var _optimizationId = optimizationResult[j].optimizationId;
							var optimizationStatus = optimizationResult[j].optimizationStatus;
							var _troubleId = deletePointInId(optimizationResult[j].troubleId);
							var _failReason = optimizationResult[j].failReason;
							for (m in optimizationInfoList) {
								var optInfo = optimizationInfoList[m];
								var tmpOptId = optInfo.optimizationId;
								var _troubleId = optInfo.troubleId;
								var _optId = optInfo.optimizationId;
								var _hasDetails = optInfo.hasDetails;
								var _isSubTrouble = optInfo.optimizationType == "SUB" ? true
									: false;

								if (optInfo.checkItemId == _checkItemId
									&& tmpOptId == _optimizationId
									&& optInfo.troubleId == _troubleId) {

									if (OptimizationStatus.SUCCESS == optimizationStatus) {
										// 2.把成功的项从列表中移除，
										// 如果是子项，则要查一下上所有的子项是否已优化完
										var _id = '.'
											+ deletePointInId(_troubleId)
											+ _optimizationId;
										if (_isSubTrouble) {
											var siblings = $(_id)
												.siblings(
													"."
													+ _checkItemId);
											if (siblings.length == 1) {
												var prev = $(_id)
													.prev();
												// STA_SPEED_LIMIT_TROUBLESAVE_ALL
												var prevId = prev
													.attr("id");
												// SAVE_ALLOPTIMIZATION_CANCEL_STA_SPEED_LIMIT_ALL
												// OPTIMIZATION_CANCEL_STA_SPEED_LIMIT
												var preClassList = prev
													.attr("class")
													.split(" ");
												var troubleOptimizationId = preClassList[2];
												if ($(_id)) {
													$(_id).remove();
													prev.remove();
													removeParentTrouble(
														troubleOptimizationId,
														_optimizationId);
												}
											} else {
												if ($(_id)) {
													$(_id).remove();
												}
											}
										} else {
											$(_id).remove();
											// 如果有trouble详情，将详情删除
											if (_hasDetails) {
												var newOptId = "."
													+ _troubleId
													+ tmpOptId
														.substring(
															0,
															tmpOptId.length - 4);
												$(newOptId).remove();
											}
										}
										// 3.判断是否所有的项已成功，如果已成功则添加正常的状态
										updateNeedOptimizationItem(optimizationResult[j]);
									} else if (OptimizationStatus.FAILED == optimizationStatus) {
										// 优化失败
										// 优化按钮显示
										$('#' + newIds)
											.css("visibility",
												"visible");
										if (_failReason == "-1") {
											var message = getResource()["OPTIMIZATION_TIME_OUT"];
											showFailedView(message);
										}
										// 问题详情处理 failReason -1
										if (!_isSubTrouble) {
											if (_hasDetails) {
												var newOptId = "."
													+ _troubleId
													+ tmpOptId
														.substring(
															0,
															tmpOptId.length - 4);
												$(newOptId).css(
													'visibility',
													'visible');
												var newOptimizationId = getSubOptimizationId(
													tmpOptId
														.substring(
															0,
															tmpOptId.length - 4),
													_troubleId);
												$(
													"#"
													+ newOptimizationId)
													.css(
														'visibility',
														'visible');
												$(".subButton").css(
													'visibility',
													'visible');
												$(".subButton").css(
													'display',
													'block');
											} else {
												var newOptId = "."
													+ _troubleId
													+ tmpOptId;
												$(newOptId).css(
													'visibility',
													'visible');
												var newOptimizationId = getSubOptimizationId(
													tmpOptId,
													_troubleId);
												$(
													"#"
													+ newOptimizationId)
													.css(
														'visibility',
														'visible');
											}
										}
									} else {
										$('#' + optimizationId)
											.css("visibility",
												"visible");
										$(
											'#' + troubleDescId
											+ troubleId
											+ '_chkimg')
											.attr("src",
												"../image/netcheck_tip.png");
									}
								}
							}
						}
					} else {
						$('#' + optimizationId).css("visibility",
							"visible");
						$('#' + troubleDescId + troubleId + '_chkimg')
							.attr("src",
								"../image/netcheck_tip.png");
					}
				}
			} else if (data.failed) {
				$('#mask').remove();
				$('#' + optimizationId).css("visibility", "visible");
				$('#' + troubleDescId + troubleId + '_chkimg').attr(
					"src", "../image/netcheck_tip.png");
			}
		});
	}
}

// 如果子检测项移除完成，把父检测项移除
function removeParentTrouble(troubleOptimizationId, _optimizationId) {
	var parentOptimizationId = _optimizationId + "_ALL";
	var parentTroubleId = troubleOptimizationId.replace(parentOptimizationId,
		"");
	var hasOptimization = 0;
	for (var i in troubleInfoObjList) {
		var troubleId = addPointIntoId(troubleInfoObjList[i].troubleId);
		var troubleOptimizationId = troubleInfoObjList[i].optimizationId;
		if (troubleId == parentTroubleId
			&& troubleOptimizationId == parentOptimizationId) {
			troubleInfoObjList.splice(i, 1, {});
			hasOptimization++;
		}
	}
	totalNeedDealWith = totalNeedDealWith - hasOptimization;
	console.log("removeParentTrouble totalNeedDealWith:" + totalNeedDealWith);

}

// 显示失败信息
function showFailedView(message) {
	html = "<div id='mask'></div><div id='err_tips' class='err_tips'>"
		+ "<span class='tips_title'>"
		+ getResource()["OPTIMIZATION_PARAM_DIALOG_TITLE"] + "</span>"
		+ "<span class='win_span'>" + message + "</span>"
		+ "<span class='sure_span' onclick='removeTips();'> "
		+ getResource()["BUTTON_CONFIRM"] + "</span></div>";
	$(document.body).append(html);
}

// 移除错误提示
function removeTips() {
	$("#mask").remove();
	$("#err_tips").remove();
}

// 优化完成之后，更新优化状态
function updateNeedOptimizationItem(optimizationResultj) {
	console.log("troubleInfoObjList问题:" + JSON.stringify(troubleInfoObjList));
	// 添加注释，优化完之后，对页面数据及样式进行修改
	var hasOptimization = 0;
	for (var i in troubleInfoObjList) {
		var troubleId = addPointIntoId(troubleInfoObjList[i].troubleId);
		var troubleOptimizationId = troubleInfoObjList[i].optimizationId;
		var checkItemId = troubleInfoObjList[i].checkItemId;
		// 长度大于1，说明是操作优化所有问题项按钮
		/*
		 * optimizationResultj= { "optimizationId":
		 * "OPTIMIZATION_MODIFY_WIFI_SSID_NAME_PROMPT", "troubleId": "5",
		 * "optimizationStatus": "SUCCESS", "checkItemId":
		 * "WIFI_SSID_NAME_CONFLICT" }
		 */
		var optimizationTroubleId = optimizationResultj.troubleId;
		var optimizationId = optimizationResultj.optimizationId;
		// 只用问题ID和优化ID判断是不是同一类问题
		if (troubleId == optimizationTroubleId
			&& troubleOptimizationId == optimizationId) {
			troubleInfoObjList.splice(i, 1, {});
			hasOptimization++;
		} else {
			if (checkItemId == "WIFI_SSID_NAME_CONFLICT") {
				var troubleParam = troubleInfoObjList[i].troubleParam;
				var troubleDescId = troubleInfoObjList[i].troubleDescId;
				for (var x in troubleParam) {
					var ssid_index = troubleParam[x].SSID_INDEX;
					// 如果是修改WIFI名称，对应所有AP设备的问题点都会被优化，问题项需要移除
					if (optimizationTroubleId == ssid_index) {
						troubleInfoObjList.splice(i, 1, {});
						hasOptimization++;
						var apOptimizationId = troubleDescId + troubleId;
						$("#" + apOptimizationId).css("display", "none");
					}
				}
			}
		}

	}
	totalNeedDealWith = totalNeedDealWith - hasOptimization;
	// 每次优化，检测每个大类是否优化完成，优化完成，更新成正常状态
	for (var key in CheckClassification) {
		var updateToNomal = true;
		for (var x in troubleInfoObjList) {
			if ((troubleInfoObjList[x] != undefined && troubleInfoObjList[x] != {})
				&& troubleInfoObjList[x].classifiction == CheckClassification[key]) {
				updateToNomal = false;
			}
		}
		if (updateToNomal) {
			addCheckNomarlCompleteView(CheckClassification[key]);
		}
	}
	console.log("updateNeedOptimizationItem totalNeedDealWith:"
		+ totalNeedDealWith);
	if (totalNeedDealWith < 0) {
		totalNeedDealWith = 0;
	}
	$("#count").text(totalNeedDealWith);
}

// 从拼接的问题点ID里提取真正的问题点ID
function getTroubleId(optimizationId) {
	var tmpOptimizationId = getOptimizationIdSplitSUB(optimizationId);

	var trId = optimizationId.replace(tmpOptimizationId, '');

	if (trId) {
		return trId.replace(SUB_EXTEND_TAG, '');
	}
	return trId;
}

function showCheckingItems() {
	var checkList = Object.getOwnPropertyNames(checkingList);

	for (i in checkList) {
		var item = checkList[i];

		var list = checkingList[item];

		var txt = "";

		for (var j = 0; j < list.length; j++) {
			var msg = getResource()[list[j]];
			if (txt != "" && txt.indexOf(msg) > -1) {
				continue;
			}
			if (j + 1 == list.length) {
				txt += msg;
			} else {
				txt += msg + ", ";
			}
		}

		if (txt != "") {
			$('#' + item + '_txt').text(
				getResource()["NOW_CHECKING"].replace('{0}', txt));
		}
	}
}

/**
 * 添加global问题的异常详情
 * 
 * @param troubleInfoObj
 *            封装的统一的一个问题对象
 */
function addGlobalTroubleInfoView(troubleInfoObj, isGlobal) {
	// 检查项ID
	var checkItemId = troubleInfoObj.checkItemId;

	// 是总问题
	var isGlobalTrouble = troubleInfoObj.isGlobalTrouble;

	// 问题ID
	var troubleId = troubleInfoObj.troubleId;

	// 问题描述ID
	var troubleDescId = troubleInfoObj.troubleDescId;

	// 是否为表格
	var isTable = troubleInfoObj.isTable;

	// 总体问题描述类型，取值INFO、ERROR、WARNING
	var troubleType = troubleInfoObj.troubleType;

	// 是否有问题详情
	var hasDetails = troubleInfoObj.hasDetails;

	// 问题点内容
	var troubleParam = troubleInfoObj.troubleParam;

	// 问题详情
	var troubleDetailList = troubleInfoObj.troubleDetailList;

	// 优化项ID，支持优化时候才不为空
	var _optimizationId = "";

	// 优化是否支持参数，只有总问题那里，修改ssid名称和密码才有这个参数
	var optimizationParam = troubleInfoObj.optimizationParam;

	// 是否支持一键优化
	var isSupportOptimization = troubleInfoObj.isSupportOptimization;

	// 权限
	var hasPermissions = troubleInfoObj.jurisdiction;

	// 优化类型 取值： PAGE_FORWARDING、PLUGIN 、无
	var optimizationType = troubleInfoObj.optimizationType;

	if (isSupportOptimization) {
		_optimizationId = troubleInfoObj.optimizationId;
	}

	var newId = getSubOptimizationId(_optimizationId, troubleId);

	troubleInfoObj.newIds = newId;
	// 将对象转义为字符串，用于页面跳转传参
	var strTrouble = JSON.stringify(troubleInfoObj).replace(/\"/g, "'");

	// 一键优化中文提示信息
	var optimizationPromptId = troubleInfoObj.optimizationPromptId;

	var html = "";
	var globalOrSub = (isGlobal == true) ? "globalTrouble" : "subTrouble";
	// 无权限的直接隐藏优化按钮，支持优化且有权限的，添加支持优化的中文按钮；支持优化的不一定有提示，有提示的一定支持优化
	// 有提示的点击优化按钮后弹窗提示，有子优化项的跳转到新页面
	if (hasPermissions == "ALL" || hasPermissions == "CUSTOMER") {
		if (isSupportOptimization) {
			var tips = getResource()[troubleInfoObj.optimizationDescId];
			// 无子优化项的，点击优化，有提示，弹窗提示，无提示直接优化
			if (isGlobal) {
				html += getHtmlAndMessage("globalTrouble", troubleDescId,
					troubleId, troubleParam, _optimizationId, checkItemId,
					isTable);
				if ("PLUGIN" == optimizationType && hasPermissions == "ALL") {
					// 支持优化，权限是ALL，优化类型为PLUGIN，不支持优化参数的，将中文提示拼接起来，添加优化按钮
					if (!optimizationParam) {
						// 拼接用于优化时候，取优化ID和问题ID的字符串
						if ($('#' + newId).length == 0) {
							html += " <button  id='" + newId
								+ "' onclick=\"optimizationOperation("
								+ strTrouble + " )\">" + tips
								+ " </button>";
						} else {
							html += "<button class='hideButton'></button> ";
						}
						// 支持优化，权限是ALL，优化类型为PLUGIN，支持优化参数的，点击优化时候，先弹窗提示，再弹窗输入参数
					} else {
						if ($('#' + newId).length == 0) {
							html += " <button  id='"
								+ newId
								+ "' onclick=\"getParamOperation( 'SSID_NAME',"
								+ strTrouble + " )\">" + tips
								+ " </button>";
						}
					}
					// TODO支持优化，权限是ALL，且优化类型为PAGE_FORWARDING的，跳转到新页面
				} else if (hasPermissions == "ALL"
					&& "PAGE_FORWARDING" == optimizationType) {
					if (troubleInfoObj.optimizationDescId != "OPTIMIZATION_CHECK_ATTATCH_DEVICE_LIST_TITLE") {
						html += " <button  id='" + newId
							+ "' onclick=\"showFailedView("
							+ getResource()["GO_TO_CONNECT_DEVICES_PAGE"]
							+ " )\">" + tips + " </button>";
					}
					// 支持优化，权限是CUSTOMER，且优化类型为PLUGIN的，修改密码，点击后提供输入弹窗
				} else if (isSupportOptimization
					&& hasPermissions == "CUSTOMER"
					&& "PLUGIN" == optimizationType) {
					if ($('#' + newId).length == 0) {
						html += " <button  id='" + newId
							+ "' onclick=\"getParamOperation('PASSWORD', "
							+ strTrouble + " )\">" + tips + " </button>";
					}
				}
			} else {
				console.log("问题详情： troubleInfoObj:"
					+ JSON.stringify(troubleInfoObj));
				html += getHtmlAndMessage("subTrouble", troubleDescId,
					troubleId, troubleParam, _optimizationId, checkItemId,
					isTable);
				if (!isTable) {
					html += " <button class='subButton' id='" + newId
						+ "' onclick=\"optimizationOperation(" + strTrouble
						+ " )\">" + tips + " </button>";
				} else {
					html += "<button class='hideButton'></button> ";
				}
				console.log("html:" + html);
			}
			// 不支持优化的内容，直接显示问题点
		} else {
			html += getHtmlAndMessage(globalOrSub, troubleDescId, troubleId,
				troubleParam, _optimizationId, checkItemId, isTable);
			html += "<button class='hideButton'></button> ";
		}
	} else {
		html += getHtmlAndMessage(globalOrSub, troubleDescId, troubleId,
			troubleParam, _optimizationId, checkItemId, isTable);
		html += "<button class='hideButton'></button> ";
	}
	html += "</li>";
	return html;
}

// 弹窗传参，密码，wifi名称的限制
function getParamOperation(paramType, troubleInfoObj) {
	var tipMsg = getResource()[troubleInfoObj.optimizationPromptId];
	var html = getDialogHtml(tipMsg);
	$(document.body).append(html);
	$(".bottom_right_button").click(function () {
		inputParam(paramType, troubleInfoObj);
	});

}

// 需要入参的弹出输入框
function inputParam(paramType, obj) {
	$("#win_warning").remove();
	var optimizationInfoList = [];
	var optimizationParam = {};
	var startOptimizationParam = {};
	var middleContent = "";
	if (paramType == "SSID_NAME") {
		middleContent = '<div class="ssid_name"><lable>'
			+ getResource()["SSID_NAME"]
			+ '</lable>'
			+ '<input name="ssid_name" type="text"  value="" id="ssid_name" maxlength="32"></div>'// <!--8指的是8个汉字，8个字符--></td>
			+ '<div class="empty_tips"> </div>'
	} else {
		middleContent = '<div class="ssid_name"><lable>'
			+ getResource()["PASSWORD"]
			+ '</lable>'
			+ '<input name="pwd" type="password" value="" id="pwd" maxlength="63"></div>'
			+ '<div class="empty_tips"></div>'
	}

	var table = '<form name="form1" method="post" action="">' + middleContent
		+ "</form>";
	var html = '<div id="win_warning" class="win_warning">'
		+ '<div class="middle_desc"><span>'
		+ getResource()["INPUT_PARAMETERS_TIP"] + '</span></div>' + table
		+ '<div class="bottom_button">'
		+ '<div class="bottom_left_button" onclick="closeWarningWin();">'
		+ '<span>' + getResource()["BUTTON_CANCEL"] + '</span>' + '</div>'
		+ '<div class="bottom_right_button">' + '<span>'
		+ getResource()["BUTTON_CONFIRM"] + '</span>' + '</div>' + '</div>'
		+ '</div>';
	$(document.body).append(html);
	$(".bottom_right_button")
		.click(
			function () {
				newIds = obj.newIds;
				hasDetails = obj.hasDetails;
				troubleId = obj.troubleId;
				troubleDescId = obj.troubleDescId;
				checkItemId = obj.checkItemId;
				troubleType = obj.troubleType;
				isSubTrouble = !obj.isGlobalTrouble;
				if (paramType == "SSID_NAME") {
					var ssid_name = form1.ssid_name.value;// 获取表单form1的用户名的值
					var reg = /^[\w\W]{1,32}$/;
					var result = reg.test(ssid_name);
					if ((ssid_name == "") || (ssid_name == null)) {//
						if ($("#ssid_name").val() == "") {
							$(".empty_tips").text(
								getResource()["PLEASE_INPUT_SSID"]);
						}
						return;
					} else {
						if (!result) {
							$(".empty_tips").text(
								getResource()["SSID_ERR_TIP"]);
							return;
						} else {
							var optimizationParam = {};
							optimizationParam["SSID_NAME"] = ssid_name;
						}
					}
				} else {
					var password = form1.pwd.value;// 获取表单form1密码值
					var reg = /^[a-zA-Z0-9`~!@#$%^&*()_\-+=<>?:"{}|,.\/;'\\[\]]{8,64}$/;
					var result = reg.test(password);
					if (password == "" || password == null) {
						if ($("#ssid_name").val() == "") {
							$(".empty_tips").text(
								getResource()["PLEASE_INPUT_PWD"]);
						}
						return;
					}
					if (!result) {
						$(".empty_tips").text(
							getResource()["PASSWOD_ERR_TIP"]);
						return;
					}
					var optimizationParam = {};
					optimizationParam["SSID_PASSWORD"] = password;
				}
				startOptimizationParam = {
					"checkItemId": checkItemId,
					"optimizationType": obj.isGlobalTrouble ? "GLOBAL"
						: "SUB",
					"troubleId": addPointIntoId(troubleId),
					"optimizationId": obj.optimizationId,
					"isSupportOptimizationParam": obj.isSupportOptimizationParam ? "true"
						: "false",
					"optimizationParam": optimizationParam
				}
				optimizationInfoList.push(startOptimizationParam);
				startOptimization(optimizationInfoList, newIds);
			});
}

// 问题点展示的html
function getHtmlAndMessage(troubleType, troubleDescId, troubleId, troubleParam,
	_optimizationId, checkItemId, isTable) {
	var isTableElement = "";
	if (!isTable) {
		isTableElement = getErrorMessage(troubleParam, troubleDescId)
	} else {
		var objKey = Object.getOwnPropertyNames(troubleParam[0]);
		isTableElement += "<ul class='table'><li>";
		for (key in objKey) {
			isTableElement += "<div class='tableClass'>"
				+ getResource()[objKey[key]] + "</div>";
		}
		isTableElement += "</li>"
		// 添加表内容
		troubleParam = troubleParam.sort(compare("TIME"));
		for (i in troubleParam) {
			// 每行数据新建一行
			isTableElement += "<li>"
			for (j in objKey) {
				// 已经确认过，表格中的数据不需要进行翻译，如果要翻译，需要修改一下getTroubleContent方法再调用
				isTableElement += "<div class='tableClass'>"
					+ troubleParam[i][objKey[j]] + "</div>";
			}
			isTableElement += "</li>"
		}
		isTableElement += "</ul>";
	}
	if (troubleType == "globalTrouble") {
		var html = "<li class='" + troubleType + " " + checkItemId + " "
			+ troubleId + _optimizationId + "' id='" + troubleDescId
			+ troubleId + "'><img src='../image/netcheck_tip.png' id='"
			+ troubleDescId + troubleId + "_chkimg' alt=''><p>"
			+ isTableElement + "</p>";
	} else {
		var html = "<li class='" + troubleType + " " + checkItemId + " "
			+ troubleId + _optimizationId + "' id='" + troubleDescId
			+ troubleId + "'><p>"
			+ isTableElement + "</p>";
	}

	return html;
}

// 用于排序的方法
var compare = function (prop) {
	return function (obj1, obj2) {
		var val1 = obj1[prop];
		var val2 = obj2[prop];
		if (!isNaN(Number(val1)) && !isNaN(Number(val2))) {
			val1 = Number(val1);
			val2 = Number(val2);
		}
		if (val1 < val2) {
			return 1;
		} else if (val1 > val2) {
			return -1;
		} else {
			return 0;
		}
	}
}

// 优化操作按钮执行的方法
function optimizationOperation(troubleInfoObj) {
	console.log("updateTroubleInfoObjList:"
		+ JSON.stringify(troubleInfoObjList));
	var tipMsg = getResource()[troubleInfoObj.optimizationPromptId];
	var optimizationId = troubleInfoObj.optimizationId;
	var optimizationInfoList = [];
	var optimizationAllId = "";
	if (optimizationId.indexOf("_ALL") > -1) {
		optimizationAllId = optimizationId.substring(0,
			optimizationId.length - 4);
	}
	var tmpId = getOptimizationIdSplitSUB(troubleInfoObj.newIds);
	var trId = getTroubleId(troubleInfoObj.newIds);
	for (i in troubleInfoObjList) {
		var obj = troubleInfoObjList[i];
		// 匹配一键优化项ID，增加trid的判断是由于如果一个优化ID对应多种情况，就会不知道优化的是哪个项
		hasDetails = obj.hasDetails;
		troubleId = obj.troubleId;
		troubleDescId = obj.troubleDescId;
		checkItemId = obj.checkItemId;
		troubleType = obj.troubleType;
		isSubTrouble = !obj.isGlobalTrouble;
		var optimizationParam = {};
		if (optimizationAllId != "") {
			if (optimizationAllId == obj.optimizationId
				|| optimizationId == obj.optimizationId) {
				// && (obj.troubleId == trId || trId == "")
				startOptimizationParam = {
					"checkItemId": checkItemId,
					"optimizationType": obj.isGlobalTrouble ? "GLOBAL" : "SUB",
					"troubleId": addPointIntoId(troubleId),
					"optimizationId": obj.isGlobalTrouble ? optimizationId
						: optimizationAllId,
					"isSupportOptimizationParam": obj.isSupportOptimizationParam ? "true"
						: "false",
					"hasDetails": obj.hasDetails,
					"optimizationParam": optimizationParam
				}
				// startOptimizationParam = {
				// "checkItemId" : checkItemId,
				// "optimizationType" : obj.isGlobalTrouble ? "GLOBAL" : "SUB",
				// "troubleId" : addPointIntoId(troubleId),
				// "optimizationId" : tmpOptimizationId,
				// "isSupportOptimizationParam" : obj.isSupportOptimizationParam
				// ? "true"
				// : "false",
				// "optimizationParam" : optimizationParam
				// }
				var newOptimizationId = getSubOptimizationId(optimizationAllId,
					troubleId);
				$("#" + newOptimizationId).css("display", "none");
				optimizationInfoList.push(startOptimizationParam);
			}
		} else {
			if (optimizationId == obj.optimizationId
				&& (obj.troubleId == trId || trId == "")) {
				startOptimizationParam = {
					"checkItemId": checkItemId,
					"optimizationType": obj.isGlobalTrouble ? "GLOBAL" : "SUB",
					"troubleId": addPointIntoId(troubleId),
					"optimizationId": optimizationId,
					"isSupportOptimizationParam": obj.isSupportOptimizationParam ? "true"
						: "false",
					"hasDetails": obj.hasDetails,
					// TODO 有优化参数，添加优化参数 上同
					"optimizationParam": optimizationParam
				}
				optimizationInfoList.push(startOptimizationParam);
				break;
			}
		}
	}
	if (tipMsg == "" || tipMsg == undefined) {
		// 没有提示信息则直接调优
		startOptimization(optimizationInfoList, troubleInfoObj.newIds);
	} else {
		// 有提示信息，默认告警提示
		optimizationDialog(tipMsg, optimizationInfoList, troubleInfoObj.newIds);
	}

}

// 拼接检测项的展示内容
function getErrorMessage(troubleParam, troubleDescId) {
	var errorMsg = "";
	// 有问题参数的，将问题参数拼接到问题详情描述中
	if (troubleParam && troubleParam.length > 0) {
		var objKey = Object.getOwnPropertyNames(troubleParam[0]);
		if (objKey && objKey.length > 0) {
			errorMsg = getTroubleContent(objKey, troubleParam, troubleDescId);
		} else {
			errorMsg = getResource()[troubleDescId];
		}
	} else {
		errorMsg = getResource()[troubleDescId];
	}
	return errorMsg;
}

/**
 * 获取异常检测项显示的内容
 * 
 * @param objKey
 * @param troubleParam
 * @param troubleDescId
 * @returns {*}
 */
function getTroubleContent(objKey, troubleParam, troubleDescId) {
	var errContent = getResource()[troubleDescId];
	if (!errContent) {
		errContent = troubleDescId;
	}

	for (i in objKey) {
		// 直接取数组第一位
		var contentValue = troubleParam[0][objKey[i]];

		if (contentValue != undefined) {
			if (contentValue == "" && !isNumber(contentValue)) {
				// 如果为空则替换成--
				errContent = errContent.replace('{' + objKey[i] + '}', "--");
				continue;
			}

			if (isNumber(contentValue)) {
				// 如果是数字则直接替换
				errContent = errContent.replace('{' + objKey[i] + '}',
					contentValue);
				continue;
			}

			if (contentValue.indexOf('&') > -1) {
				// 如果是包含&符号，则表示后面的参数需要先翻译再拼接
				var content = "";
				var values = contentValue.split('/');
				for (j in values) {
					if (values[j] == "" || values[j].replace('&', '') == "") {
						continue;
					}

					content += getResource()[values[j].replace('&', '')];
					// 中文和英文的顿号要加上
					if (j < values.length - 1) {
						content += " / ";
					}
				}

				errContent = errContent
					.replace('{&' + objKey[i] + '}', content);
			} else {
				// 直接当资源替换
				errContent = errContent.replace('{' + objKey[i] + '}',
					contentValue);
			}

		}
	}

	return errContent;
}

/**
 * 自动生成一个唯一的子项ID
 */
function getSubOptimizationId(optimizationId, _troubleId) {
	return optimizationId + SUB_EXTEND_TAG + _troubleId;
}

/**
 * 在优化ID后增加的troubleId要能够分享出来
 * 
 * @param optimizationId
 * @returns {*}
 */
function getOptimizationIdSplitSUB(optimizationId) {
	if (optimizationId) {
		var pos = optimizationId.indexOf(SUB_EXTEND_TAG);
		if (pos == -1) {
			return optimizationId;
		}

		return optimizationId.substring(0, pos);
	}

	return optimizationId;

}

/**
 * 提示用户可能是危险操作
 */
function optimizationDialog(msg, optimizationInfoList, newIds) {
	var html = getDialogHtml(msg);
	$(document.body).append(html);
	$(".bottom_right_button").click(function () {
		startOptimization(optimizationInfoList, newIds);
		// startOptimizationWithPara(data);
	});
}

// 提示弹窗
function getDialogHtml(msg) {
	var html = '<div id="mask"></div>';
	html += '<div id="win_warning" class="win_warning">'
		+ '<div class="top_image"><img src="../image/mark.png"/></div>'
		+ '<div class="middle_desc"><span>' + msg + '</span></div>'
		+ '<div class="bottom_button">'
		+ '<div class="bottom_left_button" onclick="closeWarningWin();">'
		+ '<span>' + getResource()["BUTTON_CANCEL"] + '</span>' + '</div>'
		+ '<div class="bottom_right_button">' + '<span>'
		+ getResource()["BUTTON_CONFIRM"] + '</span>' + '</div>' + '</div>'
		+ '</div>';
	return html;
}

// 取消弹窗
function closeWarningWin() {
	$(".subButton").css("display", "inline-block");
	$('#mask').remove();
	$('#win_warning').remove();
}

function z(optimizationId) {
	var tmpOptimizationId = getOptimizationIdSplitSUB(optimizationId);

	var trId = optimizationId.replace(tmpOptimizationId, '');

	if (trId) {
		return trId.replace(SUB_EXTEND_TAG, '');
	}

	return trId;
}

// 一键体检是否完成，未完成，继续循环查询结果；完成，则停止查询，展示结果
function checkItmesIsSuccess() {
	// 检测过程中停止检测了，停止检测
	if (switchFlag == "cancel") {
		$("#checkStatus").text(getResource()["CHECK_SUBITEM_AGAIN"]);
		if (queryInterval != null) {
			clearInterval(queryInterval);
		}
		return;
	}
	//	console.log("checkItmesIsSuccess:classFinishNum={},classifictionList:,classifictionList.length:"
	//					+ classFinishNum + ";" +classifictionList+";"+ classifictionList.length);
	for (var i in classifictionList) {
		var obj = classifictionList[i];
		if (obj == undefined || obj.checkItemList == undefined) {
			continue;
		}
		// 每个检测大类下有多少项需要优化
		// 检测大类检测完成，并且没有优化项，标记为正常;有优化项，显示需优化的检测项
		if (obj.isFinished || updateClassifictionState(obj)) {
			if (!obj.hasError && obj.needOptimizationCount <= 0
				&& obj.hasTrouble <= 0) {
				// 直接显示对应的结果
				setTimeout(addCheckNomarlCompleteView(obj.classifiction), 2000);
			} else {
				var imgPath = getClassificationImg(obj.classifiction, "warning");
				$("#" + obj.classifiction + " .img_bg").attr('src', imgPath);
			}
			classFinishNum++;
		}
	}
	if (classFinishNum == classifictionList.length) {
		// 全部体检已经完成
		// 1.取消定时器
		switchFlag = "cancel";
		$("#count").text(totalNeedDealWith);
		$("#unit").text(getResource()["ITEMS"]);

		$("#unit").css("font-size", "0.26rem");
		$("#content_state").text(getResource()["NEED_DEAL_WITH"]);
		$("#content_problem").css("display", "none");
		$("#content_result").css("display", "block");
		$("#content_state").css("display", "block");
		$("#content_state").css("font-size", "0.26rem");
		$(".globalTrouble").css("display", "flex");
		$(".subTrouble").css("display", "flex");
		$('.div').each(function (j) {
			$('.div').eq(j).css('color', '#ffffff');
		});
		// 2.检测完成之后，隐藏优化提示，显示需优化的内容
		for (var i in classifictionList) {
			var obj = classifictionList[i];
			if (obj == undefined || obj.checkItemList == undefined) {
				continue;
			}
			$('#' + obj.classifiction + "_prepare").css("display", "none");
		}
		$("#checkStatus").text(getResource()["CHECK_SUBITEM_AGAIN"]);
		// 3.清除定时器
		clearInterval(queryInterval);
		isNeedCancel = "false";
	}
}

/**
 * 拼接每个检测大类及总的需要优化的问题总数
 * 
 * @param optimizationCount
 */
function getDealWithContent(optimizationCount) {
	var contentValue = getResource()["NEED_OPTIMIZATION"];
	contentValue = contentValue.replace("{number}", optimizationCount);
	return contentValue;
}

/**
 * 标记是否正正常
 * 
 * @param
 */
function isNormal(classifiction) {
	var isCheckOver = updateClassifictionState(classifiction);
	if (isCheckOver) {
		var checkList = classifiction.checkItemList;
		for (var i in checkList) {
			if (checkList[i] === "false") {
				obj.isFinished = false;
				return false;
			}
		}
	}
}

/**
 * 标记是否正在检测 有检测项已经检测过，且检测大类还未检测完成，则标记为检测中
 * 
 * @param
 */
function nowIsChecking(classifiction) {
	var checkList = classifiction.checkItemList;
	for (var i in checkList) {
		if (checkList[i] === "true") {
			return true;
		}
	}
	return false;
}

/**
 * 标记是否检测完成
 * 
 * @param checkItemId
 */
function isClassifictionFinished(checkItemId) {
	var hasChecked = 0;
	for (var i in classifictionList) {
		var obj = classifictionList[i];
		if (obj == undefined || obj.checkItemList == undefined) {
			continue;
		}
		var itemList = obj.checkItemList;
		if (itemList[checkItemId] != undefined) {
			itemList[checkItemId] = "true";
		}
		for (var j in itemList) {
			if (itemList[j] == "true") {
				hasChecked++;
			}
		}
	}
	// 更新检测进度圆点样式
	controlCircle(hasChecked);
}

/**
 * 所有的项目调优完了，则显示“正常”
 */
function addCheckNomarlCompleteView(classifictionId) {
	if ($('#' + classifictionId).length > 0) {
		// 检测大类下，无对应的优化项，则该检测项显示正常
		var imgPath = getClassificationImg(classifictionId, "nomal");
		if ($("#itemsTable_" + classifictionId + "_li").length == 0) {
			$("#" + classifictionId + " .img_bg").attr('src', imgPath);
			var html = "<li id='itemsTable_" + classifictionId
				+ "_li'><img src='../image/completed.png' alt=''> <p>"
				+ getResource()["NOMARL_COMPLETED"] + "</p></li>";
			$('#itemsTable_' + classifictionId).append(html);
		}
	}
	// 隐藏检测状态
	$('#' + classifictionId + "_prepare").hide();
}

/**
 * 判断是否所有的检查项是否已完成
 * 
 * @param checkList
 * @returns {Boolean}
 */
function updateClassifictionState(obj) {
	var checkList = obj.checkItemList;
	for (var i in checkList) {
		if (checkList[i] === "false") {
			obj.isFinished = false;
			return false;
		}
	}
	obj.isFinished = true;
	return true;
}

/**
 * 获取检查大类的项
 * 
 * @param checkItemId
 * @returns {*}
 */
function getClassifiction(checkItemId) {
	for (var i in classifictionList) {
		if (classifictionList[i].checkItemList
			&& classifictionList[i].checkItemList[checkItemId]) {
			return classifictionList[i].classifiction;
		}
	}
	return "";
}

/**
 * 判断是否为数值，包括负数
 * 
 * @param input
 * @returns {boolean}
 */
function isNumber(input) {
	if (input == "0"
		|| (typeof input == 'number' && input.constructor == Number)) {
		return true;
	}

	return false;
}

/**
 * 动态计算按钮的宽度
 * 
 * @param id
 * @returns {number|jQuery}
 */
String.prototype.visualLength = function (id) {
	var ruler = $('#' + id);
	ruler.text(this);
	var len = $('#' + id).offsetWidth;
	try {
		len = ruler[0].offsetWidth
	} catch (e) {

	}
	return len;
}

/**
 * 查不到体检项时，给出错误提示
 */
function showErrorDes() {
	switchFlag = "cancel";
	$("#checkStatus").text(getResource()["CHECK_SUBITEM_AGAIN"]);
	$("#content_problem").css("font-size", "0.14rem");
	$("#content_problem").text(getResource()["NETWORK_ABNORMAL"]);
	return;
}

/**
 * 当平台正在执行体检的时候，提示稍后重试
 */
function showWaitErrorDes() {
	$("#content_problem").text(getResource()["NOW_CHECKING_WAITING"]);
	$("#checkStatus").text(getResource()["CHECK_SUBITEM_AGAIN"]);
	$("#content_problem").css("font-size", "0.14rem");
	switchFlag = "cancel";
	return;
}

/**
 * 取消体检任务	
 */
function cancelMyCheck() {
	switchFlag = "cancel";
	if (queryInterval != null) {
		clearInterval(queryInterval);
	}
	$("#checkStatus").text(getResource()["CHECK_SUBITEM_AGAIN"]);
	console.log("cancelMyCheck:isNeedCancel=" + isNeedCancel + ";switchFlag="
		+ switchFlag);
	if (isNeedCancel == "false") {
		$("#content_problem").text(getResource()["USER_CANCEL_CHECKING"]);
		$("#content_problem").css("font-size", "0.14rem");
		return;
	}
	var params = {
		"applicationName": "com.huawei.smarthome.homenetworkmanagement.NetworkManagementApplicationV2",
		"serviceName": "gatewayCheck",
		"action": "cancelCheck",
		"parameters": {
			"checkTaskId": currentCheckTaskId
		}
	}
	hwPluginService.doAction(params, function (data) {
		if (data.success) {
			var res = data.success;
			console.log("cancelCheckResult="
				+ JSON.stringify(res.cancelCheckResult));
			isNeedCancel == "false";
			switchFlag = "cancel";
			showCancelView(true, false);
		} else if (data.failed) {
			switchFlag = "check";
			$("#content_problem").text(getResource()["CHECK_CANCEL"]);
			$("#content_problem").css("font-size", "0.14rem");
		}

	});
}

/**
 * 刷新体检任务状态
 * 
 * @param isCancel
 *            是否为用户主动取消体检
 * @param isReqFailed
 *            是否为体检任务失败
 */
function showCancelView(isCancel, isReqFailed) {
	if (queryInterval != null) {
		clearInterval(queryInterval);
	}
	isNeedCancel == "false";
	switchFlag = "cancel";
	console.log("showCancelView:totalNeedDealWith " + totalNeedDealWith);
	if (isCancel) {
		$("#content_problem").text(getResource()["USER_CANCEL_CHECKING"]);
		$("#content_problem").css("font-size", "0.14rem");
		for (var i in classifictionList) {
			$("#" + classifictionList[i].classifiction + " _prepare").css(
				"display", "none");
		}

		$(".wifi_test_content .port_ul .out_li .inner_ul li .trouble").css(
			"display", "flex");

	} else if (isReqFailed) {
		// 如果是接口请求失败了，则直接刷成任务失败
		$("#content_problem").text(getResource()["CHECKING_MISSION_FAILED"]);
		$("#content_problem").css("font-size", "0.14rem");
		$("#checkStatus").text(getResource()["CHECK_SUBITEM_AGAIN"]);
	} else {
		$("#content_problem").text(getResource()["CHECKING_TIME_OUT"]);
		$("#content_problem").css("font-size", "0.14rem");
		$("#checkStatus").text(getResource()["CHECK_SUBITEM_AGAIN"])
	}
}

/**
 * 检测按钮点击事件
 */
function switchCheck() {
	if (switchFlag == "check") {
		cancelMyCheck();
	} else {
		startCheck();
	}
}

/**
 * 返回
 */
function goBack() {
	cancelMyCheck();
	hwPluginService.goBack(function (v) {
	});
}

//资源文件内资源
var resource;

// 停止测试时候，返回数据
var stopData = {
	"Id" : "id",
	"score" : "score",
	"data" : []
}

// 实时显示的数据变量
var rssi = null;
var linkedSpeed = null;
var delay = null;
var lost_rate = null;
var Switch = null;
var ping = null;
var wifi = null;

// 用于显示延时的数组
var timeDelay = [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ];

// 切换次数计数
var switchTimes = 0;
// 是否是苹果设备
var isIphone = false;
// WIFI频段
var radioType = "";
// WIFI名称
var wifiName = "--";
// 得分数组
var scores = [];
// 最终得分
var score = 0;

// 切换wifi时候，用于存储切换数据
var resultdata = null;

var language;

// 各评分因素得分点对应的数值
var separator = {
	"linkedSpeed_2_4G" : [ 150, 72, 30 ],
	"rssi" : [ -70, -80, -90 ],
	"delay" : [ 300, 100, 20 ],
	"lost_rate" : [ 10, 5, 0.01 ],
	"Switch" : [ 3000, 2000, 1000 ]
}

// 评分因素得分数值
var scoreArray = {
	"linkedSpeed_2_4G" : [ 100, 60, 30, 0 ],
	"rssi" : [ 100, 90, 20, 0 ],
	"delay" : [ 0, 30, 60, 80 ],
	"lost_rate" : [ 0, 30, 60, 100 ],
	"Switch" : [ 0, 50, 70, 80 ]
}

var scoringWeight = {
	"ios" : [ 0.1, 0.2, 0.3, 0.2, 0.2 ],
	"android" : [ 0.1, 0.2, 0.3, 0.2, 0.2 ]
}

/**
 * <div class="English"></div>
 * <div class="Chinese"></div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 * @descript 
 * @auther sujie
 * @date  2019年1月3日
 */
function load() {
	// 禁用长按弹出复制
	document.documentElement.style.webkitTouchCallout = "none";
	document.documentElement.style.webkitUserSelect = "none";
	loadData();
	if (sessionStorage.getItem('numId') == "1001") {
		displayDiv("distributed_point", "none");
	} else {
		displayDiv("distributed_point", "block");
	}
	isIphone = isApple();
	addListener();
	displayWifiName();
	
}

function loadData() {
	hwPluginService.getResource(function(data) {
		resource = data;
		console.log("loadData:getResource" + JSON.stringify(data));
		language = $.trim(resource.data["LANGUAGE"]);
		if(language == "en"){
			$("#hintImg").attr("src", "../images/hintImg_en.png");
			$(".distributed_point_description").css("height","1.9rem");
			$(".distributed_point_button").css("margin-top","0.3rem");
		}
		if(language == "zh"){
			$("#hintImg").attr("src", "../images/hintImg.png");
		}
		if(language == "zh_hant"){
			$("#hintImg").attr("src", "../images/hintImg_hant.png");
		}
		console.log("loadData:getResource" + JSON.stringify(data));
		initPage();
	});
}

/**
 * <div class="English"></div>
 * <div class="Chinese"></div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 * @descript 
 * @auther sujie
 * @date  2019年1月3日
 */
function getResource() {

	return resource.data;
}

/**
 * <div class="English"></div>
 * <div class="Chinese"></div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 * @descript 初始化页面，读取国际化翻译
 * @auther sujie
 * @date  2019年1月3日
 */
function initPage() {
	var spanArray = document.getElementsByTagName("span");
	for (var i = 0; i < spanArray.length; i++) {
		if (spanArray[i].getAttribute("local_key")) {
			var key = spanArray[i].getAttribute("local_key");
			if (getResource()[key] == undefined) {
				return;
			}
			spanArray[i].innerHTML = getResource()[key];
		}
	}
}

/**
 * <div class="English"></div>
 * <div class="Chinese"></div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 * @descript 隐藏提示信息
 * @auther sujie
 * @date  2019年1月3日
 */
function button_know() {
	displayDiv("distributed_point", "none");
}

/**
 * <div class="English"></div>
 * <div class="Chinese"></div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 * @descript 增加监听
 * @auther sujie
 * @date  2019年1月3日
 */
function addListener() {
	startTest();
	stopTest();
	reTest();
}

/**
 * <div class="English"></div>
 * <div class="Chinese"></div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 * @descript 开始测试
 * @auther sujie
 * @date  2019年1月3日
 */
function startTest() {
	document.getElementById("out").addEventListener("touchend", function() {
		displayDiv("banner", "none");
		displayDiv("average_delay_main", "block");
		displayWifiName();
		startRoomTest();
	})
}
/**
 * <div class="English"></div>
 * <div class="Chinese"></div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 * @auther sujie
 * @date  2019年1月3日
 */
function stopTest() {
	document.getElementById("stop_test").addEventListener("touchend",
			showStopPage);
}

/**
 * <div class="English"></div>
 * <div class="Chinese"></div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 * @auther sujie
 * @date  2019年1月3日
 */
function showStopPage() {
	displayDiv("average_delay_main", "none");
	displayDiv("banner", "block");
	displayDiv("content1", "none");
	displayDiv("content", "block");
	var now = new Date();
	stopData.Id = now.getTime().toString();
	if (scores.length == 0) {
		score = Math.floor(getScore());
	} else {
		score = average();
	}
	if (stopData.data.length == 0) {
		stopData.ssid = wifiName;
		stopData.data.push(resultdata);
	}
	stopData.score = score;
	$("#score").text(score);
	console.log("scores:" + JSON.stringify(scores));
	console.log("stopData:" + JSON.stringify(stopData));
	hwPluginService.stopRoamTest(stopData, function(result) {
		if (result.errorCode != "0") {
			showError();
		} else {
			console.log("successs");
		}
	});
}

/**
 * <div class="English"></div>
 * <div class="Chinese"></div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 * @descript 计算分数平均数 
 * @auther sujie
 * @date  2019年1月3日
 */
function average() {
	var sum = 0;
	var len = scores.length;
	for (var i = 0; i < len; i++) {
		sum += scores[i];
	}
	return Math.floor(sum / len);
}

/**
 * <div class="English"></div>
 * <div class="Chinese"></div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 * @descript 计算分数 
 * @auther sujie
 * @date  2019年1月3日
 */
function getScore() {
	var score = 0;
	// 进入页面无网络情况，给出评分为0，测试过程中断网了，给出评分是断网时刻的评分
	if (resultdata == null) {
		return score;
	}
	var weight = 0.2;
	var scoreType = [ "linkedSpeed", "rssi", "delay", "lost_rate", "Switch" ];
	for ( var i in scoreType) {
		// 按实际值与的分标准的比例计算分值，假设得分标准界限是x、y,实际值是z,得分界限是a、b，实际得分c
		// 满足 (z-x)/(y-x)==(c-a)/(b-a) 得到：c=a+(z-x)*(b-a)/(y-x)
		// 计算分数时候，某个得分项与的分标准做对比的对象，相当于z
		var z = null;
		// 得分标准分界线，相当于x y
		var xy = [];
		// 得分分界线，相当于a b
		var ab = [];
		if (isIphone) {
			weight = scoringWeight.ios[i];
		} else {
			weight = scoringWeight.android[i];
		}
		if (i == 0) {
			scoreType[i] = "linkedSpeed_2_4G";
		}
		if (i == 1) {
			if (isIphone) {
				if (rssi == getResource()["GOOD"]) {
					score += 100 * weight;
				} else if (rssi == getResource()["NORMAL"]) {
					score += 70 * weight;
				} else {
					score += 20 * weight;
				}
				continue;
			}
		}
		if (i == 4) {
			if (Switch == null) {
				score += 100 * weight;
				return score;
			} else if (Switch.useTime >= 0 && Switch.useTime < 100) {
				score += 90 * weight;
				return score;
			} else if (Switch.useTime >= 100 && Switch.useTime < 500) {
				score += 80 * weight;
				return score;
			}
		}
		xy = separator[scoreType[i]];
		ab = scoreArray[scoreType[i]];
		switch (i) {
		case "0":
			z = linkedSpeed;
			break;
		case "1":
			z = rssi;
			break;
		case "2":
			z = delay;
			break;
		case "3":
			z = lost_rate;
			break;
		case "4":
			z = Switch.useTime;
			break;
		}

		if (z == null || z == "--"||( i==2 && z == -1)) {
			score += 0;
			continue;
		}
		console.log("z:" + z + ";score:" + score);
		if (z >= xy[0]) {
			if (i == 0 && z > 150) {
				score += 10 ;
				continue;
			} else if (i == 1 && z > -67) {
				score = score + 18 + (67 + z) * 2 / 67;
				continue;
			}
			score += ab[0] * weight;
		} else if (z < xy[0] && z >= xy[1]) {
			// 实际得分c=a+(z-x)*(b-a)/(y-x)
			score += (Math.abs((z - xy[1]) * (ab[1] - ab[0]) / (xy[0] - xy[1])) + ab[1])
					* weight;
		} else if (z < xy[1] && z >= xy[2]) {
			score += (Math.abs((z - xy[2]) * (ab[2] - ab[1]) / (xy[1] - xy[2])) + ab[2])
					* weight;
		} else {
			if (i == 2) {
				score = score + 24 + (20 - z) * 6 / 20;
				continue;
			} else {
				score += ab[3] * weight;
			}
		}
	}
	return score;
}

/**
 * <div class="English"></div>
 * <div class="Chinese"></div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 * @descript 显示WIFI名称及频段，ios不显示频段 
 * @auther sujie
 * @date  2019年1月3日
 */
function displayWifiName() {
	hwPluginService.getConnectWiFi(function(result) {
		console.log(JSON.stringify(result));
		if (result != null && result.errorCode === "0") {
			wifiName = result.data.SSID;
			radioType = result.data.RadioType;
			var ssidAndType = ""
			if (wifiName === null || wifiName === "(null)") {
				ssidAndType="--"
			}else{
				if (isIphone) {
					ssidAndType = wifiName;
				} else {
					ssidAndType = wifiName;
				}
			}

			$("#topTips_wifiName").text(ssidAndType);
		} else {
			showError();
		}
	});
}

/**
 * <div class="English"></div>
 * <div class="Chinese"></div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 * @descript 报错提示，未设计
 * @auther sujie
 * @date  2019年1月3日
 */
function showError() {

}

/**
 * <div class="English"></div>
 * <div class="Chinese"></div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 * @descript 重新检测
 * @auther sujie
 * @date  2019年1月3日
 */
function reTest() {
	document.getElementById("content").addEventListener("touchend", function() {
		displayDiv("content", "none");
		displayDiv("average_delay_main", "block");
		initData();
		displayWifiName();
		startRoomTest();
	})
}

/**
 * <div class="English"></div>
 * <div class="Chinese"></div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 * @descript 重新检测时候，初始化数据
 * @auther sujie
 * @date  2019年1月3日
 */
function initData() {
	// 停止测试时候，返回数据
	stopData = {
		"Id" : "id",
		"score" : "score",
		"data" : []
	}

	// 实时显示的数据变量
	rssi = null;
	linkedSpeed = null;
	delay = null;
	lost_rate = null;
	Switch = null;
	ping = null;
	wifi = null;
	// 用于显示延时的对象
	timeDelay = [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ];
	switchTimes = 0;
	scores = [];
	score = 0;
	$("#scroller").empty();
}

function displayDiv(_obj, _display) {
	try {
		document.getElementById(_obj).style.display = _display;
	} catch (e) {
		console.error(e);
	}
}

/**
 * <div class="English"></div>
 * <div class="Chinese"></div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 * @descript 返回
 * @auther sujie
 * @date  2019年1月3日
 */
function goBack() {
	hwPluginService.goBack(function() {
	});
}

/**
 * <div class="English"></div>
 * <div class="Chinese"></div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 * @descript 开始调用接口
 * @auther sujie
 * @date  2019年1月3日
 */
function startRoomTest() {
	hwPluginService.startRoamTest(function(result) {
		// {"errorCode":"100104","errorMessage":"WiFi断连，请重新连接WiFi再测试"}
		console.log("startRoomTest:" + JSON.stringify(result));
//		console.log("当前时间:" + JSON.stringify(new Date().getTime()));
		if (result.errorCode == "0") {
			ping = result.data.Ping;
			wifi = result.data.Wifi;
			if (wifi != null) {
				if (isIphone) {
					switch (wifi.RSSI) {
					case "1":
						rssi = getResource()["POOR"];
						break;
					case "2":
						rssi = getResource()["NORMAL"];
						break;
					case "3":
						rssi = getResource()["GOOD"];
						break;
					default:
						rssi = "--";
					}
					linkedSpeed = wifi.linkedSpeed;
				} else {
					rssi = wifi.RSSI;
				}
				if (wifi.linkedSpeed != "-1") {
					linkedSpeed = wifi.linkedSpeed;
				} else {
					linkedSpeed = "--";
				}
			} else {
				rssi = "--";
				linkedSpeed = "--";
			}
			if (ping != null) {
				lost_rate = Math.floor(ping.lost);
				delay = Math.floor(ping.delay);
				if (ping.delay != -1) {
					timeDelay.shift();
					timeDelay.push(delay);
				}else if(ping.delay == -1){
					delay = "--";
				}
				console.log("timeDelay:" + timeDelay);
			} else {
				delay = "--";
				lost_rate = "--";
			}
			resultdata = result.data;
			if (result.data.Switch != undefined) {
				Switch = result.data.Switch;
				stopData.ssid = wifiName;
				stopData.data.push(result.data);
				switchTimes++;
				displayWifiName();
				getSwitchContent();
				score = getScore();
				scores.push(score);
				console.log("startRoomTest->stopData:"
						+ JSON.stringify(stopData));
				console.log("startRoomTest->scores:" + scores);
			}

			$("#average_speed").text(linkedSpeed);
			$("#average_delay").text(delay);
			$("#signal_intensity").text(rssi);
			$("#packet_loss_rate").text(lost_rate);
			if (delay != "-1" && delay != "--") {
				showDelays();
			}else{
				delay = 0
				showDelays();
			}
		} else if (result.errorCode == "100104") {
			showResult();
		}
		console.log(JSON.stringify(result));
	});
}

/**
 * <div class="English"></div>
 * <div class="Chinese"></div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 * @descript 
 * @auther sujie
 * @date  2019年1月3日
 */
function showResult() {
	$(".deleteConfirm").show();
	$(".shade").show();
}

/**
 * <div class="English"></div>
 * <div class="Chinese"></div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 * @descript 
 * @auther sujie
 * @date  2019年1月3日
 */
function confirm() {
	$(".deleteConfirm").hide();
	$(".shade").hide();
	displayWifiName();
	if (resultdata == null) {
	displayDiv("average_delay_main", "none");
	displayDiv("content1", "block");
	displayDiv("content", "none");
	displayDiv("banner", "block");
	} else {
		showStopPage();
	}
}

/**
 * <div class="English"></div>
 * <div class="Chinese"></div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 * @descript 拼接切换html
 * @auther sujie
 * @date  2019年1月3日
 */
function getSwitchContent() {
	/*
	 * "Switch": { "Index": "切换点索引", "Time": "切换时间", "SrcMac": "切换前MAC地址",
	 * "DestMac": "切换后MAC地址", "UseTime": "切换时长", "Lost": "切换时丢包个数" }
	 */
	var srcMac = (Switch.srcMac != null) ? Switch.srcMac : "--";
	var srcName = (Switch.srcName != null) ? Switch.srcName : "--";
	var destMac = (Switch.destMac != null) ? Switch.destMac : "--";
	var destName = (Switch.destName != null) ? Switch.destName : "--";
	var src = srcName + "(" + srcMac + ")";
	var dest = destName + "(" + destMac + ")";
	var switchTime = format(Switch.time, "yyyy-MM-dd HH:mm:ss");
	var dataDetails = (language == "zh") ? "test_details_data_cn"
			: "test_details_data_en";
	var detailsTop = (language == "zh") ? "test_data_details_cn"
			: "test_data_details_en";

	var contentHtml = "<div class='test_details_data  "
			+ dataDetails
			+ "'>"
			+ "<div  class='test_details_circle'>"
			+ "<div class='circle'>"
			+ switchTimes
			+ "</div>"
			+ "</div>"
			+ "<div class='ap_title_left'><div class='test_data_title'>"
			+ "<span class='test_details_style'>"
			+ getContent(getResource()["SWITCH_TIME"], switchTimes)
			+ "</span>"
			+ "<span class='test_details_style2'>"
			+ Math.floor(Switch.useTime)
			+ "ms</span>"
			+ "<span>"
			+ getResource()["LOST_PACKAGE"]
			+ "</span>"
			+ "<span class='test_details_style2'>"
			+ Switch.lost
			+ "</span>"
			+ "<span class='test_details_style2'>"
			+ getResource()["AN"]
			+ "</span>"
			+ "</div>"
			+ "<div class='test_data_details  "
			+ detailsTop
			+ "'>"
			+ "<span>"
			+ fromGatewayTo(getResource()["FROM_GATEWAY_TO"], switchTime, src,
					dest) + "</span>" + "</div></div></div>";
	$("#scroller").append(contentHtml);
}

/**
 * <div class="English"></div>
 * <div class="Chinese"></div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 * @descript 获取替换后的切换次数的国际化资源
 * @auther sujie
 * @date  2019年1月3日
 */ 
function getContent(message, number) {
	return message.replace("{NUMBER}", number);
}

function fromGatewayTo(message, switchTime, src, dest) {
	var newMessage = message.replace("{TIMESTAMP}", switchTime);
	newMessage = newMessage.replace("{BSSID1}", src);
	newMessage = newMessage.replace("{BSSID2}", dest);
	return newMessage;
}

/**
 * <div class="English"></div>
 * <div class="Chinese"></div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 * @descript 跳转到历史记录
 * @auther sujie
 * @date  2019年1月3日
 */
function historyRecord() {
	var openUrl = "distributedTest/html/history_notes.html";
	hwPluginService.openUrl({
		url : openUrl
	}, function(v) {
	});
}

/**
 * <div class="English"></div>
 * <div class="Chinese"></div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 * @descript 日期格式化
 * @auther sujie
 * @date  2019年1月3日
 */
function format(switchTime, format) {
	var t = new Date(Number(switchTime));
	var tf = function(i) {
		return (i < 10 ? '0' : '') + i
	};
	return format.replace(/yyyy|MM|dd|HH|mm|ss/g, function(a) {
		switch (a) {
		case 'yyyy':
			return tf(t.getFullYear());
			break;
		case 'MM':
			return tf(t.getMonth() + 1);
			break;
		case 'mm':
			return tf(t.getMinutes());
			break;
		case 'dd':
			return tf(t.getDate());
			break;
		case 'HH':
			return tf(t.getHours());
			break;
		case 'ss':
			return tf(t.getSeconds());
			break;
		}
	})
}

/**
 * <div class="English"></div>
 * <div class="Chinese"></div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 * @descript 画坐标轴及时延曲线
 * @auther sujie
 * @date  2019年1月3日
 */
function showDelays() {
	var myChart = echarts.init(document.getElementById('main'));
	option = {
		grid : {
			top : '10',
			bottom : '10',
			left : '32',
			right : '32'
		},
		xAxis : [ {
			type : 'category',
			boundaryGap : true,
			data : timesDate(),
			axisLabel : {
				show : false,
				formatter : function(value) {
					return value.split("").join("\n");
				}
			},
			axisTick : { // y轴刻度线
				show : false,
			},
			axisLine : {
				onZero : true, // 垂直方向的0值不在坐标上
				lineStyle : {
					color : '#4593E2'
				}
			},
			splitLine : {
				show : true,
				lineStyle : {
					color : '#4593E2'
				}
			}
		}

		],
		yAxis : [ {
			position : 'left',
			type : 'value',
			scale : true,
			boundaryGap : [ 0.2, 0.2 ],
			axisTick : { // y轴刻度线
				show : false
			},
			axisLine : {
				show : true,
				lineStyle : {
					color : '#4593E2'
				}
			},
			axisLabel : {
				show : false
			},
			splitLine : {
				show : true,
				lineStyle : {
					color : '#4593E2'
				}
			},
		}, {
			position : 'right',
			axisTick : { // y轴刻度线
				show : false
			},
			axisLine : {
				lineStyle : {
					color : '#4593E2'
				},
			},
			splitLine : {
				show : true,
				lineStyle : {
					color : '#4593E2'
				}
			}
		} ],
		series : [ {
			type : 'line',
			smooth : true,
			symbolSize : 5,
			symbol : 'emptyCircle',
			silent : true,
			showSymbol : false,
			showAllSymbol : true,
			itemStyle : {
				normal : {
					lineStyle : {
						width : 2
					},
					color : new echarts.graphic.LinearGradient(0, 0, 0, 1, [ {
						offset : 0,
						color : '#4593E2'
					} ]),
					opacity : 1
				}
			},
			areaStyle : {
				normal : {
					color : new echarts.graphic.LinearGradient(0, 0, 0, 1, [ {
						offset : 0,
						color : 'rgba(59, 250, 205, 0.5)'
					}, {
						offset : 0.8,
						color : 'rgba(59, 250, 205, 0)'
					} ], false),
					shadowColor : 'rgba(0, 0, 0, 0.1)',
					shadowBlur : 10
				}
			},
			markPoint : {
				symbolSize : 10,
				symbol : 'emptyCircle',
				label : {
					normal : {
						formatter : '{c|{c}}{f|ms}',
						position : 'top',
						right : '20',
						rich : {
							c : {
								align : 'left',
								verticalAlign : 'bottom',
								fontSize : '30',
								color : '#3bfacd',
								fontFamily : 'TitilliumWeb-Regular'
							},
							f : {
								align : 'left',
								verticalAlign : 'bottom',
								fontSize : '12',
								color : '#3bfacd',
								fontFamily : 'TitilliumWeb-Light'
							}
						}
					}
				},
				data : [ {
					value : delay,
					coord : [ 9, 10 ]
				} ],
			},
			markLine : {
				symbol : [ 'none', 'none' ],
				lineStyle : {
					width : 0
				},
				label : {
					normal : {
						show : false,
					}
				},
				data : [ {
					yAxis : 0,
					name : '实时'
				} ]
			},
			data : timeDelay
		} ]
	};

	myChart.setOption(option);
	option.series[0].markPoint.data[0].coord[1] = delay;
	option.series[0].markLine.data[0].yAxis = delay;
	myChart.setOption(option);

}

/**
 * <div class="English"></div>
 * <div class="Chinese"></div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 * @descript x轴曲线时间
 * @auther sujie
 * @date  2019年1月3日
 */
function timesDate() { 
	var now = new Date();
	var res = [];
	var len = 10;
	while (len--) {
		res.unshift(now.toLocaleTimeString().replace(/^\D*/, ''));
		now = new Date(now - 2000);
	}
	return res;
}

/**
 * <div class="English"></div>
 * <div class="Chinese"></div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 * @descript 判断是否为iphone
 * @auther sujie
 * @date  2019年1月3日
 */
function isApple() {
	var isApple = false;
	var sUserAgent = navigator.userAgent.toLowerCase();
	if (sUserAgent.indexOf('iphone') > -1) {
		isApple = true;
	} else if (sUserAgent.indexOf('ipad') > -1) {
		isApple = true;
	} else {
		isApple = false;
	}
	return isApple;
}

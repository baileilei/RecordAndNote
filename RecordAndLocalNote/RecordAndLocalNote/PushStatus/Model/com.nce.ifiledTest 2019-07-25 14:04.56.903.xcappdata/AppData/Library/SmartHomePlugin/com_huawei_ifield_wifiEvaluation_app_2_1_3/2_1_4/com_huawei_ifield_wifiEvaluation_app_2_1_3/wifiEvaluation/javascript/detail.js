//国际化资源(JSON)
var resource = null;

// 历史记录的时间点
var testId;

// 当前页面要显示的记录
var currentRecord;

var evaluationList;
var isIphone=false;
function load() {
	isIphone = isApple()
	testId = getUrlParams(location.href).testId;
	hwPluginService.getResource(function(data) {
		var errorCode = data.errorCode;
		if (errorCode == 0) {
			resource = data.data;
			initPage();
			queryData();
		}
	});

}
/**
 * <div class="English"></div>
 * <div class="Chinese">判断是否为ios设备</div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
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


function getUrlParams(url) {
	var params = {};
	url.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(str, key, value) {
		params[key] = value;
	});
	return params;
}

/**
 * <div class="English"></div>
 * <div class="Chinese">查询历史记录详情</div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 */
function queryData() {
	hwPluginService.getAllResultList(function(r) {
		//debug("getAllResultList = " + JSON.stringify(r));
		var errorCode = r.errorCode;
		if (errorCode == "0") {
			recordList = r.data;
			if (recordList != null && recordList.length > 0) {
				for (var i = 0; i < recordList.length; i++) {
					var record = recordList[i];
					if (record.testId == testId) {
						currentRecord = record;
						drawDetail(currentRecord);
						break;
					}
				}
			}
		} else {
			// 页面上显示还没有历史记录
			var errorMessage = r.errorMessage;
		}
	});

}

function drawDetail(currentRecord) {
	var testTime = new Date(currentRecord.testTime).toLocaleString();
	var wiFiName = currentRecord.wiFiName;
	var score = currentRecord.score;
	$("#wiFiName").html(wiFiName);
	$("#testTime").html(testTime);
	$("#score").html(score);
    if(score>=80){
        $('.changColor em,.changColor i span').css('color','#4eaff5')
    }else if(score>=60){
        $('.changColor em,.changColor i span').css('color','#ff980c')
    }else {
        $('.changColor em,.changColor i span').css('color','#e54545')
    }
    
    evaluationList = currentRecord.roomResult;
    //如果有户型图，则显示户型图以及在图上标注测试点
    if(currentRecord.testMode == "roomPig"){
    	$(".house_type_img ").show();
    	$("#photo").attr("src", currentRecord.url);
    }
    
	var detailsDiv = $("#details_content");
	var _html = "";
	// 展示数据
	for (var j = 0; j < evaluationList.length; j++) {
		var evaluation = evaluationList[j];
		var pointImg = '';
		var showColor = ''
		if(evaluation.testResult.score>=80){
			pointImg = '../image/pointBlue.png';
            showColor = 'blueColor'
		}else if(evaluation.testResult.score>=60){
			pointImg = '../image/pointYellow.png';
            showColor = 'yellowColor'
		}else{
			pointImg = '../image/pointRed.png';
            showColor = 'redColor'
		}
		
		//如果有户型图，则显示户型图以及在图上标注测试点
	    if(currentRecord.testMode == "roomPig"){
	    	var pointHtml = "";
	    	pointHtml += "<button>"
	            + evaluation.room.roomName + "</button><img src='"+pointImg+"'><span class='"+ showColor +"'>"
	            +evaluation.testResult.score+"</span>";
	        var point = $(
	            "<div>",
	            {
	                "class": "btn",
	                "css": {
	                    left: evaluation.roomPig.x + 'px',
	                    top: evaluation.roomPig.y + 'px',
	                },
	                "html": pointHtml
	            }).appendTo($("#house"));
	    }
		
		_html += "<li><p class='title'><span style='white-space:pre;'>"
				+ evaluation.room.roomName
				+ "</span><span class='"+showColor+"'><em>"
                + getResource()["ROOM_SCORE"]
			    + "</em><i>"
				+ evaluation.testResult.score
				+ `</i></span></p><ul><li><div><img src='../image/upanddown.png'/><span>`
				+ getResource()["CONNECTION_RATE"] + "</span></div><div>"
				+ evaluation.testResult.wiFi.linkedSpeed
				+ "Mbps</div></li><li><div>"
				+	`<img src='${isIphone ?'../image/ioswifi.png':'../image/androidwifi.png'}'/><span>`
				+ getResource()["SIGNAL_STRENGTH"] + "</span></div><div>"
				+ evaluation.testResult.wiFi.signalStrength
				+ `${isIphone ? '':'dBm'}`
				+ `</div></li><li><div><img src="${ evaluation.testResult.ping.networkDelay >=100 ? "../image/yanshi_bad.png":"../image/yanshi_good.png"}" /><span>`
				+ getResource()["TIME_DELAY"] + "</span></div><div>"
				+ evaluation.testResult.ping.networkDelay + "ms</div></li></ul></li>"
	}

	detailsDiv.html(_html);
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

/**
 * <div class="English"></div>
 * <div class="Chinese">将毫秒数转换成固定的时间格式</div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 */

Date.prototype.toLocaleString = function() {
    function addZero(num){
        if(num<10)
            return "0" + num;
        return num;
   }
   return this.getFullYear() + "/" + addZero(this.getMonth() + 1) + "/" + addZero(this.getDate())+" "+
       + addZero(this.getHours()) + ":" + addZero(this.getMinutes()) + ":" + addZero(this.getSeconds());
};

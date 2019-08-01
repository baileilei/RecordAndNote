//国际化资源(JSON)
var resource = null;

// 历史记录的数据
var testId;
var isIphone=false;
var hisoryList=null;
var isEn="no";
/**
 * <div class="English"></div>
 * <div class="Chinese"></div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 * @descript 加载页面
 * @auther Administrator
 * @date  2019年1月3日
 */
function load() {
	isIphone = isApple();
	var html="<div class='test_details_data'>";
	testId=getUrlParams(location.href).testId;
	hwPluginService.getResource(function(result) {
		var errorCode = result.errorCode;
		if (errorCode == 0) {
			resource = result.data;
			isEn=resource["IS_EN_US"];
			initPage();
		}
	});
	hwPluginService.getRoamTestResultList(function (result){
		if (result.errorCode !="0") {
			showError();
			return;
		}
			hisoryList = result.data;
			console.log("hisoryList:"+JSON.stringify(hisoryList));
			var ssid="";
			var time="";
			var score=0;
			for(var x in hisoryList){
				if (hisoryList[x].Id == testId) {
					ssid=hisoryList[x].ssid;
					score=hisoryList[x].score;
					time=new Date(Number(hisoryList[x].Id)).toLocaleString();
					for ( var item in hisoryList[x].data) {
						if (hisoryList[x].data[item]==null) {
								continue;	
						}
						var Switch=hisoryList[x].data[item].Switch;
						if (Switch != null ) {
							html+=getSwitchContent(Number(item)+1,Switch);
						}else {
							html+=getTips();
						}
					}
				}
				}
			html+="</div>";
			console.log(html);
			$("#ssid").text(ssid);
			$("#detailScore").text(score);
			$("#time").text(time);
			$(".item").after(html);
			});
	}

/**
 * 判断是否为iphone
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

/**
 * <div class="English"></div>
 * <div class="Chinese"></div>
 * @param <div class="English">url</div><div class="Chinese">url</div>
 * @return <div class="English">params</div><div class="Chinese">params</div>
 * @descript 截取url里的参数值
 * @auther Administrator
 * @date  2019年1月3日
 */
function getUrlParams(url) {
	var params = {};
	url.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(str, key, value) {
		params[key] = value;
	});
	return params;
}
/**
 * <div class="English"></div>
 * <div class="Chinese"></div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 * @descript 拼接html
 * @auther Administrator
 * @date  2019年1月3日
 */
function getSwitchContent(switchTimes,Switch){
	var srcMac=(Switch.srcMac!=null) ? Switch.srcMac : "--";
	var srcName=(Switch.srcName!=null) ? Switch.srcName : "--";
	var destMac=(Switch.destMac!=null) ? Switch.destMac : "--";
	var destName=(Switch.destName!=null) ? Switch.destName : "--";
	var src=srcName+"("+srcMac+")";
	var dest=destName+"("+destMac+")";
	var switchTime=format(Switch.time,"yyyy-MM-dd HH:mm:ss");
	//前人写的样式里全是绝对定位，改成自适应比较麻烦，写中英两套样式也没必要，只在关键地方修改样式
	var dataTitle= (isEn=="no") ? "test_data_title_cn" : "test_data_title_en";
	var testCircle= (isEn=="no") ? "test_details_circle_cn" : "test_details_circle_en";
	var dataItem= (isEn=="no") ? "test_details_item_cn" : "test_details_item_en";
	var contentHtml="<div class='test_details_item "+ dataItem+"'>"
		+"<div  class='test_details_circle "+ testCircle +"'>"
		+"<div class='circle'>"+ switchTimes +"</div>"
	+"</div>"
	+"<div><div class='test_data_title "+ dataTitle +"'>"
	+"<span class='test_details_style'>" + (getResource()["SWITCH_TIME"]).replace("{NUMBER}",switchTimes) +"</span>"
	+"<span class='test_details_style2'>" +Math.floor(Switch.useTime) + "ms</span>"
	+"<span>" + getResource()["LOST_PACKAGE"] + "</span>"
	+"<span class='test_details_style2'>"+Switch.lost+"</span>"
	+"<span class='test_details_style2'>"	+getResource()["AN"]+"</span>"
	+"</div>"
	+"<div class='test_data_details'>"
	+"<span>" + fromGatewayTo(getResource()["FROM_GATEWAY_TO"],switchTime ,src, dest)+ "</span>"
	+"</div></div></div>";
	return contentHtml;
}

/**
 * <div class="English"></div>
 * <div class="Chinese"></div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 * @descript 
 * @auther Administrator
 * @date  2019年1月7日
 */
function getTips() {
	var htmlContent="<div class='no_toggole_tips'>"
		+ getResource()["NO_TOGGOLE"]+"</div>"
	return  htmlContent;
}

function fromGatewayTo( message, switchTime ,src, dest){
	var newMessage=message.replace("{TIMESTAMP}",switchTime);
	newMessage=newMessage.replace("{BSSID1}",src);
	newMessage=newMessage.replace("{BSSID2}",dest);
	return newMessage;
}

function getResource() {
	return resource;
}
/**
 * <div class="English"></div>
 * <div class="Chinese"></div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 * @descript 初始化页面上的资源文件内容
 * @auther Administrator
 * @date  2019年1月3日
 */
function initPage() {
	var spanArray = document.getElementsByTagName("span");
	for (var i = 0; i < spanArray.length; i++) {
		if (spanArray[i].getAttribute("local_key")) {
			var key = spanArray[i].getAttribute("local_key")
			spanArray[i].innerHTML = getResource()[key];
		}
	}
}
/**
 * <div class="English"></div>
 * <div class="Chinese"></div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 * @descript 返回
 * @auther Administrator
 * @date  2019年1月3日
 */
function goBack(){
	hwPluginService.goBack(function(){});
}

//将毫秒数转换成固定的时间格式
Date.prototype.toLocaleString = function() {
    function addZero(num){
        if(num<10)
            return "0" + num;
        return num;
   }
   return this.getFullYear() + "/" + addZero(this.getMonth() + 1) + "/" + addZero(this.getDate())+" "+
       + addZero(this.getHours()) + ":" + addZero(this.getMinutes()) + ":" + addZero(this.getSeconds());
};

/**
 * <div class="English"></div>
 * <div class="Chinese"></div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 * @descript 格式化时间
 * @auther Administrator
 * @date  2019年1月3日
 */
function format(switchTime, format){
	var t = new Date(Number(switchTime));
    var tf = function(i){return (i < 10 ? '0' : '') + i};
    return format.replace(/yyyy|MM|dd|HH|mm|ss/g, function(a){
        switch(a){
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
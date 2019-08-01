var resource;
var hisoryList=null;
var isIphone=false;
var number=0;

/**
 * <div class="English"></div>
 * <div class="Chinese"></div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 * @descript 加载页面数据
 * @auther Administrator
 * @date  2019年1月3日
 */function load() {
    // 禁用长按弹出复制
    document.documentElement.style.webkitTouchCallout = "none";
    document.documentElement.style.webkitUserSelect = "none";
    isIphone=isApple();
    setCookie();
    loadData();
}

function loadData() {
	hwPluginService.getResource(function (data){
		resource = data;
//		console.log("resource:"+JSON.stringify(resource));
		initPage();
		initHistoryData();
		});
}

/**
 * <div class="English"></div>
 * <div class="Chinese"></div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 * @descript 返回资源文件内容
 * @auther Administrator
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
 * @auther Administrator
 * @date  2019年1月3日
 */
function initPage() {
    var spanArray = document.getElementsByTagName("span");
    for(var i = 0; i < spanArray.length; i++) {
        if(spanArray[i].getAttribute("local_key")) {
            var key = spanArray[i].getAttribute("local_key");
            if(getResource()[key] == undefined) {
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
 * @descript 初始化页面
 * @auther Administrator
 * @date  2019年1月3日
 */
function  initHistoryData() {
	hwPluginService.getRoamTestResultList(function (result){
		if (result.errorCode !="0") {
			showError();
			return;
		}
			hisoryList = result.data;
			hisoryList=hisoryList.sort(compare("Id"));
			var htmlList="";
			console.log("result:"+JSON.stringify(result));
			console.log("hisoryList:"+JSON.stringify(hisoryList));
			for(var x in hisoryList){
				console.log(JSON.stringify(hisoryList[x]));
				var record=hisoryList[x].data;
				if (record.length==0) {
					continue;
				}
				if (hisoryList[x].ssid=="--") {
					continue;
				}
				var count=0;
				for(var i in record){
					if (record[i]==null) {
						continue;
					}
					var Switch=record[i].Switch;
					if (Switch!=null) {
						count++;
					}
				}
				console.log(JSON.stringify(record));
				htmlList += `<li class="li_record" id="${hisoryList[x].Id}">
			    <div>
			        <p>
			            <span>${hisoryList[x].ssid}</span>
			            <span class=""><i>${getResource()["SCORES"]}</i><em>${hisoryList[x].score}</em></span>
			        </p>
			        <p>
			            <span>${format(hisoryList[x].Id, "yyyy-MM-dd HH:mm:ss")}</span>
			            <span> ${(getResource()["SWITCH_TIMES"]).replace("{NUMBER}",count)}</span>
			        </p>
			    </div>
			    <button class="deleteBtn" id="del_${hisoryList[x].Id}">${getResource()["DELETE"]}</button>
			</li>`
					}
			 $("#ul_list").html(htmlList);
			 $(".deleteBtn").on('click', function(e){
			    	var delId = this.id.split("_")[1];
			    	$("#deleteRec").text(getResource()["DO_YOU_CONFIRM_DELETE"]);
			    	$(".deleteConfirm").show();
			        $(".shade").show();
			        $("#deleteRecordId").html(delId);
			    });
			    var initX; //触摸位置
			    var moveX; //滑动时的位置
			    var X = 0; //移动距离
			    var objX = 0; //目标对象位置
			    var flag = true;
			    $('.li_record').on('touchstart', function (e) {
			        flag = true;
			        initX = event.targetTouches[0].pageX;
			        objX = ($(this)[0].style.WebkitTransform.replace(/translateX\(/g, "").replace(/px\)/g, "")) * 1;
			    })
			    if (objX == 0) {
			        $('.li_record').on('touchmove', function (e) {
			            //  event.preventDefault();
			            flag = false;
			            moveX = event.targetTouches[0].pageX;
			            X = moveX - initX;
			            if (X >= 0) {
			                $(this)[0].style.WebkitTransform = "translateX(" + 0 + "px)";
			            } else if (X < 0) {
			                var l = Math.abs(X);
			                $(this)[0].style.WebkitTransform = "translateX(" + -l + "px)";
			                if (l > 100) {
			                    l = 100;
			                    $(this)[0].style.WebkitTransform = "translateX(" + -l + "px)";
			                }
			            }

			        });
			    }else if (objX < 0) {
			        $('.li_record').on('touchmove', function(e) {
			            // event.preventDefault();
			            flag = false;
			            moveX = e.targetTouches[0].pageX;
			            X = moveX - initX;
			            if (X >= 0) {
			                var r = -100 + Math.abs(X);
			                $(this)[0].style.WebkitTransform = "translateX(" + r + "px)";
			                if (r > 0) {
			                    r = 0;
			                    obj.style.WebkitTransform = "translateX(" + r + "px)";
			                }
			            } else { //向左滑动
			                $(this)[0].style.WebkitTransform = "translateX(" + -100 + "px)";
			            }

			        });
			    }

			    $('.li_record').on('touchend', function (e) {
			     if(flag && e.target.className != 'deleteBtn'){
			         var testId = this.id;
//			         URL最多2000字符，数据量大了，数据传递不完整
//			         var testData=encodeURI(JSON.stringify(getTestData(testId)));
			         var openUrl = "distributedTest/html/details_notes.html?testId=" + testId;
			         hwPluginService.openUrl({url: openUrl}, function (v) {
			         });
			     }
			    })
				});
	
}

function showError(){
	
}

/**
 * <div class="English"></div>
 * <div class="Chinese"></div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 * @descript 获取id为testId的测试记录
 * @auther Administrator
 * @date  2019年1月3日
 */
function getTestData(testId) {
	for(var x in hisoryList){
		if (hisoryList[x].id==testId) {
			return hisoryList[x];
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
function goBack() {
	hwPluginService.goBack(function() {
	});
}

/**
 * <div class="English"></div>
 * <div class="Chinese"> 控制返回时不弹窗</div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 * @descript 
 * @auther Administrator
 * @date  2019年1月10日
 */
function setCookie() {
    sessionStorage.setItem('numId','1001');
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
 * @descript 格式化时间
 * @auther Administrator
 * @date  2019年1月3日
 */
function format(time, format){
    var t = new Date(Number(time));
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

function cancelDeleteRecord(){
	 $(".deleteConfirm").hide();
    $(".shade").hide();
}

function confirmDeleteRecord(){
   // 调用接口删除此房间,并将界面刷新
	var thisRecordId = $("#deleteRecordId").html();
	var recordIds=[];
	if(thisRecordId != "all"){
		recordIds.push(thisRecordId);
		deleteRecord(recordIds,thisRecordId);
	}else{
		deleteRecord(recordIds,thisRecordId);
	}
}


/**
 * <div class="English"></div>
 * <div class="Chinese"></div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 * @descript 删除记录
 * @auther Administrator
 * @date  2019年1月3日
 */
function deleteRecord(recordIds,clearAll) {
    hwPluginService.deleteRoamTestResultList({"Id": recordIds}, function (v) {
        var errorCode = v.errorCode;
        console.log("v:"+JSON.stringify(v));
        if (errorCode == "0") {
        	 $(".deleteConfirm").hide();
             $(".shade").hide();
             if(clearAll=="all"){
            	 $("#ul_list").empty();
             }else {
            	 $("#"+recordIds[0]).remove();
			}
             
        } else {
            var errorMessage = v.errorMessage;
        }
    });
}

/**
 * <div class="English"></div>
 * <div class="Chinese"></div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 * @descript 清空所有记录
 * @auther Administrator
 * @date  2019年1月3日
 */
function clearAll(){
	$("#deleteRec").text(getResource()["DO_YOU_CONFIRM_DELETE_ALL"]);
	$(".deleteConfirm").show();
    $(".shade").show();
    $("#deleteRecordId").html("all");
}

/**
 * <div class="English"></div>
 * <div class="Chinese"></div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 * @descript 判断是不是苹果设备
 * @auther Administrator
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

/**
 * <div class="English"></div>
 * <div class="Chinese">排序函数</div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 * @auther Administrator
 * @date  2019年1月3日
 */
var compare = function(prop) {
	return function(obj1, obj2) {
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

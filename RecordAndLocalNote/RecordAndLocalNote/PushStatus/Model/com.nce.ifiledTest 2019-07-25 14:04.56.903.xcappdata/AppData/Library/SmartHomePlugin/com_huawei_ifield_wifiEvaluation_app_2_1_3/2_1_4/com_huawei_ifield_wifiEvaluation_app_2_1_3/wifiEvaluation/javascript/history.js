//国际化资源(JSON)
var resource = null;
//记录列表
var recordList = [];
var isIphone = false;

function load() {
    isIphone = isApple()
    hwPluginService.getResource(function (data) {
        var errorCode = data.errorCode;
        if (errorCode == 0) {
            resource = data.data;
            initPage();
            queryRecord();
        }
    });

}

function getResource() {
    return resource;
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

function initPage() {
    var spanArray = document.getElementsByTagName("span");
    for (var i = 0; i < spanArray.length; i++) {
        if (spanArray[i].getAttribute("locale_key")) {
            var key = spanArray[i].getAttribute("locale_key")
            spanArray[i].innerHTML = getResource()[key];
        }
    }
}

function goBack() {
    hwPluginService.goBack(function () {
    });
}

/**
 * <div class="English"></div>
 * <div class="Chinese">查询所有历史记录，包括有户型图和无户型图</div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 */

function queryRecord() {
    hwPluginService.getAllResultList(function (r) {
        var errorCode = r.errorCode;
        if (errorCode == "0") {
            recordList = r.data;
            drawRecordList();
        } else {
            //页面上显示还没有历史记录
            var errorMessage = r.errorMessage;
        }
    });

}
/**
 * <div class="English"></div>
 * <div class="Chinese">展示所有历史记录</div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 */

function drawRecordList() {
    var _html = "";
    if (recordList != null && recordList.length > 0) {
        recordList.sort(function (a, b) {
            return b.testId - a.testId;
        })
        //展示数据
        for (var i = 0; i < recordList.length; i++) {
            var record = recordList[i];
            var recordClass = ''
            if (record.score >= 80) {
                recordClass = 'good'
            } else if (record.score >= 60) {
                recordClass = 'pass'
            } else {
                recordClass = 'bad'
            }
            _html += `<li class="li_record" id="${record.testId}">
                            <div>
                                <p>
                                    <span>${record.wiFiName}</span>
                                    <span class="${recordClass}">
                                        <i>${getResource()["ROOM_SCORE"]}</i>
                                        <em>${record.score}</em>
                                    </span>
                                </p>
                                <p>
                                    <span>${new Date(record.testTime).toLocaleString()}</span>
                                    <span>${record.roomResult.length} ${getResource()["RECORD_NUMBER"]}</span>
                                </p>
                            </div>
                            <button class="deleteBtn" id="del_${record.testId}">${getResource()["DELETE"]}</button>
                        </li>`
        }
    }
    $("#ul_list").html(_html);

    $(".deleteBtn").on('click', function (e) {
        var delId = this.id.split("_")[1];
        $(".deleteConfirm").show();
        $(".shade").show();
        $("#deleteRecordId").html(delId);
    });
    //触摸位置
    var initX;
    //滑动时的位置
    var moveX;
    //移动距离
    var X = 0;
    //目标对象位置
    var objX = 0;
    var flag = true;
    $('.li_record').on('touchstart', function (e) {
        flag = true;
        initX = event.targetTouches[0].pageX;
        objX = ($(this)[0].style.WebkitTransform.replace(/translateX\(/g, "").replace(/px\)/g, "")) * 1;
    })
    if (objX == 0) {
        $('.li_record').on('touchmove', function (e) {
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
    } else if (objX < 0) {
        $('.li_record').on('touchmove', function (e) {
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

        if (flag && e.target.className != 'deleteBtn') {
            var testId = this.id;
            var openUrl = "wifiEvaluation/html/nophoto_detail.html?testId=" + testId;
            hwPluginService.openUrl({url: openUrl}, function (v) {
            });
        }
    })
}

function clearAll() {
    $(".deleteConfirm").show();
    $(".shade").show();
    $("#deleteRecordId").html("all");
}

function cancelDeleteRecord() {
    $(".deleteConfirm").hide();
    $(".shade").hide();
}

function confirmDeleteRecord() {
    // 调用接口删除此房间,并将界面刷新
    var thisRecordId = $("#deleteRecordId").html();
    if (thisRecordId != "all") {
        deleteOneResult(thisRecordId);
    } else {
        deleteAllResult();
    }
}

/**
 * <div class="English"></div>
 * <div class="Chinese">删除所有历史记录</div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 */

function deleteAllResult() {
    /****** 传空数组为删除所有数据 ******/
    var testIdArr = [];
    hwPluginService.deleteResultList({testIdList: testIdArr}, function (v) {
        var errorCode = v.errorCode;
        if (errorCode == 0) {
            $(".deleteConfirm").hide();
            $(".shade").hide();
            recordList = [];
            drawRecordList();
        } else {
            var errorMessage = v.errorMessage;
        }
    });
}

/**
 * <div class="English"></div>
 * <div class="Chinese">删除单个历史记录</div>
 * @param <div class="English"></div><div class="Chinese">testId:被删除数据ID</div>
 * @return <div class="English"></div><div class="Chinese"></div>
 */

function deleteOneResult(testId) {
    var testIdArr = [];
    testIdArr.push(testId);
    hwPluginService.deleteResultList({testIdList: testIdArr}, function (v) {
        var errorCode = v.errorCode;
        if (errorCode == 0) {
            $(".deleteConfirm").hide();
            $(".shade").hide();
            //将删除的记录从recordList里删除。
            for (var i = 0; i < recordList.length; i++) {
                if (recordList[i].testId == testId) {
                    recordList.splice(i, 1);
                    break;
                }
            }
            drawRecordList();
        } else {
            var errorMessage = v.errorMessage;
        }
    });
}

/**
 * <div class="English"></div>
 * <div class="Chinese">将毫秒数转换成固定的时间格式</div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 */

Date.prototype.toLocaleString = function () {
    function addZero(num) {
        if (num < 10)
            return "0" + num;
        return num;
    }

    return this.getFullYear() + "/" + addZero(this.getMonth() + 1) + "/" + addZero(this.getDate()) + " " +
        +addZero(this.getHours()) + ":" + addZero(this.getMinutes()) + ":" + addZero(this.getSeconds());
};
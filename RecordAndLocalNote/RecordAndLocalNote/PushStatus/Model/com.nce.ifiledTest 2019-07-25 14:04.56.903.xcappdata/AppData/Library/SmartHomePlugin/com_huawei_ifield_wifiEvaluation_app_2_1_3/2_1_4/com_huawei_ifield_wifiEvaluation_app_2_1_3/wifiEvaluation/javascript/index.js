//成功状态码
const successCode = "0";
//淡入淡出时间（就、毫秒）
const fadeTime = 1000
//得分
var score = null;
// 连接速率
var connectRate = null;
// 信号强度
var signalStrength = null;
// 时延
var timeDelay = null;
var ttl = null;
var bssid = null;

//丢包率
var lostRate = null;
// 当前存在的房间列表。
var roomList = [];

var resource = null;
// 当前wifi名称
var ssidName = null;
// wifi类型是24G还是5G
var radioType = null;
// 当前选中的房间类型
var selectRoomType;
// 无户型图存储评估结果列表
var evaluationList = [];
// 户型图url
var imgPath = '';
// 有户型图存储评估结果列表
var photoEvaluationList = [];

//页面右上角的设置列表按钮是否显示
var settingDisplay = false;

var tScale;

var isIphone = false;
var roomTypes = ["livingroom", "bedroom", "diningroom", "bathroom", "kitchen",
    "other"]

function goBack() {

    hwPluginService.stopWifiTest(function (data) {
    });
    hwPluginService.goBack(function (v) {
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
        if (successCode == errorCode) {
            recordList = r.data;
            if (recordList != null && recordList.length > 0) {
                var roomPigRecords = [];
                for (var i = 0; i < recordList.length; i++) {
                    var record = recordList[i];
                    if (record.testMode == 'roomPig') {
                        roomPigRecords.push(record);
                    }
                }

                if (roomPigRecords != null && roomPigRecords.length > 0) {
                    roomPigRecords.sort(function (a, b) {
                        return b.testId - a.testId;
                    })
                    imgPath = roomPigRecords[0].url;
                    $(".house_type_none").remove();
                    $("#house p").css('display', 'flex');
                    $("<img>", {
                        id: 'imgHouse',
                        src: imgPath
                    }).appendTo($("#house"));
                    $("#imgHouse").on('click', function (event) {
                        event.preventDefault();
                        if (settingDisplay) {
                            $("#setting_list").hide();
                        }
                        var x = event.pageX - (0.2 - 0.05) * distance;
                        var y = event.pageY - (3.27 - 0.05) * distance;
                        console.log("x=" + x + ", y=" + y);
                        createPointDiv(x, y);// 画个圆，且命名。
                    });
                }
            }
        } else {
            // 页面上显示还没有历史记录
            var errorMessage = r.errorMessage;
        }
    });

}

function load() {
    drawInitCanvas();
    isIphone = isApple();
    hwPluginService.getResource(function (data) {
        var errorCode = data.errorCode;
        if (successCode == errorCode) {
            resource = data.data;
            initPage();
            startTest();
            // 查询房间数据17
            queryRoomList();
            getWifiInfo();
            queryRecord();
        }
    });
}

/**
 * <div class="English"></div>
 * <div class="Chinese">渲染测试结果默认阴影</div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 */
function drawInitCanvas() {
    tScale = window.devicePixelRatio;
    var canvas = document.getElementById('canvas')
    var width = window.screen.width / 3.75
    canvas.width = width * 1.3;
    canvas.height = width * 1.08;
    var ctx = canvas.getContext("2d");
    ctx.beginPath();
    ctx.strokeStyle = '#0b6ad3'
    ctx.lineWidth = 5;
    ctx.arc(width * 0.64, width * 0.65, width * 0.60, 0.75 * Math.PI,
        2.25 * Math.PI);
    ctx.stroke();
}

function getResource() {
    return resource;
}

/**
 * <div class="English"></div>
 * <div class="Chinese">获取国际化资源</div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 */
function initPage() {
    var spanArray = document.getElementsByTagName("span");
    for (var i = 0; i < spanArray.length; i++) {
        if (spanArray[i].getAttribute("locale_key")) {
            var key = spanArray[i].getAttribute("locale_key")
            spanArray[i].innerHTML = getResource()[key];
        }
    }
    $("#inputRoomName").attr('placeholder', getResource()['PLEASE_ENTER_ROOM_NAME']);
    $("#uploadMark").html(getResource()['NO_HOUSE_PHOTO'] + '</br>' + getResource()['PLEASE_CLICK_AND_UPLOAD']);
}

function startTest() {
    hwPluginService.startWifiTest(function (data) {
        var errorCode = data.errorCode;
        if (successCode == errorCode) {
            // testInfo: {wifi: {BSSID: "就是MAC", SSID: "wifi名称", linkedSpeed:
            // 72, RSSI: -56}, ping: {TTL: 55, delay: 26, lost: 20}}
            var obj = data.data;
            timeDelay = obj.ping.delay;
            lostRate = obj.ping.lost;
            if (timeDelay < 0) {
                score = 0;
                if (!isIphone) {
                    $("#connectRate").html("--Mbps");
                    $("#signalStrength").html("--dBm");
                } else {
                    $("#signalStrength").html("--");
                }
                $("#timeDelay").html("--ms");
            } else {
                if (!isIphone) {
                    signalStrength = obj.wifi.RSSI;
                    connectRate = obj.wifi.linkedSpeed;
                    // 分数需要计算
                    score = calculateScore(connectRate, signalStrength, timeDelay, lostRate, radioType);
                    $("#signalStrength").html(signalStrength + "dBm");
                } else {
                    signalStrength = obj.wifi.rssi;

                    connectRate = obj.wifi.linkedSpeed;
                    score = calculateScoreIos(connectRate, signalStrength, timeDelay, lostRate)
                    if (signalStrength == 0) {
                        signalStrength = getResource()["NOLEVEL"]
                    } else if (signalStrength == 1) {
                        signalStrength = getResource()["WEAK"]
                    } else if (signalStrength == 2) {
                        signalStrength = getResource()["NORMAL"]
                    } else if (signalStrength == 3) {
                        signalStrength = getResource()["STRONG"]
                    }
                    $("#signalStrength").html(signalStrength);
                    timeDelay = Math.ceil(timeDelay);
                }
                $("#connectRate").html(connectRate + "Mbps");
                $("#timeDelay").html(timeDelay + "ms");
            }
            $("#score").html(score);
            drawCanvas(score);
        } else {
            $(".nowifiHint").show();
            $(".shade").show();
        }
    });
}

/**
 * <div class="English"></div>
 * <div class="Chinese">获取房间数据</div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 */
function queryRoomList() {
    var roomNames = [getResource()["LIVINGROOM"], getResource()["BEDROOM"],
    getResource()["DININGROOM"], getResource()["RESTROOM"],
    getResource()["KITCHEN"]];
    hwPluginService.getRoomList(function (result) {
        var errorCode = result.errorCode;
        if (successCode === errorCode) {
            roomList = result.data;
            if (roomList != null || roomList.length > 0) {
                roomList.sort(function (a, b) {
                    return a.roomId - b.roomId;
                });
                roomList.forEach(function (item) {
                    switch (item.roomName) {
                        case "客厅":
                            item.roomName = getResource()["LIVINGROOM"]
                            break;
                        case "主卧":
                            item.roomName = getResource()["BEDROOM"]
                            break;
                        case "餐厅":
                            item.roomName = getResource()["DININGROOM"]
                            break;
                        case "洗手间":
                            item.roomName = getResource()["RESTROOM"]
                            break;
                        case "厨房":
                            item.roomName = getResource()["LIVINGROOM"]
                            break;
                        case "Living room":
                            item.roomName = getResource()["LIVINGROOM"]
                            break;
                        case "Bedroom":
                            item.roomName = getResource()["BEDROOM"]
                            break;
                        case "Dining room":
                            item.roomName = getResource()["DININGROOM"]
                            break;
                        case "Bathroom":
                            item.roomName = getResource()["RESTROOM"]
                            break;
                        case "Kitchen":
                            item.roomName = getResource()["LIVINGROOM"]
                            break;
                        case "客廳":
                            item.roomName = getResource()["LIVINGROOM"]
                            break;
                        case "主臥":
                            item.roomName = getResource()["BEDROOM"]
                            break;
                        case "餐廳":
                            item.roomName = getResource()["DININGROOM"]
                            break;
                        case "洗手間":
                            item.roomName = getResource()["RESTROOM"]
                            break;
                        case "廚房":
                            item.roomName = getResource()["LIVINGROOM"]
                            break;
                        default:
                            item.roomName = item.roomName
                    }
                });
            }
            drawRoomList();
        } else if ("100101" === errorCode) {
            // 这里做判断：如果没有存储过房间，那么默认存储和展示5个模板房间。如果有存储过，则按结果展示在页面上。
            for (var i = 0; i < 5; i++) {
                var roomInfo = {
                    roomId: i + 1,
                    roomName: $.trim(roomNames[i]),
                    roomType: roomTypes[i]
                };
                roomList.push(roomInfo);
            }
            roomList.sort(function (a, b) {
                return a.roomId - b.roomId;
            });

            drawRoomList();

            for (var i = 0; i < roomList.length; i++) {
                hwPluginService.addRoom({
                    roomId: roomList[i].roomId,
                    roomName: roomList[i].roomName,
                    roomType: roomList[i].roomType
                }, function (res) {
                    var errorCode = res.errorCode;
                    if (successCode == errorCode) {
                        // 返回的房间id，房间名称，房间类型这些信息存到列表里。
                    }
                });
            }
        } else {
            var errorMessage = result.errorMessage;
        }
    });
}

/**
 * <div class="English"></div>
 * <div class="Chinese">将所有房间在页面上画出来</div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 */

function drawRoomList() {
    var _html = "";
    for (var i = 0; i < roomList.length; i++) {
        // 如果有点击标记过
        var roomInfo = roomList[i];
        var roomId = roomInfo.roomId;
        var roomType = roomInfo.roomType;
        var roomName = roomInfo.roomName;
        _html += "<li class='li_room' id='roomId_"
            + roomId
            + "'><button class='close closeRoom' id='btn_"
            + roomId
            + "'></button><img src='../image/"
            + roomType
            + ".png'>"
            + "<div class='right'><p class='title'><span style='white-space:pre;' id='roomName_"
            + roomId + "'>" + roomName
            + "</span><span id='score_" + roomId
            + "'></span></p><div id='content_text_"
            + roomId + "' class='content_text'>" + "<p>"
            + getResource()['CLICK_THEN_MARKER']
            + "</p></div></div> </li>";
    }

    _html += "<li class='add' onclick='addRoom();'></li>"
    /**
     * <div class="English"></div>
     * <div class="Chinese">点击某个房间，将当前评估记录绑定到此房间，并在页面上显示出来</div>
     * @param <div class="English"></div><div class="Chinese"></div>
     * @return <div class="English"></div><div class="Chinese"></div>
     */
    $("#room_container").html(_html);
    if (evaluationList != null && evaluationList.length > 0) {
        for (var j = 0; j < evaluationList.length; j++) {
            var eva = evaluationList[j];
            var rId = eva.room.roomId;
            var detail = eva.testResult;
            for (var k = 0; k < roomList.length; k++) {
                var info = roomList[k];
                var _roomId = info.roomId;
                if (rId == _roomId) {
                    // 将当前数据显示在房间区域。
                    $("#score_" + _roomId).text(detail.score);
                    var contentHtml = "<p><span>"
                    + getResource()['CONNECTION_RATE']
                    + "</span><span>" + detail.wiFi.linkedSpeed
                    + "Mbps</span></p><p><span>"
                    + getResource()['SIGNAL_STRENGTH']
                    + "</span><span>" + detail.wiFi.signalStrength
                    + `${isIphone ? '' : 'dBm'}</span></p>`;
                $("#content_text_" + _roomId).html(contentHtml);
            }
            }
        }
    }

    /*
    * 点击除删除按钮以外的区域，隐藏删除按钮
    */
    $('body:not(.closeRoom)').off('click');
    $('body:not(.closeRoom)').on('click', function () {
        $(".closeRoom").hide();
    })
    // 长按房间列表区域，显示删除图标
    var timeOutEvent;
    var flag = true;
    $(".li_room").off(['touchstart', 'touchmove', 'touchend']);
    $(".li_room").on({
        touchstart: function (e) {
            if (settingDisplay) {
                $("#setting_list").hide();
            }
            flag = true;
            timeOutEvent = setTimeout(function () {
                deleteRoom();
                flag = false;
            }, 1000);
        },
        touchmove: function (e) {
            clearTimeout(timeOutEvent);
            flag = false;
        },
        touchend: function (e) {
            clearTimeout(timeOutEvent);
            if (flag == true) {
                if (timeDelay != null) {
                    var liId = this.id.split("_");
                    // alert(JSON.stringify(liId));
                    var _roomId = liId[1];
                    var roomName;
                    var roomType;
                    for (var index = 0; index < roomList.length; index++) {
                        if (roomList[index].roomId == _roomId) {
                            roomName = roomList[index].roomName;
                            roomType = roomList[index].roomType;
                        }
                    }
                    // 如果【生成报告】按钮为灰，改成蓝色。
                    $("#nophotoGenerate button").css("backgroundColor",
                        "#5295e3");
                    // 将当前数据显示在房间区域。
                    $("#score_" + _roomId).text(score);
                    var contentHtml = `<p><span>`
                        + getResource()['CONNECTION_RATE']
                        + '</span><span>' + connectRate
                        + "Mbps</span></p><p><span>"
                        + getResource()['SIGNAL_STRENGTH']
                        + "</span><span>" + signalStrength
                        + `${isIphone ? '' : 'dBm'}</span></p>`;
                    $("#content_text_" + _roomId).html(contentHtml);

                    // 将评估数据和房间id绑定到一起，以便之后用户点击【生成报告】按钮的时候保存。
                    var evaluation = {
                        room: {
                            roomId: _roomId,
                            roomName: roomName,
                            roomType: roomType
                        },
                        testResult: {
                            score: score,
                            wiFi: {
                                linkedSpeed: connectRate,
                                bSSID: bssid,
                                signalStrength: signalStrength
                            },
                            ping: {
                                TTL: ttl,
                                networkDelay: timeDelay,
                                lost: lostRate
                            }
                        }
                    };
                    if (evaluationList != null && evaluationList.length > 0) {
                        for (var index = 0; index < evaluationList.length; index++) {
                            var eva = evaluationList[index];
                            if (eva.room.roomId == _roomId) {
                                evaluationList.splice(index, 1);
                            }
                        }
                    }
                    evaluationList.push(evaluation);
                }
            }
            e.preventDefault();
        }
    });
    // 点击删除图标，删除对应的房间
    $(".closeRoom")
        .on(
            "touchend",
            function (e) {
                var liId = this.id.split("_");
                var thisRoomId = liId[1];
                $(".deleteConfirm").show();
                $(".shade").show();
                $("#deleteRoomId").html(thisRoomId);
            });
}

function confirmDeleteRoom() {
    // 调用接口删除此房间,并将界面刷新
    var thisRoomId = $("#deleteRoomId").html();
    hwPluginService
        .deleteRoom(
            {
                roomId: thisRoomId
            },
            function (res) {
                $(".deleteConfirm").hide();
                $(".shade").hide();
                $(".closeRoom").hide();
                var errorCode = res.errorCode;
                if (successCode == errorCode) {
                    // 房间列表里也需要删除此房间
                    for (var i = 0; i < roomList.length; i++) {
                        var _room = roomList[i];
                        if (_room.roomId == thisRoomId) {
                            roomList.splice(i, 1);
                        }
                    }
                    drawRoomList();
                    // 如果之前绑定的评估记录有此房间，也需要删除
                    if (evaluationList != null
                        && evaluationList.length > 0) {
                        for (var i = 0; i < evaluationList.length; i++) {
                            var evaluation = evaluationList[i];
                            if (evaluation.room.roomId == thisRoomId) {
                                evaluationList.splice(i, 1);
                            }
                        }
                    }
                } else {
                    var errorMessage = res.errorMessage;
                }
            });
}

function deleteRoom() {
    $(".closeRoom").show();
}

// 点击无户型图【生成报告】按钮之后
function saveEvaluation() {
    if (evaluationList == null || evaluationList.length == 0) {
        return;
    }
    generateReport(evaluationList, false);
}

// 点击有户型图【生成报告】按钮之后
function savePhotoEvaluation() {
    if (photoEvaluationList == null || photoEvaluationList.length == 0) {
        return;
    }
    generateReport(photoEvaluationList, true);
}

/**
 * <div class="English"></div>
 * <div class="Chinese">生成报告</div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 */

function generateReport(recordList, isPhoto) {
    var date = new Date();
    date.getTime();
    var totalScore = 0;
    for (var i = 0; i < recordList.length; i++) {
        totalScore += recordList[i].testResult.score;
    }
    var testMode;
    if (isPhoto) {
        testMode = "roomPig";
    } else {
        testMode = "room";
    }
    var averageScore = Math.round(totalScore / recordList.length);
    var result = {
        testId: date.getTime(),
        testTime: date.getTime(),
        wiFiName: ssidName,
        score: averageScore,
        roomResult: recordList,
        testMode: testMode,
        url: imgPath
    };
    hwPluginService.stopWifiTest(function (data) {
    });
    // 调用接口将评估记录保存起来
    hwPluginService.saveResult(result, function (res) {
        var errorCode = res.errorCode;
        if (successCode == errorCode) {
            // 保存成功，跳转到历史记录页面
            hwPluginService.openUrl({ url: "wifiEvaluation/html/history.html" }, function (v) {
            });

        } else {
            var errorMessage = res.errorMessage;
        }
    });
}

/**
 * <div class="English"></div>
 * <div class="Chinese">打开历史记录页</div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 */

function goHistory() {
    hwPluginService.stopWifiTest(function (data) {
    });
    hwPluginService.openUrl({ url: "wifiEvaluation/html/history.html" }, function (v) {
    });
}

/**
 * <div class="English"></div>
 * <div class="Chinese">打开设置页</div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 */

function goSetting() {
    hwPluginService.stopWifiTest(function (data) {
    });
    hwPluginService.openUrl({ url: "wifiEvaluation/html/setting.html" }, function (v) {
    });
}

/**
 * <div class="English"></div>
 * <div class="Chinese">点击添加房间【+】图标之后</div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 */

function addRoom() {
    if (settingDisplay) {
        $("#setting_list").hide();
    }
    $(".room_add,.shade").css('display', 'block')
}

$('#inputRoomName').focus(function () {
    if (!isIphone) {
        $(".room_add").css('position', 'fixed').css('top', '1.33rem');
    }
})

$('#inputRoomName').blur(function () {
    // 进行延时处理，时间单位为千分之一秒
    setTimeout(function () {
        if (!isIphone) {
            $(".room_add").css('top', '');
        }
    }, 100)
})

/**
 * <div class="English"></div>
 * <div class="Chinese">在添加房间弹出界面 点击 【取消】 按钮</div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 */

function cancelAddRoom() {
    $(".room_add,.shade").css('display', 'none')
}

/**
 * <div class="English"></div>
 * <div class="Chinese">在添加房间弹出界面 点击 【取消】 按钮</div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 */

function cancelDeleteRoom() {
    $(".room_add,.shade").css('display', 'none');
    $(".deleteConfirm").css('display', 'none');
    $(".closeRoom").hide();
}

/**
 * <div class="English"></div>
 * <div class="Chinese">在添加房间弹出界面 点击【 确认】按钮</div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 */

function confirmAddRoom() {
    var inputRoomName = $.trim($("#inputRoomName").val());
    if (inputRoomName == "" || inputRoomName == undefined) {
        $("#marked_words").fadeIn(fadeTime)
            .html(getResource()["PLEASE_ENTER_ROOM_NAME"]).fadeOut(fadeTime);
        return;
    }
    if (selectRoomType == "" || selectRoomType == undefined) {
        $("#marked_words").fadeIn(fadeTime)
            .html(getResource()["NOT_CHOOSE_ROOM_ICON"]).fadeOut(fadeTime);
        return;
    }
    if (roomList != null && roomList.length > 0) {
        // 先比较房间名称是否有重复的(已删除的无需比较)，如有重复，则不能提交，且在界面提示用户
        for (var i in roomList) {
            if (roomList[i].roomName == inputRoomName) {
                $("#marked_words").fadeIn(fadeTime)
                    .html(getResource()["NAME_USED"]).fadeOut(fadeTime);
                return;
            }
        }
    }
    saveRooms(inputRoomName, selectRoomType);
}

/**
 * <div class="English"></div>
 * <div class="Chinese">调用接口保存房间数据</div>
 * @param <div class="English"></div><div class="Chinese">_roomName:房间名称</div>
 * @param <div class="English"></div><div class="Chinese">_roomType:房间类型</div>
 * @return <div class="English"></div><div class="Chinese"></div>
 */

function saveRooms(_roomName, _roomType) {
    hwPluginService.addRoom({
        roomName: _roomName,
        roomType: _roomType
    },
        function (result) {
            var errorCode = result.errorCode;
            if (successCode == errorCode) {
                // 返回的房间id，房间名称，房间类型这些信息存到列表里。
                var roomInfo = result.data;
                roomList.push(roomInfo);
                $(".room_add,.shade").css('display', 'none')
                drawRoomList(); // 刷新页面
            } else if ("100102" == errorCode) {
                // 房间名称已经存在
                $("#marked_words").fadeIn(fadeTime)
                    .html(getResource()["NAME_USED"]).fadeOut(fadeTime);
                return;
            } else if ("100103" == errorCode) {
                // 房间达到20个的上限
                $("#marked_words").fadeIn(fadeTime)
                    .html(getResource()["ROOM_TOO_MUCH"]).fadeOut(fadeTime);
                return;
            }
        });
}

/**
 * <div class="English"></div>
 * <div class="Chinese">获取当前WIFi信息</div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 */

function getWifiInfo() {
    hwPluginService.getConnectWiFi(function (data) {
        var errorCode = data.errorCode;
        if (!isIphone) {
            if (successCode == errorCode) {
                var info = data.data;
                ssidName = info.SSID;
                radioType = info.RadioType;
                $("#wifi_name").css("background-image", "url(../image/androidwifiinfo.png)");
                $("#wifi_name").html(ssidName);
            } else {

            }
        } else {
            if (successCode == errorCode) {
                var info = data.date;
                ssidName = info.SSID;
                radioType = info.RadioType;
                $("#wifi_name").css("background-image", "url(../image/ioswifiinfo.png)");
                $("#wifi_name").html(ssidName);
            } else {

            }
        }

    });
}

/**
 * <div class="English"></div>
 * <div class="Chinese">根据得分渲染背景</div>
 * @param <div class="English"></div><div class="Chinese">score:得分</div>
 * @return <div class="English"></div><div class="Chinese"></div>
 */

function drawCanvas(score) {
    var canvas = document.getElementById('canvas')
    var width = window.screen.width / 3.75
    canvas.width = width * 1.3;
    canvas.height = width * 1.08;
    var ctx = canvas.getContext("2d");
    ctx.beginPath();
    ctx.strokeStyle = '#fff'
    ctx.lineWidth = 5
    ctx.arc(width * 0.64, width * 0.65, width * 0.60, 0.75 * Math.PI,
        2.25 * Math.PI);
    ctx.stroke();
    ctx.beginPath();
    ctx.strokeStyle = '#fff';
    //    if (score < 60) {
    //        ctx.strokeStyle = '#e54545';
    //    } else if (score <= 80) {
    //        ctx.strokeStyle = '#ff980c';
    //    } else {
    //        ctx.strokeStyle = '#4eaff5';
    //    }

    ctx.lineWidth = 5
    var scoreLength = 2.25 * score / 100;
    ctx.arc(width * 0.64, width * 0.65, width * 0.60, 0.75 * Math.PI,
        scoreLength * Math.PI);
    ctx.stroke();
}

/**
 * <div class="English"></div>
 * <div class="Chinese">引入户型图</div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 */

function importPhoto() {
    hwPluginService.selectRoomPig(function (data) {
        var errorCode = data.errorCode;
        if (successCode == errorCode) {
            imgPath = data.data.url;
            if (isIphone) {
                imgPath = data.data.Url;
            }
            $(".house_type_none").remove();
            $("#house p").css('display', 'flex');
            $("<img>", {
                id: 'imgHouse',
                src: imgPath
            }).appendTo($("#house"));
            $("#imgHouse").on('click', function (event) {
                event.preventDefault();
                if (settingDisplay) {
                    $("#setting_list").hide();
                }
                var x = event.pageX - (0.2 - 0.05) * distance;
                var y = event.pageY - (3.27 - 0.05) * distance;
                if (timeDelay != null) {
                    createPointDiv(x, y);
                }
            });
        } else {
            var errorMessage = data.errorMessage;
        }
    });
}

/**
 * <div class="English"></div>
 * <div class="Chinese">点击更换图片</div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 */

function changePhoto() {
    hwPluginService.selectRoomPig(function (data) {
        var errorCode = data.errorCode;
        if (successCode == errorCode) {
            imgPath = data.data.url;
            if (isIphone) {
                imgPath = data.data.Url;
            }
            $("#imgHouse").attr('src', imgPath);
            // 页面原来的测试点清除掉
            $(".btn").remove();
            // 生成报告按钮置灰
            $("#photoGenerate button").css("backgroundColor",
                "#b3b3b3");
            photoEvaluationList = [];
            photoClickCount = 1;
        } else {
            var errorMessage = data.errorMessage;
        }
    });
}

var photoClickCount = 1;

/**
 * <div class="English"></div>
 * <div class="Chinese">创建标记点</div>
 * @param <div class="English"></div><div class="Chinese">x:创建点的横坐标</div>
 * @param <div class="English"></div><div class="Chinese">y:创建点的纵坐标</div>
 * @return <div class="English"></div><div class="Chinese"></div>
 */

function createPointDiv(x, y) {
    var pointImg = '';
    var colorClass = ''
    if (score < 60) {
        pointImg = '../image/pointRed.png';
        colorClass = 'red'
    } else if (score <= 80) {
        pointImg = '../image/pointYellow.png';
        colorClass = 'yellow'
    } else {
        pointImg = '../image/pointBlue.png';
        colorClass = 'blue'
    }
    var _html = "";
    _html += "<button>"
        + photoClickCount + "</button><img src='" + pointImg + "'><span class='" + colorClass + "'>" + score + "</span>";
    var point = $(
        "<div>",
        {
            "class": "btn",
            "css": {
                left: x + 'px',
                top: y + 'px',
            },
            "html": _html
        }).appendTo($("#house"));

    $("#photoGenerate button").css("backgroundColor",
        "#5295e3");
    // 将评估数据和点名称绑定到一起，以便之后用户点击【生成报告】按钮的时候保存。
    var photoEvaluation = {
        room: {
            roomId: null,
            roomName: photoClickCount,
            roomType: null
        },
        roomPig: {
            x: x,
            y: y,
        },
        testResult: {
            score: score,
            wiFi: {
                linkedSpeed: connectRate,
                bSSID: bssid,
                signalStrength: signalStrength
            },
            ping: {
                TTL: ttl,
                networkDelay: timeDelay,
                lost: lostRate
            }
        }
    };
    photoEvaluationList.push(photoEvaluation);
    photoClickCount++;
}

/**
 * <div class="English"></div>
 * <div class="Chinese">判断是否为iphone</div>
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

/**
 * <div class="English"></div>
 * <div class="Chinese">android计算分数规则</div>
 * @param <div class="English"></div>
 *   <div class="Chinese">
 *     _connectRate:连接速率(权重0.1)
 *        5G:
 *        1: >=1024:100分
 *       2：>=886:90分
 *       3：>=433:60分
 *       4：>=100:30分
 *       6：其他0分
 *       2.4G:
 *       1: >=300: 100分
 *       1: >=150 : 90分
 *       2：>=72:  60分
 *       3: >= 30： 30分
 *    </div>
 * @param <div class="English"></div>
 *      <div class="Chinese">
 *          _signStrength:信号强度(权重0.3)
 *           Good>=-67：90
 *           NORMAL>=-70:70
 *           POOR>=-80:20
 *           WERY_POOR>=-90:0
 *           0
 *     </div>
 * @param <div class="English"></div>
 *      <div class="Chinese">
 *          _timeDelay:时延（权重0.2）
 *          <20：80
 *          <=100：60
 *          <=300：30
 *          0
 *       </div>
 * @param <div class="English"></div>
 *      <div class="Chinese">
 *          _lostRate:丢包率（权重0.4）
 *          0：100
 *          <5：60
 *          <10：30
 *          0
 *     </div>
 * @param <div class="English"></div><div class="Chinese">_type:WiFi类型</div>
 * @return <div class="English"></div><div class="Chinese"></div>
 */

function calculateScore(connectRate, signStrength, timeDelay, lostRate, type) {
    var rateScore, signScore, delayScore, lostScore = 0;
    if (type == '2.4G') {
        if (connectRate >= 300) {
            rateScore = 100
        } else if (connectRate >= 150) {
            rateScore = 90 + (connectRate - 150) / ((300 - 150) / 10)
        } else if (connectRate >= 72) {
            rateScore = 60 + (connectRate - 72) / ((150 - 72) / 30);
        } else if (connectRate >= 30) {
            rateScore = 30 + (connectRate - 30) / ((72 - 30) / 30);
        } else {
            rateScore = connectRate;
        }
    } else {
        if (connectRate >= 1024) {
            rateScore = 100;
        } else if (connectRate >= 886) {
            rateScore = 90 + Math.round((connectRate - 886) / ((1024 - 886) / 10));
        } else if (connectRate >= 443) {
            rateScore = 60 + Math.round((connectRate - 443) / ((886 - 443) / 30));
        } else if (connectRate >= 100) {
            rateScore = 30 + Math.round((connectRate - 100) / ((443 - 100) / 30));
        } else {
            rateScore = 0 + Math.round(connectRate / (100 / 30));
        }
    }


    if (signStrength >= 0) {
        signScore = 100;
    } else if (signStrength >= -67) {
        signScore = 90 + Math.round((signStrength + 67) / (67 / 10));
    } else if (signStrength >= -70) {
        signScore = 70 + Math.round((signStrength + 70) / ((70 - 67) / 20));
    } else if (signStrength >= -80) {
        signScore = 20 + Math.round((signStrength + 80) / ((80 - 70) / 50));
    } else {
        signScore = 0;
    }

    if (timeDelay <= 0) {
        delayScore = 100
    } else if (timeDelay < 20) {
        delayScore = 80 + Math.round((20 - timeDelay) / ((20 - 0) / 20))
    } else if (timeDelay <= 100) {
        delayScore = 60 + Math.round((100 - timeDelay) / ((100 - 20) / 20))
    } else if (timeDelay <= 300) {
        delayScore = 30 + Math.round((300 - timeDelay) / ((300 - 100) / 30))
    } else {
        delayScore = 0;
    }

    if (lostRate == 0) {
        lostScore = 100
    } else if (lostRate < 5) {
        lostScore = 60 + Math.round((5 - lostRate) / (5 / 40))
    } else if (lostRate < 10) {
        lostScore = 30 + Math.round((10 - lostRate) / ((10 - 5) / 30))
    } else {
        lostScore = 0;
    }
    score = Math.round(rateScore * 0.1 + signScore * 0.3 + delayScore * 0.2
        + lostScore * 0.4);
    return score;
}

/**
 * <div class="English"></div>
 * <div class="Chinese">ios计算分数规则</div>
 * @param <div class="English"></div>
 *   <div class="Chinese">
 *       connectRate:连接速率(权重0.1)
 *        5G:
 *        1: >=1024:100分
 *       2：>=886:90分
 *       3：>=433:60分
 *       4：>=100:30分
 *       6：其他0分
 *       2.4G:
 *       1: >=300: 100分
 *       1: >=150 : 90分
 *       2：>=72:  60分
 *       3: >= 30： 30分
 *    </div>
 * @param <div class="English"></div>
 *      <div class="Chinese">
 *           signStrength:信号强度(权重0.2)
 *           Good：100
 *           Normal：70
 *           Poor: 30
 *     </div>
 * @param <div class="English"></div>
 *      <div class="Chinese">
 *           timeDelay:时延（权重0.3）
 *           0 : 100
 *          <20：80
 *          <=100：60
 *          <=300：30
 *          0
 *       </div>
 * @param <div class="English"></div>
 *      <div class="Chinese">
 *          lostRate:丢包率（权重0.4）
 *          0：100
 *          <5：60
 *          <10：30
 *          0
 *     </div>
 * @return <div class="English"></div><div class="Chinese"></div>
 */

function calculateScoreIos(connectRate, signStrength, timeDelay, lostRate) {
    var rateScore, signScore, delayScore, lostScore = 0;

    if (connectRate >= 300) {
        rateScore = 100
    } else if (connectRate >= 150) {
        rateScore = 90 + (connectRate - 150) / ((300 - 150) / 10)
    } else if (connectRate >= 72) {
        rateScore = 60 + (connectRate - 72) / ((150 - 72) / 30);
    } else if (connectRate >= 30) {
        rateScore = 30 + (connectRate - 30) / ((72 - 30) / 30);
    } else {
        rateScore = connectRate;
    }

    if (signStrength == 0) {
        signScore = 0
    } else if (signStrength == 1) {
        signScore = 30
    } else if (signStrength == 2) {
        signScore = 70
    } else if (signStrength == 3) {
        signScore = 100
    }

    if (timeDelay = 0) {
        delayScore = 100
    } else if (timeDelay < 20) {
        delayScore = 80 + Math.round((20 - timeDelay) / ((20 - 0) / 20))
    } else if (timeDelay <= 100) {
        delayScore = 60 + Math.round((100 - timeDelay) / ((100 - 20) / 40))
    } else if (timeDelay <= 300) {
        delayScore = 30 + Math.round((300 - timeDelay) / ((300 - 100) / 30))
    } else {
        delayScore = 0;
    }

    if (lostRate == 0) {
        lostScore = 100
    } else if (lostRate < 5) {
        lostScore = 60 + Math.round((5 - lostRate) / (5 / 40))
    } else if (lostRate < 10) {
        lostScore = 30 + Math.round((10 - lostRate) / ((10 - 5) / 30))
    } else {
        lostScore = 0;
    }
    score = Math.round(rateScore * 0.1 + signScore * 0.3 + delayScore * 0.2
        + lostScore * 0.4);
    return score;
}

/**
 * <div class="English"></div>
 * <div class="Chinese">卡片切换</div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 */

var swiper = new Swiper('.swiper-container', {
    pagination: {
        el: '.swiper-pagination',
    },
    loop: false,
});

$("#setting").on('click', function () {
    settingDisplay = !settingDisplay;
    if (settingDisplay) {
        $("#setting_list").show();
    } else {
        $("#setting_list").hide();
    }
});


/**
 * <div class="English"></div>
 * <div class="Chinese">添加房间时单击切换图标事件</div>
 * @param <div class="English"></div><div class="Chinese"></div>
 * @return <div class="English"></div><div class="Chinese"></div>
 */
//房间图标单击事件
$('.room_type ul li a').on('click', function () {
    if (settingDisplay) {
        $("#setting_list").hide();
    }
    var selectImageId = this.id.split("_")[1];
    for (var i = 0; i < $('.room_type ul li').length; i++) {
        var src = $('.room_type ul li').eq(i).find('a').find('img').attr('src').split('_')
        if (src.length == 2) {
            $('.room_type ul li').eq(i).find('a').find('img').attr('src', `${src[0]}_grey.png`)
        } else {
            $('.room_type ul li').eq(i).find('a').find('img').attr('src', `${src[0].split('.png')[0]}_grey.png`)
        }
    }
    $(this).find('img').attr('src', `${$(this).find('img').attr('src').split('_grey')[0]}.png`)
    selectRoomType = roomTypes[selectImageId];
});

$('.clear_text').click(function () {
    $('.input_add_room input').val('')
})

$('.banner').click(function () {
    if (settingDisplay) {
        $("#setting_list").hide();
    }
})

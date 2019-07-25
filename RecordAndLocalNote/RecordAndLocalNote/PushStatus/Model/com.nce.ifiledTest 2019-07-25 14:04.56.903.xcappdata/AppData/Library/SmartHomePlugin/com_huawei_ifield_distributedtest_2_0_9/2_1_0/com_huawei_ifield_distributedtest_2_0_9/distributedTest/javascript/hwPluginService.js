function debug(info) {
//	alert(info);
	console.log(info);
}

var bridge = {
  //  default:this,// for typescript
    call: function (method, args, cb) {
        var ret = '';
        if (typeof args == 'function') {
            cb = args;
            args = {};
        }
        var arg={data:args===undefined?null:args}
        if (typeof cb == 'function') {
            var cbName = 'dscb' + window.dscb++;
            window[cbName] = cb;
            arg['_dscbstub'] = cbName;
        }
        arg = JSON.stringify(arg)

        //if in webview that dsBridge provided, call!
        if(window._dsbridge){
           ret=  _dsbridge.call(method, arg)
        }else if(window._dswk||navigator.userAgent.indexOf("_dsbridge")!=-1){
           ret = prompt("_dsbridge=" + method, arg);
        }

       return  JSON.parse(ret||'{}').data
    },
    register: function (name, fun, asyn) {
        var q = asyn ? window._dsaf : window._dsf
        if (!window._dsInit) {
            window._dsInit = true;
            //notify native that js apis register successfully on next event loop
            setTimeout(function () {
                bridge.call("_dsb.dsinit");
            }, 0)
        }
        if (typeof fun == "object") {
            q._obs[name] = fun;
        } else {
            q[name] = fun
        }
    },
    registerAsyn: function (name, fun) {
        this.register(name, fun, true);
    },
    hasNativeMethod: function (name, type) {
        return this.call("_dsb.hasNativeMethod", {name: name, type:type||"all"});
    },
    disableJavascriptDialogBlock: function (disable) {
        this.call("_dsb.disableJavascriptDialogBlock", {
            disable: disable !== false
        })
    }
};

var pluginService = {
//	default: this,
	openUrl: function (args, cb) {
		bridge.call("openUrl", args, cb);
	},
	goBack: function (cb) {
		bridge.call("goBack", cb);
	},
	selectRoomPig: function (cb) {
		bridge.call("selectPig", cb);
	},
	getRoomList: function (cb) {
		bridge.call("getRoomList", cb);
	},
	addRoom: function (args, cb) {
        bridge.call("addRoom", args, cb);
    },
    modifyRoom: function (args, cb) {
        bridge.call("modifyRoom", args, cb);
    },
    deleteRoom: function (args, cb) {
        bridge.call("deleteRoom", args, cb);
    },
    startWifiTest: function (cb) {
        bridge.call("startWifiTest", cb);
    },
    stopWifiTest: function (cb) {
        bridge.call("stopWifiTest", cb);
    },
    saveResult: function (args, cb) {
        bridge.call("saveResult", args, cb);
    },
    getAllResultList: function (cb) {
        bridge.call("getAllResultList", cb);
    },
    deleteResultList: function (args, cb) {
        bridge.call("deleteResultList", args, cb);
    },
    getSetting: function (cb) {
        bridge.call("getSetting", cb);
    },
    modifySetting: function (args, cb) {
        bridge.call("modifySetting", args, cb);
    },
    getConnectWiFi: function (cb) {
        bridge.call("getConnectWiFi", cb);
    },
    getResource: function (cb) {
        bridge.call("getResource", cb);
    },
    startRoamTest: function (cb) {
        bridge.call("startRoamTest", cb);
    },
    stopRoamTest: function (args, cb) {
        bridge.call("stopRoamTest", args, cb);
    },
    getRoamTestResultList: function (cb) {
        bridge.call("getRoamTestResultList", cb);
    },
    deleteRoamTestResultList: function (args, cb) {
        bridge.call("deleteRoamTestResultList", args, cb);
    },
};

!function () {
    if (window._dsf) return;
    var ob = {
        _dsf: {
            _obs: {}
        },
        _dsaf: {
            _obs: {}
        },
        dscb: 0,
        //dsBridge: bridge,
		hwPluginService: pluginService,
        close: function () {
            bridge.call("_dsb.closePage")
        },
        _handleMessageFromNative: function (info) {
            var arg = JSON.parse(info.data);
            var ret = {
                id: info.callbackId,
                complete: true
            }
            var f = this._dsf[info.method];
            var af = this._dsaf[info.method]
            var callSyn = function (f, ob) {
                ret.data = f.apply(ob, arg);
                bridge.call("_dsb.returnValue", ret);
            }
            var callAsyn = function (f, ob) {
                arg.push(function (data, complete) {
                    ret.data = data;
                    ret.complete = complete!==false;
                    bridge.call("_dsb.returnValue", ret)
                })
                f.apply(ob, arg);
            }
            if (f) {
                callSyn(f, this._dsf);
            } else if (af) {
                callAsyn(af, this._dsaf);
            } else {
                //with namespace
                var name = info.method.split('.');
                if (name.length<2) return;
                var method=name.pop();
                var namespace=name.join('.')
                var obs = this._dsf._obs;
                var ob = obs[namespace] || {};
                var m = ob[method];
                if (m && typeof m == "function") {
                    callSyn(m, ob);
                    return;
                }
                obs = this._dsaf._obs;
                ob = obs[namespace] || {};
                m = ob[method];
                if (m && typeof m == "function") {
                    callAsyn(m, ob);
                    return;
                }
            }
        }
    }
    for (var attr in ob) {
        window[attr] = ob[attr]
    }
    bridge.register("_hasJavascriptMethod", function (method, tag) {
         var name = method.split('.')
         if(name.length<2) {
           return !!(_dsf[name]||_dsaf[name])
         }else{
           // with namespace
           var method=name.pop()
           var namespace=name.join('.')
           var ob=_dsf._obs[namespace]||_dsaf._obs[namespace]
           return ob&&!!ob[method]
         }
    })
}();

module.exports = bridge;
--定义一个类 iOS 独有
waxClass{"PandoraActViewController", PandoraBaseViewController,protocol = {"PandoraLuckyStarOperateDownloadFinish"}}

--定义一个全局的table
PandoraActViewController = {}
this = PandoraActViewController

--公告面板
--使用lua的table方法 
--OC的类的调用是 Class(Instance):Method(params,..),而lua table的方法是Class(Instance).Method(params,..)

------------------------------------ Life Cycle ----------------------------------
-- iOS Life Cycle，和安卓类似，如果是ViewController(Activity, Fragment)，需要各自的lua中管理各自的Life Cycle的回调
function viewWillAppear(self,animated)
    plSafeCallHandler(pcall(plViewWillAppear, self, animated))
end

function plViewWillAppear(self,animated)
    PandoraActViewController.InitLogic()
    PandoraActViewController.InitViewSetup()
end

function viewDidAppear( self, animated )
    plSafeCallHandler(pcall(plpViewDidAppear, self, animated))
end

function plpViewDidAppear(self, animated )
--COSPER super属性无法调用
--    super:viewDidAppear(super,animated)
    --self.backView:setView(self);
end


------------------------------------ Lua 编写规范 (双端保持一样的规范，具体的UI实现不一致)----------------------------------
function PandoraActViewController.InitLogic()
    --拉取钻石数量
    local notifTable = {}
    table["getdiamond"] = "number"
    Pandora.SendRequest(101,table，nil) --101标识通知, 回调为空
   
    --拉取数据
    --活动面板需要拉取精彩活动，假日尊享，预留页签位1，预留页签位2
    local noticeChannelId = PandoraConstant.isTestChannel ~= true and tostring(activitypannel) or tostring(activitypannel_test);
    local jiariChannelId = PandoraConstant.isTestChannel ~= true and tostring(activityJingcaihuodong) or tostring(activityJingcaihuodong_test);
    local yuliu1 = PandoraConstant.isTestChannel ~= true and tostring(activityYuliu1) or tostring(activityYuliu1_test);
    local yuliu2 = PandoraConstant.isTestChannel ~= true and tostring(activityYuliu2) or tostring(activityYuliu2_test);

    --获取网络数据
    Pandora.SendRequest(1, json1, callback1)
    Pandora.SendRequest(1, json2, callback2)
    Pandora.SendRequest(1, json3, callback3)
    Pandora.SendRequest(1, json4, callback4)

    --Pandora 统一提供回调
    Pandora.closeLuaTimer()
end

--View的实现各自是不同的
function PandoraActViewController.InitViewSetup( )
    --当打开界面的时候聚焦到第一个tab的第一个公告活动上
    if self.backView ~= nil and self.backView.tabTable ~= nil and self.backView.tabTable[1] ~= nil then
        self.backView:tabClick(self.backView.tabTable[1], true);
    end
end
function PandoraActViewController.AddBackView(self)
    safeCall(this.pAddBackView)
end

-- 双端各自实现UI操作，
function PandoraActViewController.pAddBackView( self )

    if self:view():frame().width > self:view():frame().height then 
        self.main_width = self:view():frame().width;
        self.main_height = self:view():frame().height;
    else
        self.main_width = self:view():frame().height;
        self.main_height = self:view():frame().width;
    end
    local back_W = self.main_width/10*8.5;
    local back_H = back_W/900*570;
    local back_y;
    --使用Pandora提供的封装的接口 DeviceType = 0 是 Phone 2 是 iPad
    if Pandora.DeviceType == 0 then
        if TGTools:getCurrentDevice() == 1 then
--          back_W = self.main_width/10*9.2;
--          back_H = back_W/900*580;
            back_y = (self.main_height - back_H)/3*2
        else
            back_y = (self.main_height - back_H)
        end
    elseif Pandora.DeviceType == 1 then
        back_y = (self.main_height - back_H)/2
    end
    self.backView = PandLuaBackView:initWithFrame(CGRect((self.main_width - back_W)/2,back_y,back_W,back_H));
    self.backView.selectTab = 1;
    self:view():addSubview(self.backView);
    self.backView:setView(self);
end

function PandoraActViewController.OnImageCallBack(self,responseObject,url)
    if self.backView ~= nil then
--        self.backView:updateImage();
    end
end

function PandoraActViewController.OnDownloadFinish(self)
    plSafeCallHandler(pcall(PandoraActViewController.pldownloadFinish,self))
end

function pldownloadFinish(self)
	plLog("PandoraActViewController download finish")
	if self.backView ~= nil then
        self.backView:setView(self);
    end
end

function PandoraActViewController.OnDataChanged(self)
    plSafeCallHandler(pcall(PandoraActViewController.plpdataChanged, self))
end

function PandoraActViewController.plpdataChanged(self)
    TGTools:plLog("update  delegate --------------")
--add bu cosperyu 20151111
    if self.backView ~= nil then
        self.backView:setView(self);
    end
end

--关闭事件统一走Close或者Hide事件
function PandoraActViewController.Hide(self,btn)
    plSafeCallHandler(pcall(this.pDoClose, self, btn))
end

function PandoraActViewController.pHide(self,btn)
    --首先让那个tab聚焦到第一个tab上面。以免造成有延迟切换
    if self.backView ~= nil and self.backView.tabTable ~= nil and self.backView.tabTable[1] ~= nil then
        self.backView:tabClick(self.backView.tabTable[1], true);
    end
    --TODO 逻辑和视图分开
    PandoraActViewController.LogicHide()
    PandoraActViewController.ViewHide()
    
end

function PandoraActViewController.LogicClose()
    --埋点：活动中心的关闭
    local staticReportTable = {}
    staticReportTable.jumpUrl = aURL;
    local staticReportJsonString = PLJsonManager.encode(staticReportTable)
    Pandora.SendRequest(1, staticReportJsonString, nil)
end

function PandoraActViewController.ViewClose()
    PandoraManager:hideActivityPanel(self)
end

function PandoraActViewController.Close()
    local result = safeCall(PandoraActViewController.pClose)
    if result == false then
        return false
    else
        return true
    end
end

function PandoraActViewController.pClose()
    PandoraActViewController.ViewClose()
    PandoraActViewController.LogicClose()
end

function PandoraActViewController.ViewClose( )
    --视图置nil
    if self.backView ~= nil then
        self.backView:removeFromSuperview()
        self.backView:releaseObjects()
        self.backView = nil
    end
end

function PandoraActViewController.LogicClose( )
    --mGetActlistDataDelegate改为setMGetActlistDataDelegate cosperyu 20151112
    --代理置nil
    PandoraOprate:getClass():getInstanceOprate():setMGetActlistDataDelegate(nil);
    PandoraOprate:getClass():getInstanceOprate():setMGetImageDelegate(nil);
end
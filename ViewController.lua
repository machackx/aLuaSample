waxClass{"PandoraActViewController", PandoraBaseViewController,protocol = {"PandoraLuckyStarOperateDownloadFinish"}}

--公告面板
function plAddBackView(self)

    local result = plSafeCallHandler(pcall(plpAddBackView, self))
    if result == false then
        return false
    else
        return true
    end
end

function plpAddBackView( self )

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
	if UIDevice:currentDevice():userInterfaceIdiom() == 0 then
		if TGTools:getCurrentDevice() == 1 then
--			back_W = self.main_width/10*9.2;
--			back_H = back_W/900*580;
			back_y = (self.main_height - back_H)/3*2
		else
			back_y = (self.main_height - back_H)
		end
	elseif UIDevice:currentDevice():userInterfaceIdiom() == 1 then
		back_y = (self.main_height - back_H)/2
	end
    self.backView = PandLuaBackView:initWithFrame(CGRect((self.main_width - back_W)/2,back_y,back_W,back_H));
    self.backView.selectTab = 1;
    self:view():addSubview(self.backView);
    self.backView:setView(self);
end

function plViewWillAppear(self,animated)
    --拉取钻石数量
    PandoraNotification:notificationSentWithType_content("getdiamond","number");

    --拉取数据
    --活动面板需要拉取精彩活动，假日尊享，预留页签位1，预留页签位2
    local noticeChannelId = PandoraModelIns():configFile():isTestChannel() ~= true and tostring(activitypannel) or tostring(activitypannel_test);
    local jiariChannelId = PandoraModelIns():configFile():isTestChannel() ~= true and tostring(activityJingcaihuodong) or tostring(activityJingcaihuodong_test);
    local yuliu1 = PandoraModelIns():configFile():isTestChannel() ~= true and tostring(activityYuliu1) or tostring(activityYuliu1_test);
    local yuliu2 = PandoraModelIns():configFile():isTestChannel() ~= true and tostring(activityYuliu2) or tostring(activityYuliu2_test);

    --获取网络数据
    PandoraOprate:getActList_isLocal_channelid_infoid(PandoraOprateIns(),"NO", {noticeChannelId}, nil);
    PandoraOprate:getActList_isLocal_channelid_infoid(PandoraOprateIns(),"NO", {jiariChannelId}, nil);
    PandoraOprate:getActList_isLocal_channelid_infoid(PandoraOprateIns(),"NO", {yuliu1}, nil);
    PandoraOprate:getActList_isLocal_channelid_infoid(PandoraOprateIns(),"NO", {yuliu2}, nil);

    --设置刷新界面代理
    PandoraOprate:getClass():getInstanceOprate():setDownloadDelegate(self)
--    PandoraOprate:getClass():getInstanceOprate():setMGetActlistDataDelegate(self);
    PandoraOprate:getClass():getInstanceOprate():setMGetImageDelegate(self);

    PandoraManager:closeLuaTimer();


    --当打开界面的时候聚焦到第一个tab的第一个公告活动上
    if self.backView ~= nil and self.backView.tabTable ~= nil and self.backView.tabTable[1] ~= nil then
        self.backView:tabClick(self.backView.tabTable[1], true);
    end
end

function viewWillAppear(self,animated)
    plSafeCallHandler(pcall(plViewWillAppear, self, animated))
end

function getImageCallBack_url(self,responseObject,url)
    if self.backView ~= nil then
--        self.backView:updateImage();
    end
end

function viewDidAppear( self, animated )
    plSafeCallHandler(pcall(plpViewDidAppear, self, animated))
end

function plpViewDidAppear(self, animated )
--COSPER super属性无法调用
--    super:viewDidAppear(super,animated)
    --self.backView:setView(self);
end

function downloadFinish(self)
    plSafeCallHandler(pcall(pldownloadFinish,self))
end
function pldownloadFinish(self)
	plLog("PandoraActViewController download finish")
	if self.backView ~= nil then
        self.backView:setView(self);
    end
end

function dataChanged(self)
    plSafeCallHandler(pcall(plpdataChanged, self))
end

function plpdataChanged(self)
    TGTools:plLog("update  delegate --------------")
--add bu cosperyu 20151111
    if self.backView ~= nil then
        self.backView:setView(self);
    end
end

function doClose(self,btn)
    plSafeCallHandler(pcall(plpdoClose, self, btn))
end

function plpdoClose(self,btn)
    --首先让那个tab聚焦到第一个tab上面。以免造成有延迟切换
    if self.backView ~= nil and self.backView.tabTable ~= nil and self.backView.tabTable[1] ~= nil then
        self.backView:tabClick(self.backView.tabTable[1], true);
    end

    --埋点：活动中心的关闭
    PandoraOprate:statisticsReport_channelId_type_actId_jumpType_jumpUrl_recommendId_changjingId_goodsId_fee_currencyType_actStyle_flowId(1,0,5,0,0,"","0","0","0",0,"1","0","0");
    --PandoraManager:closeCurrentSDKViewWithViewController(self);
    PandoraManager:hideActivityPanel(self)
end

function releaseObjects(self)
    local result = plSafeCallHandler(pcall(plReleaseObjects, self))
    if result == false then
        return false
    else
        return true
    end
end

function plReleaseObjects( self )
--add by cosperyu 20151112
    if self.backView ~= nil then
        self.backView:removeFromSuperview()
        self.backView:releaseObjects()
        self.backView = nil
    end
--mGetActlistDataDelegate改为setMGetActlistDataDelegate cosperyu 20151112
    PandoraOprate:getClass():getInstanceOprate():setMGetActlistDataDelegate(nil);
    PandoraOprate:getClass():getInstanceOprate():setMGetImageDelegate(nil);
end

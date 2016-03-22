-- require "ScreenApdaterUtil"
-- require "ResGetUtil"
-- require "ViewUtils";
-- require "ViewUtils"
-- require "ResGetUtil"
-- require "idFile";
-- require "Tools"

local TAG = "PandoraNotice";
local noticeADTitle;--活动标题
local noticeTimer;--倒计时
local noticeHtmlView;--图文详情
local exchangeBtn;
local scrollView;--滚动按钮
local ActInfos;
local ChannelId;
local lianjiefu="距活动结束：";
local viewlayout;
local layoutNotice;
local textBg;
local currentTimeTaskInstantce;
function NoticeSetChannelId(ChannelId1)
  ChannelId=ChannelId1;
end
function setNoticeShowData(ActInfo,netTime)
  ActInfos=ActInfo;
  if(currentTimeTaskInstantce ~= nil and noticeTimer~= nil) then
    currentTimeTaskInstantce:registerObserver(noticeTimer);
  end
  if(ActInfos~=nil)then
    noticeADTitle:setText(ActInfos:getAct_title());
    --0为当为0是不显示倒计时，为1时显示倒计时
    local showlog=ActInfos:getShowflag();
    if(showlog==nil)then
      noticeTimer:setVisibility(8);
      viewlayout:getLayoutParams():addRule(2,exchangeBtn:getId());
    else
      if(showlog=="1")then
        if(ActInfos:getAct_end_time()~=nil and netTime~=nil)then
          noticeTimer:setEndTime(ActInfos:getAct_end_time());
          noticeTimer:setVisibility(View().VISIBLE);
        else
          noticeTimer:setVisibility(8);
        end

      else if(showlog=="0")then
        noticeTimer:setVisibility(8);
      end
      end
    end
    print(ActInfos:getJumpurl().."dddd");
    noticeHtmlView:setContent(ActInfos,ChannelId.."");
    print("设置信息success");
    jumpUrl=ActInfos:getJumpurl();
    if((ActInfos:getJumpurl()==nil) or (ActInfos:getJumpurl()==""))then
      exchangeBtn:setVisibility(8);--8
    else
      exchangeBtn:setVisibility(View().VISIBLE);--8
    end
    if(exchangeBtn:getVisibility()==8 and noticeTimer:getVisibility()==0)then
      if((viewlayout~=nil )and ( viewlayout:getLayoutParams()~=nil) and (noticeTimer~=nil) and (noticeTimer:getId()~=nil))then
        viewlayout:getLayoutParams():addRule(2,noticeTimer:getId());
      end
    else if(noticeTimer:getVisibility()==8 and exchangeBtn:getVisibility()==0)then
      if((viewlayout~=nil )and ( viewlayout:getLayoutParams()~=nil) and (exchangeBtn~=nil) and (exchangeBtn:getId()~=nil))then
        viewlayout:getLayoutParams():addRule(2,exchangeBtn:getId());
      end
    end
    end
  else
    print("获取到得数据为null");
    return;
  end
  --添加点击事件
end
--添加布局
function noticeInitUI(context,dir)
  local mdir;
  if(dir~=nil)then
    mdir=dir;
  end
  local marginLeft12=marginLeftTen(12);
  local marginLeft5=marginLeftTen(8);
  local marginLeft40=marginLeftTen(40);
  --最外层
  layoutNotice = RelativeLayout(context);
  local layoutParams = luajava.newInstance("android.widget.RelativeLayout$LayoutParams", -1, -1);
  layoutNotice:setPadding(marginLeft12, 0, marginLeft12, 0);
  layoutNotice:setLayoutParams(layoutParams);
  print("xxxxx layoutNotice "..tostring(layoutNotice))

  --标题的背景
  textBg = ImageView(context);
  local  textBgParams =  getRelaLayoutParams(458,75);
  textBgParams:addRule(14);
  textBg:setLayoutParams(textBgParams);
  setBackgroundResource(textBg, dir.."/pandora_exchange_title_bg.png",pandora_exchange_title_bg, 458,75);
  layoutNotice:addView(textBg);
  textBg:setId(pandoraNoticenoticeADTitleBackGroundId)
  print("xxxxx textBg "..tostring(textBg))

  --活动标题
  noticeADTitle=TextView(context);
  local  noticeADTitlePara = getRelaLayoutParams(597,75);
  noticeADTitlePara:addRule(14);--14=RelativeLayout.CENTER_HORIZONTAL
  noticeADTitlePara:addRule(6,textBg:getId());--6=ALIGN_TOP
  noticeADTitle:setGravity(17);--Gravity().CENTER=17
  noticeADTitle:setTextColor(-1);--白色为-1
  noticeADTitle:setSingleLine(true);
  noticeADTitle:setEllipsize(luajava.bindClass("android.text.TextUtils$TruncateAt").END);
  noticeADTitle:setTextSize(getTextSize(17));
  noticeADTitle:getPaint():setFakeBoldText(true);
  noticeADTitle:setLayoutParams(noticeADTitlePara);
  noticeADTitle:setId(pandoraNoticenoticeADTitleId);
  noticeADTitle:setPadding(marginLeftTen(100), 0, marginLeftTen(100), 0);--修改
  noticeADTitle:setText("活动更新中")
  --  setBackgroundResource(noticeADTitle, dir.."/pandora_exchange_title_bg.png",pandora_exchange_title_bg,568,75);--修改  layoutNotice:addView(noticeADTitle);
  layoutNotice:addView(noticeADTitle);
  print("xxxxx noticeADTitle "..tostring(noticeADTitle))

  --立即购买
  exchangeBtn = TextView(context)
  local exchangeBtnParam  = getRelaLayoutParams(148,64);
  exchangeBtnParam:setMargins(0,0,0,marginLeft12);
  exchangeBtnParam:addRule(11);
  exchangeBtnParam:addRule(12);
  exchangeBtn:setLayoutParams(exchangeBtnParam)
  local viewGradientUtils=luajava.newInstance("com.tencent.pandora.tool.ViewGradientUtils");
  if(pandora_exchange_btn~=nil and pandora_yilingqu_btn_bg~=nl)then
    exchangeBtn:setBackgroundDrawable(viewGradientUtils:setNewSelector(context,pandora_yilingqu_btn_bg,pandora_exchange_btn));
  end
  exchangeBtn:setTextColor(viewGradientUtils:setColorStateList(-131587,-7714304));
  exchangeBtn:setText("立即前往");
  exchangeBtn:setTextSize(getTextSize(12))
  exchangeBtn:setGravity(Gravity().CENTER);
  exchangeBtn:setPadding(0, -marginLeftTen(8), 0, 0);
  exchangeBtn:setId(pandoraNoticeexchangeBtnId);
  exchangeBtn:setVisibility(8);--默认隐藏
  layoutNotice:addView(exchangeBtn);
  print("xxxxx exchangeBtn "..tostring(exchangeBtn))

  --添加倒计时
  noticeTimer = luajava.newInstance("com.tencent.pandora.view.TimeCountdownView",context);
  local noticeTimerPara = getRelaLayoutParams(-1,64);
  noticeTimerPara:addRule(9);--9为据左边
  noticeTimerPara:addRule(12);
  noticeTimerPara:addRule(0,exchangeBtn:getId());
  noticeTimerPara:setMargins(0,0,0,marginLeft12);
  noticeTimerPara:addRule(15);
  noticeTimer:setLayoutParams(noticeTimerPara)
  noticeTimer:setId(pandoraNoticenoticeTimerId);
  noticeTimer:setTextColor(-31744); ---31744= #ff8400
  noticeTimer:setTextSize(getTextSize(11));
  noticeTimer:setGravity(16);
  noticeTimer:setColor(-1);
  noticeTimer:setTimersString(lianjiefu,"天","小时","分","秒","");
  noticeTimer:setEndStringColor(-1);--活动时间结束改为了白色的字体
  noticeTimer:setVisibility(8);--默认隐藏
  currentTimeTaskInstantce = TimeTask();
  layoutNotice:addView(noticeTimer);
  print("xxxxx noticeTimer "..tostring(noticeTimer))


  viewlayout= RelativeLayout(context);
  viewlayout:setId(pandoraNoticeviewlayoutId);
  local viewlayoutParams = getRelaLayoutParams(597, -1);
  viewlayoutParams:addRule(3,noticeADTitle:getId());
  viewlayoutParams:addRule(2,exchangeBtn:getId());
  viewlayoutParams:addRule(2,noticeTimer:getId());
  viewlayoutParams:addRule(13);
  viewlayoutParams:setMargins(0,0,0,marginLeft12);
  viewlayout:setLayoutParams(viewlayoutParams);
  setBackgroundResource(viewlayout, mdir.."/pandora_leiji_right_bottom_bg.png",pandora_leiji_right_bottom_bg,597, 1);
  layoutNotice:addView(viewlayout);
  print("xxxxx viewlayout "..tostring(viewlayout))

  --添加scrollview
  scrollView = ScrollView(context);
  local scrollViewPara= getRelaLayoutParams(-1, -1);--290-90=205
  scrollViewPara:setMargins(marginLeft5,marginLeft12,marginLeft5,marginLeft12);
  scrollViewPara:addRule(2,exchangeBtn:getId());
  scrollView:setLayoutParams(scrollViewPara);
  scrollView:setId(pandoraNoticescrollViewId);
  scrollView:setVerticalScrollBarEnabled(false);
  viewlayout:addView( scrollView);
  print("xxxxx scrollView "..tostring(scrollView))

  --添加图文布局
  noticeHtmlView=luajava.newInstance("com.tencent.pandora.view.htmltextview.HtmlTextView",context);
  local htmlLayoutPara= layoutParams;
  noticeHtmlView:setLayoutParams(htmlLayoutPara);
  noticeHtmlView:setTextColor(-460552);--#c7c5c5=-3684923 #"#f8f8f8"=-4605552
  noticeHtmlView:setId(pandoraNoticenoticeHtmlViewId);
  noticeHtmlView:setText("活动更新中：若多次打开面板不显示活动内容，可尝试退出游戏后重新登录查看活动内容。")
  scrollView:addView(noticeHtmlView);
  print("xxxxx noticeHtmlView "..tostring(noticeHtmlView))


  local listener = luajava.createProxy("android.view.View$OnClickListener", {
    onClick = function(v)
      if(ActInfos~=nil and ActInfos:getJumpurl()~=nil)then
        local jumpBtn =luajava.bindClass("com.tencent.pandora.tool.PandoraCallBack");
        print("local url is "..ActInfos:getJumpurl())
        jumpBtn:actJumpTwo(ActInfos:getJumpurl())
        if(ActInfos~=nil and ChannelId~=nil)then
          local staticReport =luajava.newInstance("com.tencent.pandora.tool.LogReportUtil");
          staticReport:staticReport("1",ChannelId.."","3",ActInfos:getInfo_id().."","1",ActInfos:getJumpurl().."","0","0","0","0","0","2",tonumber(ActInfos:getAct_style()),0);
          print("notice前往按钮点击按钮上报成功");
        end
      end
    end });
  exchangeBtn:setOnClickListener(listener);
  return layoutNotice;
end
--设置默认滚动套最头部
function setNoticeScrollY()
  scrollView:setScrollY(0);
end

function destroyPandoraNotice()
  print("recycle xxxx layoutNotice------------------- ")
  currentTimeTaskInstantce:unregisterObserver(noticeTimer);
  clearLayoutNinePatch(layoutNotice,1)
  if layoutNotice ~= nil then
    layoutNotice = nil
  end
  if noticeADTitle ~= nil then
    noticeADTitle = nil
  end

  print("recycle xxxx textBg------------------- ")
  clearBitmap(textBg,0)
  if textBg ~= nil then
    textBg = nil
  end

  print("recycle xxxx exchangeBtn------------------- ")
  if exchangeBtn ~= nil then
    local exchangeBtnDrawable = exchangeBtn:getBackground()
    print("recycle xxxx exchangeBtnDrawable "..tostring(exchangeBtnDrawable))
    if exchangeBtnDrawable ~= nil then
      local exchangeBtnNineState = exchangeBtnDrawable:getConstantState()
      print("recycle xxxx exchangeBtnNineState "..tostring(exchangeBtnNineState))
      -- local exchangeBtnNinrightePatch = exchangeBtnNineState.mNinePatch
      -- print("recycle xxxx exchangeBtnNinrightePatch "..tostring(exchangeBtnNinrightePatch))
      -- exchangeBtnNinrightePatch = nil
      exchangeBtnNineState = nil
      exchangeBtnDrawable = nil
    end
    exchangeBtn:setBackgroundDrawable(nil)
    exchangeBtn = nil
  end

  print("recycle xxxx viewlayout------------------- ")
  clearLayoutNinePatch(viewlayout,1)
  if viewlayout ~= nil then
    viewlayout = nil
  end

  print("recycle xxxx scrollView------------------- ")
  clearBitmap(scrollView,1)
  if scrollView ~= nil then
    scrollView = nil
  end

  if noticeHtmlView ~= nil then
    noticeHtmlView = nil
  end
end

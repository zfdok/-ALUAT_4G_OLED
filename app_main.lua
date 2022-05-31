--- 模块功能：APP MAIN  
-- @author JWL
-- @license MIT
-- @copyright JWL
-- @release 2020.04.02
-- require"ril"
-- require "utils"
require "sys"
require "pins"

module(..., package.seeall)

_G.DeviceName = "al00034g0090"
_G.ProductId = "4LwKzUwOpX"
_G.token =
    "version=2018-10-31&res=products%2F4LwKzUwOpX%2Fdevices%2Fal00034g0090&et=4092599349&method=md5&sign=HRjDTluMI4R5RFQG8GKX4Q%3D%3D"

_G.HaveHumi = true -- 是否测湿度 false
_G.screen_scroll = 0 -- 界面轮播计数
_G.temp_humi_state = 0 -- 轮播界面
_G.LCD_STATE = true -- 屏幕亮暗状态
_G.REC_STATE = false -- 记录状态
_G.temp = 12.54 -- 默认温度
_G.humi = 34.56 -- 默认湿度
_G.period = 5 -- 采样周期
_G.tempU = 40 -- 温度上限
_G.tempL = -40 -- 温度下限
_G.tempUA = 0 -- 高温报警数
_G.tempLA = 0 -- 低温报警数
_G.REC_count = 0 -- 纪录个数
_G.SINGLE_QUERY = 0 -- 信号
_G.BATT_VAL = 3760 -- 电池电压
_G.BATT_LEV = 100 -- 电池百分比
_G.BATT_CHARGING = false -- 电池充电状态
_G.SCREEN_STATE = 0 -- 当前界面 0 主界面 1飞行模式 2.蓝牙模式 3.U盘模式 4.系统信息
_G.FLY_STATE = false -- 飞行模式状态
_G.temp_alarm = false -- 是否超限报警
_G.flyrec_count = 0 -- 飞行状态下的记录条目
_G.tempfail = 0 -- 连接失败表示位
_G.emegency = 0 -- 出现报警紧急情况
_G.already_beep = 0 -- 防止重复beep标识位
_G.stop_beep = 0 -- 防止重复beep标识位

function start_main()
    log.info("=======================Starting")
    sys.publish("SINGLE_QUERY_ON")
    sys.publish("LCD_STATE_ON")
    sys.publish("REC_STATE_OFF")
end

sys.subscribe("LCD_WELCOME_DONE", start_main)

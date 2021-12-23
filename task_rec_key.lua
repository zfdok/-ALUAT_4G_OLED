module(..., package.seeall)
require "utils"
require "pm"
require "pins"

local rec_key = pio.P0_19
local rec_key_down_start = 0
local rec_key_down_end = 0
rec_key_down_flag = false

-------------------------------------------------------------------------
function rec_key_while_recon()
    log.info("收到: REC_STATE_ON, 更改 _G.REC_STATE = true")
    _G.REC_STATE = true
end

function rec_key_while_recoff()
    log.info("收到: REC_STATE_OFF, 更改 _G.REC_STATE = false")
    _G.REC_STATE = false
end

sys.subscribe("REC_STATE_ON", rec_key_while_recon)
sys.subscribe("REC_STATE_OFF", rec_key_while_recoff)
--------------------------按键1 记录键-------------------------------------
function rec_keyIntFnc(msg)
    if _G.LCD_STATE then
        log.info("testGpioSingle.rec_keyIntFnc", msg, getrec_keyFnc())
        -- 上升沿中断
        if _G.SCREEN_STATE == 0 then
            if msg == cpu.INT_GPIO_POSEDGE then
                rec_key_down_end = rtos.tick()
                log.warn("抬起", rec_key_down_end)
                rec_key_down_flag = false
                if rec_key_down_end - rec_key_down_start > 600 and rec_key_down_end - rec_key_down_start < 2000 then
                    _G.REC_STATE = not _G.REC_STATE
                    if _G.REC_STATE then
                        sys.publish("REC_STATE_ON")
                        log.warn("...开启记录")
                    else
                        sys.publish("REC_STATE_OFF")
                        log.warn("...关闭记录")
                    end
                elseif rec_key_down_end - rec_key_down_start >= 1500 then
                    if not _G.FLY_STATE then
                        log.warn("********************************进入飞行模式")
                        _G.FLY_STATE = true
                        net.switchFly(true)
                        _G.SINGLE_QUERY = 0
                        _G.SCREEN_STATE = 0
                    else
                        log.warn("********************************退出飞行模式")
                        _G.FLY_STATE = false
                        net.switchFly(false)
                        _G.SINGLE_QUERY = 26
                        _G.SCREEN_STATE = 0
                    end
                else
                end
                pm.sleep("REC_KEY")
            else
                pm.wake("REC_KEY")
                rec_key_down_start = rtos.tick()
                log.warn("按下", rec_key_down_start)
                rec_key_down_flag = true
                task_auto_screenoff.oled_on_start = rtos.tick()
            end
        end
    else
        if msg == cpu.INT_GPIO_POSEDGE then
            pm.wake("REC_KEY")
            log.warn("点亮屏幕")
            _G.LCD_STATE = true
            sys.publish("LCD_STATE_ON")
            rec_key_down_flag = false
            pm.sleep("REC_KEY")
        end
    end
    pm.sleep("REC_KEY")
end

-- rec_key配置为中断，可通过getrec_keyFnc()获取输入电平，产生中断时，自动执行rec_keyIntFnc函数
getrec_keyFnc = pins.setup(rec_key, rec_keyIntFnc, pio.PULLUP)

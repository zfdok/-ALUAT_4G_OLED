module(..., package.seeall)
require "utils"
require "pm"
---------------------------------------------------------♥♥♥♥♥♥♥♥♥♥-------------------------------------

local tmp, hum -- 原始数据

function ds18b20_init()
    pmd.ldoset(15, pmd.LDO_VLCD)
end

function ds18b20_getTH()
    local status, temperature = onewire.read_ds18b20(pio.P0_7)
    sys.wait(200)
    if status == onewire.OK then
        -- log.info("18b20","temperature:",temperature/10000)
        if temperature ~= 0 then
            _G.temp = temperature / 10000
        end
    elseif status == onewire.NOT_SENSOR then
        log.info("18b20", "未检测到传感器,请检查硬件连接")
    elseif status == onewire.READ_ERROR then
        log.info("18b20", "读取数据过程错误")
    elseif status == onewire.CHECK_ERROR then
        log.info("18b20", "数据校验错误")
    end
end

---------------------------------------------------------♥♥♥♥♥♥♥♥♥♥-------------------------------------
function ds18b20_while_lcdon()
    if not _G.HaveHumi then
        log.info("ds18b20收到: LCD_STATE_ON 开启频繁测量!")
        sys.taskInit(function()
            while _G.LCD_STATE do
                ds18b20_init()
                ds18b20_getTH()
                -- log.info("ds18b2020", "temp,humi", _G.temp, _G.humi)
            end
        end)
    end
end

function ds18b20_while_lcdoff()
    if not _G.HaveHumi then
        log.info("ds18b20收到: LCD_STATE_OFF 关闭频繁测量!")
        _G.LCD_STATE = false
    end
end

function ds18b20_get_recing()
    sys.taskInit(function()
        if not _G.LCD_STATE then
            log.info("ds18b20收到: RECING, 采集一次温度!")
            ds18b20_init()
            ds18b20_getTH()
        end
    end)
end

sys.subscribe("LCD_STATE_ON", ds18b20_while_lcdon)
sys.subscribe("LCD_STATE_OFF", ds18b20_while_lcdoff)
-- sys.subscribe("RECING", ds18b20_get_recing)

----------------------------------------------------------------
-- 启动个task, 定时查询ds18b2020的数据
sys.taskInit(function()
    if not _G.HaveHumi then
        ds18b20_init()
    end
end)

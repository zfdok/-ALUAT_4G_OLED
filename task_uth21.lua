module(..., package.seeall)
require "utils"
require "pm"
---------------------------------------------------------♥♥♥♥♥♥♥♥♥♥-------------------------------------

local tmp, hum -- 原始数据
local addr = 0x40
local id = 2

function sht20_init()
    if i2c.setup(id, i2c.SLOW, addr) ~= i2c.SLOW then
        i2c.close(id)
        log.warn("SHT20", "open i2c error.")
        return
    end
end

function sht20_getTH()
    -- print("=================测温度=========================")
    i2c.send(id, addr, string.char(0xe3))
    sys.wait(50)
    tmp = i2c.recv(id, addr, 2)
    -- log.info("SHT20", "read tem data", tmp:toHex())
    i2c.send(id, addr, string.char(0xe5))
    sys.wait(50)
    hum = i2c.recv(id, addr, 2)
    -- log.info("SHT20", "read hum data", hum:toHex())
    local _, tval = pack.unpack(tmp, '>H')
    local _, hval = pack.unpack(hum, '>H')
    if tval and hval then
        _G.temp = ((1750 * (tval) / 65535 - 450)) / 10
        _G.humi = ((1000 * (hval) / 65535)) / 10
        -- log.info("SHT20", "temp,humi", _G.temp, _G.humi)
    end
end

---------------------------------------------------------♥♥♥♥♥♥♥♥♥♥-------------------------------------
function sht20_while_lcdon()
    if _G.HaveHumi then
        log.info("sht20收到: LCD_STATE_ON 开启频繁测量!")
        sys.taskInit(function()
            while _G.LCD_STATE do
                sht20_getTH()
                log.warn("SHT20", "temp,humi", _G.temp, _G.humi)
            end
        end)
    end
end

function sht20_while_lcdoff()
    if _G.HaveHumi then
        log.info("sht20收到: LCD_STATE_OFF 关闭频繁测量!")
        _G.LCD_STATE = false
    end
end

function sht20_get_recing()
    sys.taskInit(function()
        if not _G.LCD_STATE then
            log.info("sht20收到: RECING, 采集一次温度!")
            sht20_getTH()
        end
    end)
end

sys.subscribe("LCD_STATE_ON", sht20_while_lcdon)
sys.subscribe("LCD_STATE_OFF", sht20_while_lcdoff)
-- sys.subscribe("RECING", sht20_get_recing)

----------------------------------------------------------------
-- 启动个task, 定时查询sht20的数据
sys.taskInit(function()
    if _G.HaveHumi then
        sht20_init()
    end
end)

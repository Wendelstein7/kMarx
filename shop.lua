
--  00      0000 0000    000000   0000000   00    00      00000   00    00    0000    0000000
--  00      0000000000  00000000  00000000  00    00     000000   00    00   000000   00000000         8888
--  00      00  00  00  00    00  00    00  000  000    00        00    00  00    00  00    00        888888
--  00  00  00  00  00  00    00  00    00   000000     00        00    00  00    00  00    00       88    88
--  00 00   00  00  00  00000000  00000000    0000       00000    00000000  00    00  00000000       88    88
--  0000    00  00  00  00000000  0000000     0000        00000   00000000  00    00  0000000      888888888888
--  000     00  00  00  00    00  00 000     000000           00  00    00  00    00  00           888888888888
--  0000    00  00  00  00    00  00  000   000  000          00  00    00  00    00  00           888 v0.4 888
--  00 00   00  00  00  00    00  00   000  00    00     000000   00    00   000000   00           888888888888
--  00  00  00  00  00  00    00  00    00  00    00     00000    00    00    0000    00            8888888888

-- kMarx (Krist Markets) Shop Program v0.4 - Created by HydroNitrogen - purpose environment: KristPay on SwitchCraft 2
-- https://energetic.pw/computercraft/kmarx | energetic.pw/kmarx

-- ### LICENCE, RIGHTS and TERMS ###
-- Anyone is allowed to use this program on any kristpay enabled server, given that they comply with the usage policy below.
-- Anyone is allowed to make modifications for their personal needs.
-- Nobody is allowed to sell, distribute or publish this program or parts of it in any way, modified or unmodified.
-- Nobody can hold me, the author, responsible for any damage this program may cause, including but not limited to theft/loss of krist, items, blocks etc...
--
-- ### USAGE POLICY ###
-- Anyone using this shop program must either:
-- 1. Share a royalty (percentage) of more than 10% of sales (rounded down in your favour) with the creator of the program (HydroNitrogen).
-- 2. Have a permanent display of credits on the main shop monitor.
-- You can choose either 1, 2 or both options via the configuration file that the shop uses.

local success, error = pcall(function()
  local dataFile = "/shopData.lua"

  if not fs.exists("k.lua") then shell.run("pastebin", "run 4ddNhMYd") end

  local w = require("w")
  local r = require("r")
  local k = require("k")
  local jua = require("jua")
  os.loadAPI("json.lua")
  local await = jua.await

  r.init(jua)
  w.init(jua)
  k.init(jua, json, w, r)

  if not fs.exists("blittle.lua") then shell.run("pastebin", "get ujchRSnU blittle.lua") end
  os.loadAPI("blittle.lua")

  local mon = peripheral.find("monitor") -- Do you error here? Then you haven't connected a monitor properly.
  mon.setTextScale(.5)
  local xm, ym = mon.getSize()

  local chestContent = {}
  local stockLevels = {}
  local lookupTable = {}
  local chest

  local monMaxX, monMaxY = mon.getSize()

  local function getData(file)
    print("[info] Getting data from file")
    if not fs.exists(file) then error("There's no data file! The shop needs a data file!") end
    local h = fs.open(file, "r")
    local unserialized = textutils.unserialize(h.readAll()) -- Do you error here? Then your data file is probably corrupt.
    if unserialized == nil then error("[error] Could not serialize shop data file!") end
    h.close()
    return unserialized
  end

  if not fs.exists(dataFile) then shell.run("wget", "https://energetic.pw/computercraft/kmarx/assets/v0.4/shopData.lua " .. dataFile) end
  local shopData = getData(dataFile)

  local function makeDataSafe()
    shopData.config.name = string.sub(shopData.config.name, 1, 128)
    shopData.config.owner = string.sub(shopData.config.owner, 1, 64)
    shopData.config.krist.privatekey = string.sub(shopData.config.krist.privatekey, 1, 512)
    shopData.config.krist.domainname = string.sub(shopData.config.krist.domainname, 1, 32)
    shopData.config.messages.overpaid = string.sub(shopData.config.messages.overpaid, 1, 192)
    shopData.config.messages.underpaid = string.sub(shopData.config.messages.underpaid, 1, 192)
    shopData.config.messages.outofstock = string.sub(shopData.config.messages.outofstock, 1, 192)
    shopData.config.messages.unknownitem = string.sub(shopData.config.messages.unknownitem, 1, 192)
  end

  makeDataSafe()

  local function saveConfig()
    if not fs.exists("/shopData-old.lua") then
      fs.copy(dataFile, "/shopData-old.lua")
    end
    local serialized = textutils.serialize(shopData)
    local handle = fs.open(dataFile, "w")
    handle.write(serialized)
    handle.flush()
    handle.close()
    print("[info] Config file updated and saved.")
  end

  local function updateConfigTo2()
    shopData.config.krist.iskristwalletformat = false
    shopData.config.redstoneside = "top"
    shopData.iv = 2

    --UNCOMMENT the following line if you want to have your config file automatically updated. [ NOT RECOMMENDED ]
    --saveConfig()
  end

  local logoImage
  if not fs.exists(shopData.layout.logo.location) then shell.run("wget", "https://energetic.pw/computercraft/kmarx/assets/v0.4/shopLogo.lua " .. shopData.layout.logo.location) end

  local function wrapChest()
    chest = peripheral.wrap(shopData.config.chestside)
  end

  local function getStock()
    print("[info] Getting chest content")
    chestContent = chest.list()

    for c = 0, #shopData.stock do
      stockLevels[shopData.stock[c].name .. ":" .. shopData.stock[c].damage] = 0
    end

    print("[info] Populating lookup table")
    for c = 0, #shopData.stock do
      lookupTable[shopData.stock[c].meta] = { ["longname"] = shopData.stock[c].name .. ":" .. shopData.stock[c].damage, ["index"] = c }
    end

    print("[info] Listing stock")
    for c = 1, chest.size() do
      if chestContent[c] ~= nil and stockLevels[chestContent[c].name .. ":" .. chestContent[c].damage] ~= nil then
        stockLevels[chestContent[c].name .. ":" .. chestContent[c].damage] = stockLevels[chestContent[c].name .. ":" .. chestContent[c].damage] + chestContent[c].count
      end
    end
  end

  local function replaceStuff(input)
    if input == "domainname" then
      return shopData.config.krist.domainname
    elseif input == "shopname" then
      return shopData.config.name
    elseif input == "shopowner" then
      return shopData.config.owner
    elseif input == "kristaddress" then
      return shopData.config.krist.address
    elseif input == "kristname" then
      return shopData.config.krist.name
    end
    return "*"
  end

  local function clearLines(y1, y2, colour, terminal)
    local x0, y0 = terminal.getCursorPos()
    local colour0 = terminal.getBackgroundColour()
    terminal.setBackgroundColor(colour)
    for y = y1, y2 do
      terminal.setCursorPos(1, y)
      terminal.clearLine()
    end
    terminal.setCursorPos(x0, y0)
    terminal.setBackgroundColor(colour0)
  end

  local function drawShopItem(index, yoff)
    clearLines(yoff, yoff + shopData.layout.table.size.row - 1, shopData.layout.colours.table.content.row[index % 2], mon)

    mon.setCursorPos(monMaxX * shopData.layout.columnoffset.name, yoff + math.floor(shopData.layout.table.size.row / 2.1 ))
    mon.setTextColor(shopData.layout.colours.table.content.name[index % 2])
    mon.setBackgroundColor(shopData.layout.colours.table.content.row[index % 2])
    mon.write(shopData.stock[index].displayname)

    mon.setCursorPos(monMaxX * shopData.layout.columnoffset.stock, yoff + math.floor(shopData.layout.table.size.row / 2.1 ))
    if stockLevels[shopData.stock[index].name .. ":" .. shopData.stock[index].damage] > 0 then
      mon.setTextColor(shopData.layout.colours.table.content.stockfull[index % 2])
    else
      mon.setTextColor(shopData.layout.colours.table.content.stockempty[index % 2])
    end
    mon.setBackgroundColor(shopData.layout.colours.table.content.row[index % 2])
    mon.write(string.format("%.0f", stockLevels[shopData.stock[index].name .. ":" .. shopData.stock[index].damage]) .. shopData.layout.table.suffix.stock)

    mon.setCursorPos(monMaxX * shopData.layout.columnoffset.price, yoff + math.floor(shopData.layout.table.size.row / 2.1 ))
    mon.setTextColor(shopData.layout.colours.table.content.price[index % 2])
    mon.setBackgroundColor(shopData.layout.colours.table.content.row[index % 2])
    mon.write(shopData.stock[index].price .. shopData.layout.table.suffix.currency)

    mon.setCursorPos(monMaxX * shopData.layout.columnoffset.meta, yoff + math.floor(shopData.layout.table.size.row / 2.1 ))
    mon.setTextColor(shopData.layout.colours.table.content.meta[index % 2])
    mon.setBackgroundColor(shopData.layout.colours.table.content.row[index % 2])
    mon.write(shopData.stock[index].meta .. string.gsub(shopData.layout.table.suffix.meta, "{(.-)}", replaceStuff))
  end

  local function drawHeader(yoff)
    local ysize = #shopData.layout.header.text + shopData.layout.header.spacing

    clearLines(yoff, yoff + ysize, shopData.layout.colours.header.background, mon)
    for i = 1,#shopData.layout.header.text do
      mon.setCursorPos(shopData.layout.header.indent + 1, yoff + shopData.layout.header.spacing + i - 1)
      mon.setTextColor(shopData.layout.colours.header.text)
      mon.setBackgroundColor(shopData.layout.colours.header.background)
      mon.write(string.gsub(shopData.layout.header.text[i], "{(.-)}", replaceStuff))
    end
  end

  local function drawFooter()
    local ysize = #shopData.layout.footer.text + shopData.layout.footer.spacing
    local ystart = monMaxY - ysize

    clearLines(ystart, monMaxY, shopData.layout.colours.footer.background, mon)
    for i = 1,#shopData.layout.footer.text do
      mon.setCursorPos(shopData.layout.footer.indent + 1, ystart + shopData.layout.footer.spacing + i - 1)
      mon.setTextColor(shopData.layout.colours.footer.text)
      mon.setBackgroundColor(shopData.layout.colours.footer.background)
      mon.write(string.gsub(shopData.layout.footer.text[i], "{(.-)}", replaceStuff))
    end
  end

  local function drawTableHeader(yoff)
    local ysize = shopData.layout.table.size.header

    clearLines(yoff, yoff + ysize - 1, shopData.layout.colours.table.header.row, mon)
    mon.setCursorPos(monMaxX * shopData.layout.columnoffset.name, yoff + math.floor(shopData.layout.table.size.header / 2.1 ))
    mon.setTextColor(shopData.layout.colours.table.header.name)
    mon.setBackgroundColor(shopData.layout.colours.table.header.row)
    mon.write(shopData.layout.table.columnname.name)

    mon.setCursorPos(monMaxX * shopData.layout.columnoffset.stock, yoff + math.floor(shopData.layout.table.size.header / 2.1 ))
    mon.setBackgroundColor(shopData.layout.colours.table.header.row)
    mon.write(shopData.layout.table.columnname.stock)

    mon.setCursorPos(monMaxX * shopData.layout.columnoffset.price, yoff + math.floor(shopData.layout.table.size.header / 2.1 ))
    mon.setTextColor(shopData.layout.colours.table.header.price)
    mon.setBackgroundColor(shopData.layout.colours.table.header.row)
    mon.write(shopData.layout.table.columnname.price)

    mon.setCursorPos(monMaxX * shopData.layout.columnoffset.meta, yoff + math.floor(shopData.layout.table.size.header / 2.1 ))
    mon.setTextColor(shopData.layout.colours.table.header.meta)
    mon.setBackgroundColor(shopData.layout.colours.table.header.row)
    mon.write(shopData.layout.table.columnname.meta)
  end

  local function drawTableContent(yoff)
    for i = 0, #shopData.stock do
      drawShopItem(i, yOffset["tableContents"][i])
      yOffset["tableContents"][i] = yoff
      yoff = yoff + shopData.layout.table.size.row
    end
  end

  local function drawTableFooter(yoff)
    local ysize = shopData.layout.table.size.footer

    clearLines(yoff, yoff + ysize - 1, shopData.layout.colours.table.footer.row, mon)
    mon.setCursorPos(monMaxX * shopData.layout.columnoffset.name, yoff + math.floor(shopData.layout.table.size.footer / 2.1 ))
    mon.setTextColor(shopData.layout.colours.table.footer.name)
    mon.setBackgroundColor(shopData.layout.colours.table.footer.row)
    mon.write(shopData.layout.table.columnname.name)

    mon.setCursorPos(monMaxX * shopData.layout.columnoffset.stock, yoff + math.floor(shopData.layout.table.size.footer / 2.1 ))
    mon.setBackgroundColor(shopData.layout.colours.table.footer.row)
    mon.write(shopData.layout.table.columnname.stock)

    mon.setCursorPos(monMaxX * shopData.layout.columnoffset.price, yoff + math.floor(shopData.layout.table.size.footer / 2.1 ))
    mon.setTextColor(shopData.layout.colours.table.footer.price)
    mon.setBackgroundColor(shopData.layout.colours.table.footer.row)
    mon.write(shopData.layout.table.columnname.price)

    mon.setCursorPos(monMaxX * shopData.layout.columnoffset.meta, yoff + math.floor(shopData.layout.table.size.footer / 2.1 ))
    mon.setTextColor(shopData.layout.colours.table.footer.meta)
    mon.setBackgroundColor(shopData.layout.colours.table.footer.row)
    mon.write(shopData.layout.table.columnname.meta)
  end

  local function drawLogo(yoff)
    blittle.draw(logoImage, 1, yoff + 1, mon)
  end

  local function drawCredits(y)
    local creditsText
    if monMaxX >= 86 then
      creditsText = "kMarx shop program - v0.4 - Created by HydroNitrogen - more info on energetic.pw/kmarx"
    elseif monMaxX >= 71 then
      creditsText = "kMarx shop program v0.4 - Created by HydroNitrogen - energetic.pw/kmarx"
    elseif monMaxX >= 55 then
      creditsText = "kMarx shop v0.4 - by HydroNitrogen - energetic.pw/kmarx"
    elseif monMaxX >= 48 then
      creditsText = "kMarx v0.4 by HydroNitrogen - energetic.pw/kmarx"
    elseif monMaxX >= 31 then
      creditsText = "kMarx v0.4 - energetic.pw/kmarx"
    elseif monMaxX >= 18 then
      creditsText = "energetic.pw/kmarx"
    else
      creditsText = "kMarx"
    end
    mon.setCursorPos(math.ceil((monMaxX / 2) - (creditsText:len() / 2)) + 1, y)
    mon.setBackgroundColor(colours.yellow)
    mon.setTextColor(colours.black)
    mon.clearLine()
    mon.write(creditsText)
  end

  local yOffset = { ["default"] = 1}

  local function drawShopGui()
    mon.setBackgroundColor(shopData.layout.colours.empty)
    mon.clear()
    local yoff = 1

    if shopData.layout.credits.forceVisible or shopData.config.krist.royaltyrate <= .1 then
      drawCredits(yoff)
      yoff = yoff + 1
    end

    if shopData.layout.visible.logo then
      logoImage = blittle.shrink(paintutils.loadImage(shopData.layout.logo.location), shopData.layout.colours.logo.background)
      drawLogo(yoff)
      yOffset["logo"] = yoff
      yoff = yoff + shopData.layout.logo.verticalSize
    end

    if shopData.layout.visible.header then
      drawHeader(yoff)
      yOffset["header"] = yoff
      yoff = yoff + shopData.layout.header.spacing * 2 + #shopData.layout.header.text
    end

    if shopData.layout.visible.table.header then
      drawTableHeader(yoff)
      yOffset["tableHeader"] = yoff
      yoff = yoff + shopData.layout.table.size.header
    end

    yOffset["tableContents"] = {}
    for i = 0, #shopData.stock do
      drawShopItem(i, yoff)
      yOffset["tableContents"][i] = yoff
      yoff = yoff + shopData.layout.table.size.row
    end

    if shopData.layout.visible.table.footer then
      yOffset["tableFooter"] = yoff
      drawTableFooter(yoff)
      yoff = yoff + shopData.layout.table.size.footer
    end

    if shopData.layout.visible.footer then
      drawFooter()
    end
  end

  local function updateStock()
    print("[info] Updated stock levels")
    chestContent = chest.list()
    stockLevels = {}

    for c = 0, #shopData.stock do
      stockLevels[shopData.stock[c].name .. ":" .. shopData.stock[c].damage] = 0
    end

    for c = 1, chest.size() do
      if chestContent[c] ~= nil and stockLevels[chestContent[c].name .. ":" .. chestContent[c].damage] ~= nil then
        stockLevels[chestContent[c].name .. ":" .. chestContent[c].damage] = stockLevels[chestContent[c].name .. ":" .. chestContent[c].damage] + chestContent[c].count
      end
    end

    for i = 0, #shopData.stock do
      drawShopItem(i, yOffset["tableContents"][i])
    end
  end

  local function dispense(item, amount)
    print("[info] Dispensing " .. amount .. " of " .. item)
    local amountToDispense = amount

    for c = 1, chest.size() do
      if chestContent[c] ~= nil and (chestContent[c].name .. ":" .. chestContent[c].damage) == item then
        local dispensed = chest.drop(c, amountToDispense, shopData.config.dispensedirection)
        amountToDispense = amountToDispense - dispensed
        if amountToDispense == 0 then return end
      end
    end
  end

  local function drawShutdownGUI()
    mon.setBackgroundColor(colours.grey)
    mon.setTextColor(colours.lightGrey)
    mon.clear()
    local shutDownMsg = "Shop has been shut down manually."
    mon.setCursorPos(math.ceil((xm/ 2) - (shutDownMsg:len() / 2)) + 1, ym / 2)
    mon.write(shutDownMsg)
  end

  local function drawStartupGUI()
    mon.setBackgroundColor(colours.blue)
    mon.setTextColor(colours.white)
    mon.clear()
    local startUpMsg = "Starting kMarx shop..."
    mon.setCursorPos(math.ceil((xm/ 2) - (startUpMsg:len() / 2)) + 1, ym / 2)
    mon.write(startUpMsg)
  end

  local function dCChar(rr)
    local cChar = "?"
    if rr <= 0 then cChar = "."
    elseif rr > 0 and rr <= .05 then cChar = ":"
    elseif rr > .05 and rr <= .1 then cChar = "-"
    elseif rr > .1 then cChar = "=" end
    mon.setBackgroundColour(shopData.layout.colours.footer.background)
    mon.setTextColour(shopData.layout.colours.footer.text)
    mon.setCursorPos(monMaxX, monMaxY)
    mon.write(cChar)
  end

  local redstoneHeartbeatStatus = false
  local function toggleRedstone()
    redstoneHeartbeatStatus = not redstoneHeartbeatStatus
    redstone.setOutput(shopData.config.redstoneside, redstoneHeartbeatStatus)
  end

  local wssuccess, ws
  local royaltyDestination = "kMarx.kst"
  local internalVersion = "0.4"
  local integerVersion = 4
  local updateFetch = "https://energetic.pw/computercraft/kmarx/assets/versioncheck"
  local privatekey

  if shopData.config.krist.iskristwalletformat then
    privatekey = k.toKristWalletFormat(shopData.config.krist.privatekey)
  else
    privatekey = shopData.config.krist.privatekey
  end

  local function notifyToUpdate()
    local headers = { [ "User-Agent" ] = "kMarx-client (v" .. internalVersion .. ")" }
    if http.checkURL("https://energetic.pw/computercraft/kmarx/assets/versioncheck") then
      local handle = http.get("https://energetic.pw/computercraft/kmarx/assets/versioncheck", headers)
      if handle == nil then
        printError("[warning] Could not check for updates.")
      else
        local rawResult = handle.readAll()
        handle.close()
        local result = {}
        local success = pcall(function() result = textutils.unserialize(rawResult) end)
        if not success or result == nil then
          printError("[warning] Could not check for updates.")
        else
          if result.status ~= nil and result.status == "success" then
            if result.versions.current.integerVersion == integerVersion then
              print("[info] Shop is up to date!")
            elseif result.versions.current.integerVersion ~= integerVersion then
              printError("[info] Shop version is outdated!")
              print("[info] Visit energetic.pw/kmarx")
            end
          else
            printError("[warning] Could not check for updates.")
          end
        end
      end
    else
      printError("[warning] Could not check for updates.")
    end
  end

  local function handleTransaction(data)
    local transaction = data.transaction
    local metadata = nil

    if transaction.to ~= shopData.config.krist.address then return end

    local success, error = pcall(function() metadata = k.parseMeta(transaction.metadata) end)

    if not success then
      printError("[error] could not parse metadata!!")
    elseif metadata ~= nil and metadata.name ~= nil and metadata.domain == shopData.config.krist.domainname then -- filter out only our shop payments

      if metadata.meta["return"] == nil then metadata.meta["return"] = transaction.from end
      if metadata.meta["username"] == nil then metadata.meta["username"] = transaction.from end

      if lookupTable[metadata.name] ~= nil then
        print("[info] Transaction to shop made! Received " .. transaction.value .. " from " .. transaction.from)
        if stockLevels[lookupTable[metadata.name].longname] > 0 then
          --we have stock - DISPENSE & REFUND THE CHANGE
          local amountToDispense = math.min( math.floor( transaction.value / shopData.stock[lookupTable[metadata.name].index].price ), stockLevels[lookupTable[metadata.name].longname])
          local amountToRefund = transaction.value - ( amountToDispense * shopData.stock[lookupTable[metadata.name].index].price )
          local amountToRoyalty = math.floor( ( transaction.value - amountToRefund ) * shopData.config.krist.royaltyrate )

          if amountToDispense == 0 then
            -- no items dispensed, because user underpaid, refunding
            print("[info] Underpaid, refunding customer")
            local success = await(k.makeTransaction, privatekey, metadata.meta["return"], amountToRefund, string.gsub(shopData.config.messages.underpaid, "{buyer}", metadata.meta.username))
            assert(success, "[warning] Couldn't refund customer!!")
          elseif amountToDispense > 0 then
            -- dispensing items for the user
            dispense(lookupTable[metadata.name].longname, amountToDispense)
            updateStock()

            if amountToRoyalty > 0 then
              local success = await(k.makeTransaction, privatekey, royaltyDestination, amountToRoyalty, "kMarx Royalties;" .. table.concat({ "iv=" .. internalVersion, "rr=" .. shopData.config.krist.royaltyrate, "so=" .. shopData.config.owner }, ";"))
              assert(success, "[warning] Could not pay royalties!")
            end

            if amountToRefund > 0 then
              -- items dispensed, returning overpay
              print("[info] Item has been dispensed, returning change")
              local success = await(k.makeTransaction, privatekey, metadata.meta["return"], amountToRefund, string.gsub(shopData.config.messages.overpaid, "{buyer}", metadata.meta.username))
              assert(success, "[warning] Couldn't refund customer!!")
            end
          end
        else
          -- we're out of stock - REFUND
          print("[info] We're out of stock, refunding customer")
          local success = await(k.makeTransaction, privatekey, metadata.meta["return"], transaction.value, string.gsub(shopData.config.messages.outofstock, "{buyer}", metadata.meta.username))
          assert(success, "[warning] Couldn't refund customer!!")
        end
      else
        -- we don't sell this item - REFUND
        print("[info] Unknown item, refunding customer")
        local success = await(k.makeTransaction, privatekey, metadata.meta["return"], transaction.value, string.gsub(shopData.config.messages.unknownitem, "{buyer}", metadata.meta.username))
        assert(success, "[warning] Couldn't refund customer!!")
      end
    end
  end

  jua.on("terminate", function()
    print("[stop] Terminating")
    drawShutdownGUI()
    local success = pcall(function() ws.close() end)
    if not success then
      printError("Warning: Could not close websocket. Rebooting is strongly recommended!")
    else
      print("[stop] Websocket succesfully closed.")
    end
    jua.stop()
    printError("[stop] Terminated.")
  end)

  local function openWebsocket()
    wssuccess, ws = await(k.connect, privatekey)
    if not wssuccess then
      error("Failed to connect to websocket! Please reboot and try again.")
    end

    local success = await(ws.subscribe, "ownTransactions", handleTransaction)
    if not success then
      error("Failed to subscribe to websocket! Please reboot and try again.")
    end

    print("[info] Connections to krist made!")
  end

  jua.go(function()
    term.setCursorPos(1,1)
    term.setBackgroundColor(colors.black)
    term.clear()

    term.setTextColor(colours.black)
    term.setBackgroundColor(colors.white)
    term.clearLine()
    print(" kMarx shop - energetic.pw/kmarx")
    term.clearLine()
    print(" Created by HydroNitrogen")
    term.clearLine()
    print(" version 0.4 - 2020-02-05")

    drawStartupGUI()

    term.setBackgroundColor(colors.black)
    term.setTextColor(colours.white)
    print("...")

    if shopData.iv == nil or shopData.iv < 2 then
      printError("[warning] Config file is outdated!")
      updateConfigTo2()
    end

    wrapChest()
    getStock()

    openWebsocket()

    print("[info] Drawing shop GUI")
    drawShopGui()

    jua.setInterval(updateStock, shopData.config.updatestockinterval)
    jua.setTimeout(function() dCChar(shopData.config.krist.royaltyrate) end, 30)
    jua.setInterval(toggleRedstone, 3)

    notifyToUpdate()
  end)
end)

local function centerWrite(t, text)
  local xm, xy = t.getSize()
  local x, y = t.getCursorPos()
  t.clearLine()
  t.setCursorPos(math.ceil((xm/ 2) - (text:len() / 2)) + 1, y)
  t.write(text)
end

local function displayError(error)
  local mon = peripheral.find("monitor")
  mon.setTextScale(1)
  local xm, ym = mon.getSize()
  if xm < 26 or ym < 10 then
    mon.setTextScale(.5)
    xm, xy = mon.getSize()
  end

  mon.setBackgroundColor(colours.white)
  mon.setTextScale(1)
  mon.clear()

  mon.setBackgroundColor(colours.red)
  mon.setTextColor(colours.white)
  mon.setCursorPos(1,1)
  mon.clearLine()
  mon.setCursorPos(1,2)
  centerWrite(mon, "MEDIC NEEDED!")
  mon.setCursorPos(1,3)
  centerWrite(mon, "Shop has stopped working!")
  mon.setCursorPos(1,4)
  mon.clearLine()

  mon.setBackgroundColor(colours.white)
  mon.setTextColor(colours.grey)
  mon.setCursorPos(1, math.floor(0.5 * ym))
  mon.write("Error details:")
  mon.setCursorPos(1, math.floor(0.5 * ym) + 1)
  mon.write(error)

  mon.setTextColor(colours.black)
  mon.setCursorPos(1, math.floor(0.9 * ym))
  centerWrite(mon, "Auto reboot in 15 seconds")
end

if not success then
  pcall(function() displayError(error) end)
  term.setTextColor(colours.white)
  term.setBackgroundColor(colours.black)
  term.setCursorPos(1,1)
  term.clear()
  printError("FATAL ERROR OF DEATH IN SHOP")
  printError("Shop stopped working.")
  printError("\nInformation about your error:")
  print(error)
  print("\nShop will reboot in 15 seconds!")
  os.sleep(15)
  os.reboot()
end

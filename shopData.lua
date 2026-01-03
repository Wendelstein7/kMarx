{
  ["iv"] = 4,
  ["config"] = {
    ["name"] = "My awesome shop",
    ["krist"] = {
      ["address"] = "k123456789",
      ["privatekey"] = "",
      ["iskristwalletformat"] = true,
      ["domainname"] = "kmarx",
      ["royaltyrate"] = 0
    },
    ["owner"] = "Someone",
    ["chestside"] = "bottom",
    ["dispensedirection"] = "north",
    ["updatestockinterval"] = 120,
    ["redstoneside"] = "top",
    ["messages"] = {
      ["overpaid"] = "message=Here is your change, {buyer}. Thanks for your purchase!",
      ["underpaid"] = "error=Here is a refund, {buyer}. You did not pay enough to receive any of the specified item.",
      ["outofstock"] = "error=Here is a refund, {buyer}. We currently do not have this item in stock. Sorry for the inconvenience.",
      ["unknownitem"] = "error=Here is a refund, {buyer}. We do not sell the item you specified."
    }
  },
  ["layout"] =
  {
    ["logo"] = {
      ["location"] = "/shopLogo.lua",
      ["verticalSize"] = 5
    },
    ["header"] = {
      ["text"] = { "Welcome to {shopname}! This is the best shop ever!", "This shop refunds wrong purchases and returns change automatically!"},
      ["indent"] = 1,
      ["spacing"] = 1
    },
    ["footer"] = {
      ["text"] = { "{shopname} is being run by {shopowner}.", "Please contact me ({shopowner}) if shop is out of stock.", "This shop is powered by a beta version of kMarx"},
      ["indent"] = 1,
      ["spacing"] = 1
    },
    ["table"] = {
      ["suffix"] = {
        ["currency"] = " kst",
        ["stock"] = " x",
        ["meta"] = "@{domainname}.kst"
      },
      ["columnname"] = {
        ["name"] = "Item",
        ["stock"] = "Stock",
        ["price"] = "Price",
        ["meta"] = "Krist destination"
      },
      ["size"] = {
        ["header"] = 3,
        ["row"] = 3,
        ["footer"] = 3
      }
    },
    ["visible"] = {
      ["logo"] = true,
      ["header"] = true,
      ["table"] = {
        ["header"] = true,
        ["content"] = true,
        ["footer"] = true
      },
      ["footer"] = true
    },
    ["colours"] = {
      ["empty"] = 2048,
      ["logo"] = {
        ["background"] = 2048
      },
      ["header"] = {
        ["text"] = 1,
        ["background"] = 2048
      },
      ["footer"] = {
        ["text"] = 1,
        ["background"] = 2048
      },
      ["table"] = {
        ["header"] = {
          ["row"] = 128,
          ["name"] = 1,
          ["stock"] = 1,
          ["price"] = 1,
          ["meta"] = 1
        },
        ["content"] = {
          ["row"] = { [0] = 1, [1] = 256 },
          ["name"] = { [0] = 32768, [1] = 32768 },
          ["stockfull"] = { [0] = 256, [1] = 128 },
          ["stockempty"] = { [0] = 16384, [1] = 16384 },
          ["price"] = { [0] = 32768, [1] = 32768 },
          ["meta"] = { [0] = 256, [1] = 128 }
        },
        ["footer"] = {
          ["row"] = 128,
          ["name"] = 1,
          ["stock"] = 1,
          ["price"] = 1,
          ["meta"] = 1
        }
      }
    },
    ["columnoffset"] = {
      ["name"] = .05,
      ["stock"] = .5,
      ["price"] = .65,
      ["meta"] = .8
    },
    ["credits"] = {
      ["forceVisible"] = true
    }
  },
  ["stock"] = {
    [0] = {
      ["name"] = "minecraft:gold_ingot",
      ["damage"] = 0,
      ["displayname"] = "Gold Ingot",
      ["meta"] = "gold",
      ["price"] = 2.5
    },
    [1] = {
      ["name"] = "computercraft:peripheral",
      ["damage"] = 2,
      ["displayname"] = "Basic Monitor",
      ["meta"] = "bmon",
      ["price"] = 5.0
    },
    [2] = {
      ["name"] = "computercraft:peripheral",
      ["damage"] = 1,
      ["displayname"] = "Wireless Modem",
      ["meta"] = "wmod",
      ["price"] = 10
    }
  }
}

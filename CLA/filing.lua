local digest = assert(arg[1], "usage: lua filing.lua <digest-hex>")
assert(#digest == 64 and digest:match("^%x+$"), "digest must be 64 hex characters")

local lib = assert(loadfile("lib.lua"))()
local secret = lib.load_env(".env").FILING_SECRET
assert(
  secret ~= nil and secret ~= "" and secret ~= "change-me-to-a-long-random-string",
  "FILING_SECRET is missing or still the placeholder"
)

print(lib.check_code(secret, digest:lower()))

local lib = {}

lib.level2 = {
  "Assembly",
  "Board",
  "Officer",
  "Secretariat",
}

lib.level3 = {
  "Council of (to) the Assembly",
  "Council of (to) the Board",
  "Executive Committee",
  "Technical (R&D) Committee",
  "Commission of Discipline",
  "Commission of Inquiry",
  "Functional Group",
  "Administrative Group",
  "Working Group",
  "Special Interest Group",
}

local function is_in(list, name)
  for _, v in ipairs(list) do
    if v == name then
      return true
    end
  end
  return false
end

function lib.is_unit(name)
  return is_in(lib.level2, name) or is_in(lib.level3, name)
end

lib.doc = {
  unit2 = "",
  unit3 = "",
  refno = "",
  date = "",
  verghash = "",
  email = "",
  platformid = "",
  sigdate = "",
  hmacsecret = "",
}

function lib.check_unit(name)
  return name == "" or lib.is_unit(name)
end

function lib.validate()
  if tex == nil then
    return true
  end
  if not lib.check_unit(lib.doc.unit2) then
    tex.error("Unknown Level-2 unit name")
  end
  if not lib.check_unit(lib.doc.unit3) then
    tex.error("Unknown Level-3 unit name")
  end
  return true
end

function lib.setup_barcode()
  lib.validate()
  if tex == nil then
    return true
  end
  if lib.check_ready() then
    local chk = lib.check_code(lib.doc.hmacsecret, lib.agreement_hex())
    tex.sprint(
      "\\runmetapost\\bcinst{beginfig(0);" .. lib.barcode_mp(chk, 0.4, 1.2, 7) .. "endfig;}"
    )
    tex.sprint("\\boxnextmpimage\\bcinst\\barcodebox ")
  end
  return true
end

local K = {
  0x428a2f98,
  0x71374491,
  0xb5c0fbcf,
  0xe9b5dba5,
  0x3956c25b,
  0x59f111f1,
  0x923f82a4,
  0xab1c5ed5,
  0xd807aa98,
  0x12835b01,
  0x243185be,
  0x550c7dc3,
  0x72be5d74,
  0x80deb1fe,
  0x9bdc06a7,
  0xc19bf174,
  0xe49b69c1,
  0xefbe4786,
  0x0fc19dc6,
  0x240ca1cc,
  0x2de92c6f,
  0x4a7484aa,
  0x5cb0a9dc,
  0x76f988da,
  0x983e5152,
  0xa831c66d,
  0xb00327c8,
  0xbf597fc7,
  0xc6e00bf3,
  0xd5a79147,
  0x06ca6351,
  0x14292967,
  0x27b70a85,
  0x2e1b2138,
  0x4d2c6dfc,
  0x53380d13,
  0x650a7354,
  0x766a0abb,
  0x81c2c92e,
  0x92722c85,
  0xa2bfe8a1,
  0xa81a664b,
  0xc24b8b70,
  0xc76c51a3,
  0xd192e819,
  0xd6990624,
  0xf40e3585,
  0x106aa070,
  0x19a4c116,
  0x1e376c08,
  0x2748774c,
  0x34b0bcb5,
  0x391c0cb3,
  0x4ed8aa4a,
  0x5b9cca4f,
  0x682e6ff3,
  0x748f82ee,
  0x78a5636f,
  0x84c87814,
  0x8cc70208,
  0x90befffa,
  0xa4506ceb,
  0xbef9a3f7,
  0xc67178f2,
}

local function rrot(x, n)
  return ((x >> n) | (x << (32 - n))) & 0xFFFFFFFF
end

function lib.sha256_words(msg)
  local H = {
    0x6a09e667,
    0xbb67ae85,
    0x3c6ef372,
    0xa54ff53a,
    0x510e527f,
    0x9b05688c,
    0x1f83d9ab,
    0x5be0cd19,
  }
  local ml = #msg
  msg = msg .. "\x80"
  while (#msg % 64) ~= 56 do
    msg = msg .. "\x00"
  end
  local hi = 0
  local lo = (ml * 8) & 0xFFFFFFFF
  msg = msg .. string.pack(">I4>I4", hi, lo)
  local W = {}
  for b = 1, #msg, 64 do
    for i = 0, 15 do
      local o = b + i * 4
      W[i + 1] = string.unpack(">I4", msg, o)
    end
    for i = 17, 64 do
      local x, y = W[i - 15], W[i - 2]
      local s0 = (rrot(x, 7) ~ rrot(x, 18) ~ (x >> 3)) & 0xFFFFFFFF
      local s1 = (rrot(y, 17) ~ rrot(y, 19) ~ (y >> 10)) & 0xFFFFFFFF
      W[i] = (W[i - 16] + s0 + W[i - 7] + s1) & 0xFFFFFFFF
    end
    local a, c, d, e, f, g, h
    local bb
    a, bb, c, d, e, f, g, h = H[1], H[2], H[3], H[4], H[5], H[6], H[7], H[8]
    for i = 1, 64 do
      local S1 = (rrot(e, 6) ~ rrot(e, 11) ~ rrot(e, 25)) & 0xFFFFFFFF
      local ch = ((e & f) ~ (~e & g)) & 0xFFFFFFFF
      local t1 = (h + S1 + ch + K[i] + W[i]) & 0xFFFFFFFF
      local S0 = (rrot(a, 2) ~ rrot(a, 13) ~ rrot(a, 22)) & 0xFFFFFFFF
      local mj = ((a & bb) ~ (a & c) ~ (bb & c)) & 0xFFFFFFFF
      local t2 = (S0 + mj) & 0xFFFFFFFF
      h, g, f, e, d, c, bb, a = g, f, e, (d + t1) & 0xFFFFFFFF, c, bb, a, (t1 + t2) & 0xFFFFFFFF
    end
    H[1] = (H[1] + a) & 0xFFFFFFFF
    H[2] = (H[2] + bb) & 0xFFFFFFFF
    H[3] = (H[3] + c) & 0xFFFFFFFF
    H[4] = (H[4] + d) & 0xFFFFFFFF
    H[5] = (H[5] + e) & 0xFFFFFFFF
    H[6] = (H[6] + f) & 0xFFFFFFFF
    H[7] = (H[7] + g) & 0xFFFFFFFF
    H[8] = (H[8] + h) & 0xFFFFFFFF
  end
  return H
end

local function hexwords(H)
  return string.format("%08x%08x%08x%08x%08x%08x%08x%08x", table.unpack(H))
end

local PACK8 = string.rep(">I4", 8)

function lib.sha256_bytes(msg)
  return string.pack(PACK8, table.unpack(lib.sha256_words(msg)))
end

function lib.sha256_hex(msg)
  return hexwords(lib.sha256_words(msg))
end

local function hmac_words(key, msg)
  if #key > 64 then
    key = lib.sha256_bytes(key)
  end
  key = key .. string.rep("\0", 64 - #key)
  local ipad, opad = {}, {}
  for i = 1, 64 do
    local c = key:sub(i, i):byte()
    ipad[i] = string.char(c ~ 0x36)
    opad[i] = string.char(c ~ 0x5C)
  end
  local inner = lib.sha256_bytes(table.concat(ipad) .. msg)
  return lib.sha256_words(table.concat(opad) .. inner)
end

function lib.hmac_sha256_bytes(key, msg)
  return string.pack(PACK8, table.unpack(hmac_words(key, msg)))
end

function lib.hmac_sha256_hex(key, msg)
  return hexwords(hmac_words(key, msg))
end

lib.crockford = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"

function lib.crockford13(bytes8)
  assert(#bytes8 == 8, "crockford13 needs exactly 8 bytes")
  local hi, lo = string.unpack(">I4>I4", bytes8)
  local g = {
    hi >> 27,
    (hi >> 22) & 31,
    (hi >> 17) & 31,
    (hi >> 12) & 31,
    (hi >> 7) & 31,
    (hi >> 2) & 31,
    ((hi & 3) << 3) | (lo >> 29),
    (lo >> 24) & 31,
    (lo >> 19) & 31,
    (lo >> 14) & 31,
    (lo >> 9) & 31,
    (lo >> 4) & 31,
    (lo & 15) << 1,
  }
  local out = {}
  for i = 1, 13 do
    out[i] = lib.crockford:sub(g[i] + 1, g[i] + 1)
  end
  return table.concat(out)
end

function lib.check_code(secret, digest_hex)
  local mac = lib.hmac_sha256_bytes(secret, digest_hex)
  local c13 = lib.crockford13(mac:sub(1, 8))
  return c13:sub(1, 5) .. "-" .. c13:sub(6, 10) .. "-" .. c13:sub(11, 13)
end

function lib.agreement_hex()
  local d = lib.doc
  return lib.sha256_hex(d.verghash .. d.email .. d.platformid .. d.sigdate)
end

function lib.agreement_complete()
  local d = lib.doc
  return d.email ~= "" and d.platformid ~= "" and d.sigdate ~= ""
end

function lib.check_ready()
  return lib.agreement_complete() and lib.doc.hmacsecret ~= ""
end

lib.code39 = {
  ["0"] = "nnnwwnwnn",
  ["1"] = "wnnwnnnnw",
  ["2"] = "nnwwnnnnw",
  ["3"] = "wnwwnnnnn",
  ["4"] = "nnnwwnnnw",
  ["5"] = "wnnwwnnnn",
  ["6"] = "nnwwwnnnn",
  ["7"] = "nnnwnnwnw",
  ["8"] = "wnnwnnwnn",
  ["9"] = "nnwwnnwnn",
  ["A"] = "wnnnnwnnw",
  ["B"] = "nnwnnwnnw",
  ["C"] = "wnwnnwnnn",
  ["D"] = "nnnnwwnnw",
  ["E"] = "wnnnwwnnn",
  ["F"] = "nnwnwwnnn",
  ["G"] = "nnnnnwwnw",
  ["H"] = "wnnnnwwnn",
  ["I"] = "nnwnnwwnn",
  ["J"] = "nnnnwwwnn",
  ["K"] = "wnnnnnnww",
  ["L"] = "nnwnnnnww",
  ["M"] = "wnwnnnnwn",
  ["N"] = "nnnnwnnww",
  ["O"] = "wnnnwnnwn",
  ["P"] = "nnwnwnnwn",
  ["Q"] = "nnnnnnwww",
  ["R"] = "wnnnnnwwn",
  ["S"] = "nnwnnnwwn",
  ["T"] = "nnnnwnwwn",
  ["U"] = "wwnnnnnnw",
  ["V"] = "nwwnnnnnw",
  ["W"] = "wwwnnnnnn",
  ["X"] = "nwnnwnnnw",
  ["Y"] = "wwnnwnnnn",
  ["Z"] = "nwwnwnnnn",
  ["-"] = "nwnnnnwnw",
  ["."] = "wwnnnnwnn",
  [" "] = "nwwnnnwnn",
  ["$"] = "nwnwnwnnn",
  ["/"] = "nwnwnnnwn",
  ["+"] = "wnnnnwnwn",
  ["%"] = "nnnwnwnwn",
  ["*"] = "wnnnwnwnn",
}

function lib.barcode_mp(payload, narrow, wide, height)
  local parts = {}
  local x = narrow * 10
  local function bar(w)
    parts[#parts + 1] = string.format(
      "fill unitsquare xscaled %.3fmm yscaled %.3fmm shifted (%.3fmm,0);",
      w,
      height,
      x
    )
    x = x + w
  end
  local function gap(w)
    x = x + w
  end
  local msg = "*" .. payload .. "*"
  for i = 1, #msg do
    local pat = lib.code39[msg:sub(i, i)]
    if pat then
      for j = 1, 9 do
        local w = (pat:sub(j, j) == "w") and wide or narrow
        if j % 2 == 1 then
          bar(w)
        else
          gap(w)
        end
      end
      gap(narrow)
    end
  end
  return table.concat(parts)
end

function lib.selftest()
  assert(
    lib.sha256_hex("abc") == "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad",
    "SHA-256 of abc"
  )
  assert(
    lib.sha256_hex("") == "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
    "SHA-256 of the empty string"
  )
  local k1 = string.rep("\11", 20)
  assert(
    lib.hmac_sha256_hex(k1, "Hi There")
      == "b0344c61d8db38535ca8afceaf0bf12b881dc200c9833da726e9376c2e32cff7",
    "HMAC-SHA-256 RFC 4231 case 1"
  )
  assert(
    lib.hmac_sha256_hex("Jefe", "what do ya want for nothing?")
      == "5bdcc146bf60754e6a042426089575c75a003f089d2739839dec58b964ec3843",
    "HMAC-SHA-256 RFC 4231 case 2"
  )
  assert(
    lib.crockford13(string.rep("\0", 8)) == "0000000000000",
    "Crockford encoding of zero bytes"
  )
  assert(
    lib.crockford13(string.rep("\255", 8)) == "ZZZZZZZZZZZZY",
    "Crockford encoding of 0xFF bytes"
  )
  local cc = lib.check_code("test-secret", lib.sha256_hex("abc"))
  assert(
    #cc == 15
      and cc:match(
          "^[0-9A-Z][0-9A-Z][0-9A-Z][0-9A-Z][0-9A-Z]%-[0-9A-Z][0-9A-Z][0-9A-Z][0-9A-Z][0-9A-Z]%-[0-9A-Z][0-9A-Z][0-9A-Z]$"
        )
        ~= nil,
    "check code is not in 5-5-3 form"
  )
  assert(cc:find("[ILOU]") == nil, "check code contains ambiguous characters")
  return true
end

if tex ~= nil then
  function cla_emit_unit()
    local function line(u)
      u = u:gsub("&", "\\&")
      tex.sprint("\\hbox{\\bf\\relax " .. u .. "}")
    end
    local d = lib.doc
    if d.unit2 ~= "" then
      line(d.unit2)
    end
    if d.unit3 ~= "" then
      line(d.unit3)
    end
  end

  local function digest_footer(hex, third)
    return "\\vbox{\\baselineskip=9pt"
      .. "\\hbox{\\monofoot\\relax "
      .. hex:sub(1, 32)
      .. "}"
      .. "\\hbox{\\monofoot\\relax "
      .. hex:sub(33, 64)
      .. "}"
      .. third
      .. "}"
  end

  function cla_emit_footer_left()
    if lib.check_ready() then
      local hex = lib.agreement_hex()
      local chk = lib.check_code(lib.doc.hmacsecret, hex)
      tex.sprint(
        digest_footer(
          hex,
          "\\hbox{\\monofoot\\relax CHECK: " .. chk .. "}" .. "\\hbox{\\copy\\barcodebox}"
        )
      )
    elseif lib.agreement_complete() then
      tex.sprint(
        digest_footer(
          lib.agreement_hex(),
          "\\hbox{\\monofoot\\relax CHECK CODE: GENERATED AT FILING}"
        )
      )
    else
      tex.sprint(
        "\\vbox{\\baselineskip=9pt\\hsize=120mm\\noindent{\\rmfoot\\relax Unsigned copy. Barcode and check code are generated at filing.}\\par"
      )
      tex.sprint(
        "\\noindent{\\rmfoot\\relax SHA-256 (version-hash\\textbar email\\textbar platform-ID\\textbar date).}\\par}"
      )
    end
  end

  function cla_schedrow(i)
    local r = "Row " .. i .. ":"
    tex.sprint("\\formrow{" .. r .. " Name:}{CCLA_sched" .. i .. "_name}")
    tex.sprint("\\formrow{" .. r .. " Email:}{CCLA_sched" .. i .. "_email}")
    tex.sprint(
      "\\formrowtwo{"
        .. r
        .. " Platform IDs:}{CCLA_sched"
        .. i
        .. "_ids}"
        .. "{"
        .. r
        .. " Valid from:}{CCLA_sched"
        .. i
        .. "_from}"
    )
  end
end

local BP_PER_MM = 72 / 25.4

lib.field_h_mm = 10 + 25.4 / 72.27
lib.field_w_full_mm = 160
lib.field_w_half_mm = 76

function lib.appearance_content(w_mm, h_mm)
  local w_bp = w_mm * BP_PER_MM
  local h_bp = h_mm * BP_PER_MM
  local hbw = 0.5 / h_bp
  local vbw = 0.5 / w_bp
  local function f(x)
    return string.format("%.6f", x)
  end
  local body = table.concat({
    "1 1 1 rg 0 0 1 1 re f",
    "0.45 0.45 0.45 rg",
    "0 0 1 " .. f(hbw) .. " re f",
    "0 " .. f(1 - hbw) .. " 1 " .. f(hbw) .. " re f",
    "0 0 " .. f(vbw) .. " 1 re f",
    f(1 - vbw) .. " 0 " .. f(vbw) .. " 1 re f",
  }, "\n")
  return body, f(w_bp), f(h_bp)
end

function lib.make_appearance(w_mm, h_mm)
  local body, w, h = lib.appearance_content(w_mm, h_mm)
  return pdf.obj({
    type = "stream",
    string = body,
    attr = "/Type /XObject /Subtype /Form"
      .. " /BBox [0 0 1 1] /Matrix ["
      .. w
      .. " 0 0 "
      .. h
      .. " 0 0]"
      .. " /Resources << >>",
    immediate = true,
  })
end

if tex ~= nil then
  function cla_make_appearances()
    local full = lib.make_appearance(lib.field_w_full_mm, lib.field_h_mm)
    local half = lib.make_appearance(lib.field_w_half_mm, lib.field_h_mm)
    tex.sprint("\\def\\apfullnum{" .. full .. "}")
    tex.sprint("\\def\\aphalfnum{" .. half .. "}")
  end
end

if tex == nil then
  function lib.load_env(path)
    local env = {}
    local f = assert(io.open(path, "r"), "missing " .. path)
    for line in f:lines() do
      local k, v = line:match("^%s*([A-Za-z_][A-Za-z0-9_]*)%s*=%s*(.-)%s*$")
      if k and not line:match("^%s*#") then
        env[k] = v
      end
    end
    f:close()
    return env
  end

  function lib.read_all(path)
    local f = assert(io.open(path, "rb"), "missing " .. path)
    local s = f:read("a")
    f:close()
    return s
  end

  function lib.run(cmd, loud)
    if loud then
      print("+ " .. cmd)
    end
    local ok = os.execute(cmd)
    assert(ok == true or ok == 0, "command failed: " .. cmd)
  end
end

return lib

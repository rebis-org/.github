local WIDGETS = { CCLA = 18, ICLA = 6 }

local job = arg and arg[1]
assert(job ~= nil and WIDGETS[job] ~= nil, "usage: lua verify.lua <CCLA|ICLA>")

local lib = assert(loadfile("lib.lua"))()
assert(lib.selftest())
print("lib OK")

local QPDF = os.getenv("QPDF") or "qpdf"

local pdf = lib.read_all(job .. ".pdf")
assert(pdf:sub(1, 5) == "%PDF-", job .. ".pdf is not a PDF")
assert(
  pdf:find(string.rep("V", 64), 1, true) == nil,
  job .. ".pdf still carries the unstamped placeholder"
)

lib.run(QPDF .. " --qdf --object-streams=disable " .. job .. ".pdf " .. job .. "-qdf.tmp.pdf", true)
local expanded = lib.read_all(job .. "-qdf.tmp.pdf")
os.remove(job .. "-qdf.tmp.pdf")
assert(expanded:find("/AcroForm", 1, true) ~= nil, job .. ".pdf lacks an AcroForm dictionary")

local function count(pat)
  local n = 0
  for _ in expanded:gmatch(pat) do
    n = n + 1
  end
  return n
end
local w = count("/Subtype /Widget")
print(job .. ".pdf widgets: " .. w)
assert(w == WIDGETS[job], job .. ".pdf widget count is not " .. WIDGETS[job])
local ap = count("/AP%s+<<%s+/N%s+%d+%s+0%s+R%s*>>")
print(job .. ".pdf appearances: " .. ap)
assert(ap == w, job .. ".pdf appearance count is not " .. w)

local bangs = 0
for line in io.lines(job .. ".log") do
  if line:sub(1, 1) == "!" then
    bangs = bangs + 1
  end
end
print(job .. ".log bang lines: " .. bangs)
assert(bangs == 0, job .. ".log contains TeX errors")

lib.run(QPDF .. " --check " .. job .. ".pdf", true)
print("VERIFY OK: " .. job .. ".pdf")

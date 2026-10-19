import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import { LuauState } from 'luau-web';
const root = path.resolve(import.meta.dirname, '..');
const state = await LuauState.createAsync();
function files(dir) {
  return fs.readdirSync(dir, {withFileTypes:true}).flatMap(e => e.isDirectory() ? files(path.join(dir,e.name)) : e.name.endsWith('.lua') ? [path.join(dir,e.name)] : []);
}
let compiled = 0;
try {
  for (const file of files(path.join(root,'src'))) {
    state.loadstring(fs.readFileSync(file,'utf8'), path.relative(root,file), true);
    compiled++;
  }
  console.log(`PASS: ${compiled} Luau sources compile (syntax only, not type analysis).`);
  const sources = {};
  for (const name of ['EconomyConfig','SeasonConfig','PlantConfig']) sources[name] = fs.readFileSync(path.join(root,`src/shared/Config/${name}.lua`),'utf8');
  sources.Types = 'return {}';
  sources.TokenBucket = fs.readFileSync(path.join(root,'src/shared/Modules/TokenBucket.lua'),'utf8');
  sources.RemoteValidator = fs.readFileSync(path.join(root,'src/server/AntiCheat/RemoteValidator.lua'),'utf8');
  for (const name of ['DataSchema','EconomyService','PlantService','FusionService','QuestService','SeasonPassService','WorldService']) sources[name] = fs.readFileSync(path.join(root,`src/server/Services/${name}.lua`),'utf8');
  // Actual production source is executed under minimal in-memory Roblox service doubles.
  const prelude = `
local modules, loaded = {}, {}
local clock = 1792400000
local nativeOs = os
local os = { time = function() return clock end, clock = nativeOs.clock }
local Color3 = { fromRGB = function(r,g,b) return {r,g,b} end }
local Shared = { Config = { EconomyConfig="EconomyConfig", SeasonConfig="SeasonConfig", PlantConfig="PlantConfig" }, Types="Types" }
local script = { Parent = { Parent = { Types="Types" } } }
for _, name in {"DataService","EconomyService","PlotService","PlantService","QuestService"} do script.Parent[name]=name end
local counter = 0
local lighting = {}
local game = { GetService = function(_, name)
 if name == "ReplicatedStorage" then return {Shared=Shared} end
 if name == "Lighting" then return lighting end
 if name == "HttpService" then return {GenerateGUID=function() counter+=1 return "crop-"..counter end} end
 error("unexpected service "..name)
end }
local function require(name)
 if loaded[name] == nil then loaded[name] = modules[name]() end
 return loaded[name]
end
`;
  let program = prelude;
  for (const [name, source] of Object.entries(sources)) program += `\nmodules[${JSON.stringify(name)}] = function()\n${source}\nend\n`;
  program += `
local player = { FindFirstChild=function() return nil end }
local function fresh()
 return { Version=1, Coins=100, Gems=0, Seeds={}, Crops={}, Slots={}, Collection={}, CollectionRewards={}, LastSeen=0,
 LastDaily=-1, Streak=0, QuestDay=-1, Quests={}, QuestClaims={}, SeasonId=-1, XP=0, SeasonClaims={},
 ShieldUntil=0, LastSteal=0, Harvests=0, Steals=0, Fusions=0, Ledger={}, TutorialDone=false }
end
local data = fresh()
modules.DataService = function() return {Get=function(p) return if p==player then data else nil end} end
local near = true
modules.PlotService = function() return {Id=function() return 1 end, Near=function() return near end} end
local limiter = require("TokenBucket")
local bucket = limiter.New(12,0)
local accepted = 0
for i=1,1000 do if limiter.Take(bucket,12,4,0) then accepted+=1 end end
assert(accepted==12)
assert(not limiter.Take(bucket,12,4,0.24))
assert(limiter.Take(bucket,12,4,0.25))
assert(not limiter.Take(bucket,12,4,0.25))
local validator = require("RemoteValidator")
assert(validator.Parse("Buy:sprout")[2]=="sprout")
assert(validator.Parse("Plant:sprout:1")[3]=="1")
assert(validator.Parse("GiveCoins:999999")==nil)
assert(validator.Parse("Buy:sprout:extra")==nil)
assert(validator.Parse("Buy:")==nil)
assert(validator.Parse("Buy:sprout\\n")==nil)
assert(validator.Integer("nan")==nil and validator.Integer("1e3")==nil and validator.Integer("-1")==nil)
assert(validator.Integer("2")==2)
local schema=require("DataSchema")
assert(schema.Validate(data))
data.Coins=0/0 assert(not schema.Validate(data)) data.Coins=100
data.Seeds.fake=1 assert(not schema.Validate(data)) data.Seeds.fake=nil
data.Slots["99"]={PlantId="sprout",PlantedAt=clock} assert(not schema.Validate(data)) data.Slots={}
data.Crops={{Id="a",PlantId="sprout",Mutant=false},{Id="a",PlantId="sprout",Mutant=false}} assert(not schema.Validate(data)) data.Crops={}
data.QuestDay="bad" assert(not schema.Validate(data)) data.QuestDay=-1
local economy=require("EconomyService")
assert(not economy.Change(player,-101,"test") and data.Coins==100)
assert(not economy.Change(player,math.huge,"test"))
assert(not economy.Change(player,0/0,"test"))
assert(not economy.Change(player,0.5,"test"))
assert(economy.Change(player,10,"test") and data.Coins==110)
for i=1,110 do assert(economy.Change(player,1,"test")) end
assert(#data.Ledger==100)
data=fresh()
local plant=require("PlantService")
assert(not plant.Buy(player,"forged"))
assert(plant.Buy(player,"sprout") and data.Coins==90 and data.Seeds.sprout==1)
assert(not plant.Plant(player,"sprout",9))
near=false assert(not plant.Plant(player,"sprout",1)) near=true
assert(plant.Plant(player,"sprout",1) and data.Seeds.sprout==0)
assert(not plant.Plant(player,"sprout",1))
assert(not plant.Harvest(player,1) and #data.Crops==0)
clock+=10 assert(plant.Harvest(player,1) and #data.Crops==1 and data.Slots["1"]==nil)
assert(not plant.Harvest(player,1))
assert(data.Collection.sprout and data.Harvests==1)
local id=data.Crops[1].Id
assert(not plant.Sell(player,"forged"))
assert(plant.Sell(player,id) and data.Coins==105 and #data.Crops==0)
assert(not plant.Sell(player,id))
-- Growth requires no online ticking: time elapsed across an offline interval is enough.
data.Seeds.sprout=1 assert(plant.Plant(player,"sprout",1)) clock+=86400 assert(plant.Harvest(player,1))
local fusion=require("FusionService")
assert(not fusion.Fuse(player,"sprout"))
data.Crops={{Id="a",PlantId="sprout",Mutant=false},{Id="b",PlantId="sprout",Mutant=false},{Id="c",PlantId="sprout",Mutant=false}}
data.Coins=99 assert(not fusion.Fuse(player,"sprout") and #data.Crops==3)
data.Coins=100 assert(fusion.Fuse(player,"sprout") and #data.Crops==1 and data.Crops[1].Mutant and data.Coins==0)
assert(plant.Sell(player,data.Crops[1].Id) and data.Coins==30)
local quest=require("QuestService")
assert(quest.Daily(player)) local first=data.Coins assert(not quest.Daily(player) and data.Coins==first)
clock+=86400 assert(quest.Daily(player) and data.Streak==2)
clock+=172800 assert(quest.Daily(player) and data.Streak==1)
assert(not quest.Claim(player,"Harvest"))
for i=1,10 do quest.Progress(player,"Harvest") end
assert(quest.Claim(player,"Harvest")) assert(not quest.Claim(player,"Harvest"))
local season=require("SeasonPassService")
season.Refresh(player) data.XP=100
assert(not season.Claim(player,0)) assert(not season.Claim(player,51))
assert(season.Claim(player,1)) assert(not season.Claim(player,1))
clock+=30*86400 season.Refresh(player) assert(data.XP==0 and next(data.SeasonClaims)==nil)
assert(schema.Validate(data))
local world=require("WorldService")
clock=1800*100 assert(not world.IsNight() and world.Remaining()==1500)
clock+=1499 assert(not world.IsNight() and world.Remaining()==1)
clock+=1 assert(world.IsNight() and world.Remaining()==300)
clock+=300 assert(not world.IsNight())
return true
`;
  const result = await state.loadstring(program,'behavior-tests',true)();
  assert.equal(result[0],true);
  console.log('PASS: production validator/schema/economy/plant/fusion/daily/quest/season/world behavior assertions.');
} finally { state.destroy(); }

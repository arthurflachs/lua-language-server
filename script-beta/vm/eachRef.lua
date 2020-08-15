local vm     = require 'vm.vm'
local guide  = require 'parser.guide'
local util   = require 'utility'

local function eachRef(source, results)
    results = results or {}
    local lock = vm.lock('eachDef', source)
    if not lock then
        return results
    end

    local myResults, count = guide.requestReference(source, vm.interface)
    if DEVELOP and count > 10 then
        log.warn('requestReference', count, util.dump(source, { deep = 0 }))
    end
    vm.mergeResults(results, myResults)

    lock()

    return results
end

function vm.getRefs(source)
    local cache = vm.getCache('eachRef')[source] or eachRef(source)
    vm.getCache('eachDef')[source] = cache
    return cache
end

function vm.eachRef(source, callback)
    local results = vm.getRefs(source)
    for i = 1, #results do
        callback(results[i])
    end
end

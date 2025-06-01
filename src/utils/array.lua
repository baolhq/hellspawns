local array = {}

function array.contains(arr, pos)
    for _, v in ipairs(arr) do
        if v == pos then return true end
    end
    return false
end

return array

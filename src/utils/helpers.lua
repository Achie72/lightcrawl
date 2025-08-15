local color = require "src.utils.color"
local helpers = {}

---@param value: any atomic value or object
---@param set: a collection of items, iterable by ipairs()
---@return boolean True: if value matches any items in set
function helpers.is_value_in_set(value, set)
    for _,element in ipairs(set) do
        if value == element then
            return true
        end
    end
    return false
end

---@param collection: an indexable collection of values to choose from
---@return element: choosen element from the collection
function helpers.random_element_from(collection)
    local collection_lenght = #collection
    local fetch_index = math.random(1, collection_lenght)
    return collection[fetch_index]
end

---Select a random element from the collection, where elements are "weighted"
---@param collection table: a collection of elements from where we choose one
---@param weights table: a collection of integer weights corresponding to the collection elements
---@return element: a random element from the table.
function helpers.random_weighted_element_from(collection, weights)
    local weighthed_collection = {}
    for i=1,#collection do
        for j=1,weights[i] do
            table.insert(weighthed_collection, collection[i])
        end
    end
    return helpers.random_element_from(weighthed_collection)
end

---Merge two tables together. Table_1 then entries from table_2
---@param table_1 table
---@param table_2 table
---@return table: merged data with elements from table_1 first
function helpers.table_concat(table_1, table_2)
    local return_table = {}
    local len = #table_1
    
    for i=1,#table_1 do
        return_table[i] = table_1[i]
    end
    for i=1,#table_2 do
        return_table[len+i] = table_2[i]
    end
    return return_table
end


function helpers.collide(a, b)
	if (a.collisionWidth == nil) then a.collisionWidth = 8 end
	if (a.collisionHeigth == nil) then a.collisionHeigth = 8 end
	if (b.collisionWidth == nil) then b.collisionWidth = 8 end
	if (b.collisionHeigth == nil) then b.collisionHeigth = 8 end

	local aLeft = a.x
	local aTop = a.y
	local aRigth = a.x+a.collisionWidth-1
	local aBottom = a.y+a.collisionHeigth-1

	local bLeft = b.x
	local bTop = b.y
	local bRigth = b.x+b.collisionWidth-1
	local bBottom = b.y+b.collisionHeigth-1

	if (aTop > bBottom) then return false end
	if (bTop > aBottom) then return false end
	if (aLeft > bRigth) then return false end
	if (bLeft > aRigth) then return false end

	return true
end

---comment Draw an image followed by text
---@param icon Drawable: Image to draw
---@param icon_width number: width of image
---@param text string: text to draw after iomage
---@param x number: x position
---@param y number: y position
---@param clr RGBColor | number: Color of the text
function helpers.draw_icon_with_text(icon, icon_width, text, x, y, clr)
    love.graphics.draw(icon, x, y)
	color.set(clr)
	love.graphics.print(text, _G.font, x+icon_width, y+1)
	color.reset()
end

function helpers.print_outline(text, x, y, clr, thickness, border_color)
    if thickness == nil then thickness = 1 end
    if border_color == nil then border_color = color.PICO_DARK_BLUE end

    color.set(border_color)
    for i=-thickness,thickness do
        for j=-thickness,thickness do
            love.graphics.print(text, _G.font, x+i, y+j)
        end
    end
    color.set(clr)
    love.graphics.print(text, _G.font, x, y)
    color.reset()
end

function helpers.remove_element_from_table(tbl, element)
    for i=#tbl,1,-1 do
        local elem = tbl[i]
        if elem == element then
            table.remove(tbl, i)
            break
        end
    end
end

function helpers.text_lenght(text)
	return _G.font:getWidth(text)
end

return helpers
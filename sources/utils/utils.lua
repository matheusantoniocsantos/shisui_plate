screen = Vector2 (guiGetScreenSize ())
screenBase = Vector2 (1366, 768)

local textures = {image = {}, font = {}}

function setScreenPosition (x, y, w, h)
    local x, y, w, h = math.ceil (x), math.ceil (y), math.ceil (w), math.ceil (h)
    return (
        (x / screenBase.x) * screen.x),
        ((y / screenBase.y) * screen.y),
        ((w / screenBase.x) * screen.x),
        ((h / screenBase.y) * screen.y
    )
end;

_dxDrawRectangle = dxDrawRectangle
dxDrawRectangle = function (x, y, w, h, ...)
    if (not x or not y or not w or not h) then
        return false;
    end;
    local x, y, w, h = setScreenPosition (x, y, w, h);
    return _dxDrawRectangle (x, y, w, h, ...);
end;

_dxDrawImage = dxDrawImage
dxDrawImage = function (x, y, w, h, path, ...)
    if (not x or not y or not w or not h) then
        return false;
    end;
    if (type (path) == 'string') then
        if (not textures['image'][path]) then
            textures['image'][path] = dxCreateTexture (path, 'argb', false, 'clamp');
        end;
        path = textures['image'][path];
    end;
    local x, y, w, h = setScreenPosition (x, y, w, h);
    return _dxDrawImage (x, y, w, h, path, ...);
end;

_dxDrawText = dxDrawText
dxDrawText = function (text, x, y, w, h, ...)
    if (not text or not x or not y or not w or not h) then
        return false;
    end;
    local x, y, w, h = setScreenPosition (x, y, w, h);
    return _dxDrawText (text, x, y, (x + w), (y + h), ...)
end;

_dxDrawLine = dxDrawLine
dxDrawLine = function (x, y, w, h, ...)
    local x, y, w, h = setScreenPosition (x, y, w, h);
    return _dxDrawLine (x, y, w, h, ...);
end;

_dxCreateFont = dxCreateFont
dxCreateFont = function (path, size, ...)
    local _, scale, _, _ = setScreenPosition (0, size, 0, 0)

    if (not textures['font'][path]) then
        textures['font'][path] = {};
    end;
    if (not textures['font'][path][size]) then
        textures['font'][path][size] = _dxCreateFont (path, scale, ...);
    end;
    return textures['font'][path][size];
end;

_dxDrawImageSection = dxDrawImageSection
dxDrawImageSection = function (x, y, w, h, ...)
    local x, y, w, h = setScreenPosition (x, y, w, h)
    return _dxDrawImageSection (x, y, w, h, ...)
end;

function isCursorOnElement (x, y, w, h)
    if (not isCursorShowing()) then
        return false
    end
    local mx, my = getCursorPosition()
    local fullx, fully = guiGetScreenSize()
    local cursorx, cursory = mx*fullx, my*fully
    if cursorx > x and cursorx < x + w and cursory > y and cursory < y + h then
        return true
    else
        return false
    end
end

local fonts = {}
function loadFont(path, size)
    if not (path) then return end
    if not (size) then return end

    local formateVariable = path..'-'..size
    if (fonts[formateVariable]) then
        return fonts[formateVariable]
    end

    fonts[formateVariable] = dxCreateFont('assets/fonts/'..path..'.ttf', size)
    return fonts[formateVariable]
end

function placeFolder(image)
    return 'assets/images/'..image..'.png'
end


local editbox = {
    actual = false;
    events = false;
    elements = { };
    selected = false;
}

createEditBox = function (identify, x, y, width, height, options, postGUI)
    local postGUI = postGUI or false

    if not editbox.elements[identify] then
        editbox.elements[identify] = {
            text = '';
            position = {x, y, width, height};
            options = {
                using = options.using;
                font = options.font or 'default';
                masked = options.masked or false;
                onlynumber = options.onlynumber or false;
                textalign = options.textalign or 'center';
                maxcharacters = options.maxcharacters or 32;
                othertext = options.othertext or 'Digite aqui';
                cache_othertext = options.othertext or 'Digite aqui';
                text = options.text; 
                selected = options.selected;
            };
            manager = {
                tick;
            };
        }

        if next (editbox.elements) and not editbox.events then
            addEventHandler ('onClientKey', root, onClientKeyEditBox)
            addEventHandler ('onClientClick', root, onClientClickEditBox)
            addEventHandler ('onClientPaste', root, onClientPasteEditBox)
            addEventHandler ('onClientCharacter', root, onClientCharacterEditBox)
            editbox.events = true
        end
    else
        local v = editbox.elements[identify]
        local x, y, width, height = unpack (v.position)

        v.text = tostring (v.text)

        local text = (#v.text ~= 0 and v.options.masked and string.gsub (v.text, '.', '*') or #v.text == 0 and v.options.othertext or v.text)
        local textWidth = dxGetTextWidth (text, 1.5, v.options.font) or 0

        dxDrawText (text, x, y, width, height, tocolor (unpack (v.options.text)), 1, v.options.font, v.options.textalign, 'center', (textWidth > width), false, postGUI)

        if v.options.using then
            if editbox.selected ~= nil and editbox.selected == identify then
               dxDrawRectangle (x, y + 0.5, (textWidth > width and width or textWidth), height - 5, tocolor (unpack (v.options.selected)), postGUI)
            end
            if v.manager.tick ~= nil and (getTickCount () >= v.manager.tick + 150) then
                v.text = string.sub (v.text, 1, math.max (#v.text - 1), 0)
            end
        end
    end
end

function dxDestroyAllEditBox ()
    if not next (editbox.elements) then
        return false
    end
    editbox.elements = { }
    editbox.actual = false
    editbox.selected = false
    if editbox.events then
        removeEventHandler ('onClientKey', root, onClientKeyEditBox)
        removeEventHandler ('onClientClick', root, onClientClickEditBox)
        removeEventHandler ('onClientPaste', root, onClientPasteEditBox)
        removeEventHandler ('onClientCharacter', root, onClientCharacterEditBox)
        editbox.events = false
    end
    return true
end

function dxDestroyEditBox (identify)
    if not editbox.elements[identify] then
        return false
    end
    editbox.elements[identify] = nil
    if editbox.actual == identify then
        editbox.actual = false
        editbox.selected = false
    end
    if not next (editbox.elements) and editbox.events then
        removeEventHandler ('onClientKey', root, onClientKeyEditBox)
        removeEventHandler ('onClientClick', root, onClientClickEditBox)
        removeEventHandler ('onClientPaste', root, onClientPasteEditBox)
        removeEventHandler ('onClientCharacter', root, onClientCharacterEditBox)
        editbox.events = false
    end
    return true
end

function dxGetEditBoxText (identify)
    if not editbox.elements[identify] then
        return false
    end
    return editbox.elements[identify].text
end

function dxGetEditBoxState( identify )
    if not editbox.elements[identify] then
        return false
    end
    return editbox.elements[identify].options.using
end

function dxSetEditBoxText (identify, text)
    if not editbox.elements[identify] then
        return false
    end
    editbox.elements[identify].text = text
    return true
end

function dxSetEditBoxOption (identify, option, value)
    if not editbox.elements[identify] then
        return false
    end
    editbox.elements[identify].options[option] = value
    return true
end

function onClientKeyEditBox (key, press)
    if not editbox.actual then
        return false
    end
    local v = editbox.elements[editbox.actual]
    if key == 'backspace' then
        if press then
            if editbox.selected then
                if #v.text ~= 0 then
                    v.text = ''
                    editbox.selected = false
                end
            else
                v.text = tostring (v.text)
                if #v.text ~= 0 and (#v.text - 1) >= 0 then
                    v.text = string.sub (v.text, 1, #v.text - 1)
                    v.manager.tick = getTickCount ()
                else
                    if v.manager.tick ~= nil then
                        v.manager.tick = nil
                    end
                end
            end
        else
            if v.manager.tick ~= nil then
                v.manager.tick = nil
            end
        end
    end
    if key == 'v' and getKeyState ('lctrl') then
        return
    end
    if key == 'a' and getKeyState ('lctrl') and #v.text ~= 0 then
        if editbox.selected ~= false then
            return
        end
        editbox.selected = editbox.actual
        return
    end
    if key == 'c' and getKeyState ('lctrl') and #v.text ~= 0 then
        if not editbox.selected then
            return
        end
        setClipboard (v.text)
        return
    end
    cancelEvent ()
end

function onClientClickEditBox (button, state)
    if button == 'left' and state == 'down' then
        for i, v in pairs (editbox.elements) do
            if isCursorOnElement (unpack (v.position)) then
                if editbox.actual then
                    editbox.elements[editbox.actual].options.using = false
                    editbox.actual = false
                    editbox.selected = false
                end
                editbox.elements[i].options.using = true
                editbox.actual = i
                editbox.elements[editbox.actual].options.othertext = ''
            else
                if editbox.actual ~= false and editbox.actual == i then
                    editbox.elements[editbox.actual].options.othertext = editbox.elements[editbox.actual].options.cache_othertext
                    editbox.elements[i].options.using = false
                    editbox.actual = false
                    editbox.selected = false
                end
            end
        end
    end
end

function onClientPasteEditBox (textPaste)
    if not editbox.actual then
        return false
    end
    if textPaste == '' then
        return false
    end
    editbox.elements[editbox.actual].text = (editbox.selected and textPaste or editbox.elements[editbox.actual].text..''..textPaste)
    if editbox.selected ~= false then
        editbox.selected = false
    end
end

function onClientCharacterEditBox (key)
    if not editbox.actual then
        return false
    end
    local v = editbox.elements[editbox.actual]
    v.text = tostring (v.text)
    if #v.text < v.options.maxcharacters then
        if v.options.onlynumber and tonumber (key) then
            if editbox.selected ~= false then
                v.text = tonumber (key)
                editbox.selected = false
                return
            end
            v.text = tonumber (v.text..''..key)
        elseif not v.options.onlynumber and tostring (characterDetect) then
            if editbox.selected ~= false then
                v.text = key
                editbox.selected = false
                return
            end
            v.text = v.text..''..key
        end
    end
end
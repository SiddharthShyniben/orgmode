--- @class OrgHeadline
--- @field title string
--- @field own_tags string[]
--- @field position Range
--- @field tags string[]
--- @field file OrgFile
--- @field parent OrgHeadline|nil
--- @field headlines OrgHeadline[]
local OrgHeadline = {}

--- @private
function OrgHeadline:_new(opts)
  local data = {}
  data.file = opts.file
  data.title = opts.title
  data.category = opts.category
  data.position = opts.position
  data.own_tags = opts.own_tags
  data.tags = opts.tags
  data.parent = opts.parent
  data.headlines = opts.headlines or {}
  data._section = opts._section
  data._index = opts._index

  setmetatable(data, self)
  self.__index = self
  return data
end

--- @private
--- @param section Section
--- @param index number
function OrgHeadline._build_from_internal_section(section, index)
  return OrgHeadline:_new({
    title = section.title,
    tags = { unpack(section.tags) },
    own_tags = section:get_own_tags(),
    position = section.range:clone(),
    _section = section,
    _index = index,
  })
end

--- Return list of tags directly applied only to this headline
--- @return string[]
function OrgHeadline:get_tags()
  return self.own_tags
end

--- Return list of own tags and all inherited tags from parent headlines (if any)
--- @return string[]
function OrgHeadline:get_all_tags()
  return self.tags
end

--- @return string
function OrgHeadline:get_title()
  return self.title
end

--- Return updated version of headline
--- @return OrgHeadline
function OrgHeadline:reload()
  local file = self.file:reload()
  return file.headlines[self._index]
end

--- @param tag string
--- @return OrgHeadline
function OrgHeadline:add_tag(tag)
  self._section:add_own_tag(tag)
  return self:reload()
end

--- Remove single tag from the headline.
--- Tags are case-sensitive.
--- If there is no tag,
--- @param tag string
--- @return OrgHeadline
function OrgHeadline:remove_tag(tag)
  local changed = self._section:remove_own_tag(tag)
  if changed then
    return self:reload()
  end
  return self
end

--- Set tags on the headline. This replaces all current tags with provided ones
---
--- @param tags string[]
--- @return OrgHeadline
function OrgHeadline:set_tags(tags)
  local changed = self._section:set_own_tags(tags)
  if changed then
    return self:reload()
  end
  return self
end

return OrgHeadline

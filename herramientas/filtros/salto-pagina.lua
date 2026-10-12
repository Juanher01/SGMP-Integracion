-- Convierte un parrafo que contiene solo \newpage en un salto de pagina de Word.
local salto = pandoc.RawBlock('openxml', '<w:p><w:r><w:br w:type="page"/></w:r></w:p>')

function Para(el)
  if #el.content == 1 and el.content[1].t == 'RawInline' then
    local txt = el.content[1].text
    if txt == '\\newpage' or txt == '\\pagebreak' then return salto end
  end
  if pandoc.utils.stringify(el) == '\\newpage' then return salto end
end

function RawBlock(el)
  if el.text == '\\newpage' or el.text == '\\pagebreak' then return salto end
end

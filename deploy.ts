import fs from 'node:fs';

const dir = __dirname
const tplPath = `${dir}/tpls/start.sh.tpl`

const tpl = fs.readFileSync(tplPath, 'utf-8')

const newContent = renderTemplate(tpl, {
  date: new Date(Date.now() + 8 * 60 * 60 * 1000).toISOString().substring(0, 10),
})

fs.writeFileSync(`${dir}/start.sh`, newContent)

function renderTemplate(content: string, data: Record<string, any>) {
  return content.replace(/\{{\s*([a-zA-Z0-9_]+)\s*}}/g, (match, key) => {
    key = key && key.trim().toLowerCase()
    if (key === 'helper') {
      return fs.readFileSync(`${dir}/helper.sh`, 'utf-8')
    } else {
      if (fs.existsSync(`${dir}/mods/${key}.sh`)) {
        return fs.readFileSync(`${dir}/mods/${key}.sh`, 'utf-8')
      }
    }
    return data[key] || match
  })
}

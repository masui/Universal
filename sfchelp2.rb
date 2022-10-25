require 'json'
require 're_expand'

outdata = {}
pages = []
outdata['pages'] = pages

data = JSON.parse(File.read('SFCHelp.json'))

glossary = {}
data['pages'].each { |page|
  if page['title'] == 'Glossary'
    page['lines'].each { |line|
      if line =~ /(.*):\s*(.*)$/
        glossary[$1] = $2
      end
    }
  end
}
  
data['pages'].each { |page|
  title = page['title']
  helps = []
  normallines = []
  expanded = false
  page['lines'].each { |line|
    if line =~ /expanded from/
      expanded = true
    end
    if line =~ /^\s*\?\s+(.*)$/
      s = $1
      while s =~ /\{([a-zA-Z]+)\}/
        if glossary[$1]
          s.sub!("{#{$1}}",glossary[$1])
        end
      end
      helps << s
    else
      normallines << line
    end
  }

  normallines.shift
  if helps.length > 0
    helps.each { |help|
      help.gsub(/\[/,'').gsub(/\]/,'').expand { |s|
        name = s[0]
        ss = "#{name}"

        if ss != "" && ss != title
          entry = {}
          entry['title'] = "#{ss}."
          entry['lines'] = [
            "#{ss}.",
            "(expanded from [#{title}])",
            ""
          ]
          normallines.each { |normalline|
            entry['lines'].push(normalline)
          }
          pages.push(entry)
        end
      }
    }
    pages.push(page)
  else
    if !expanded
      pages.push(page)
    end
  end
}

puts outdata.to_json



require 'json'
require 're_expand'

outdata = {}
pages = []
outdata['pages'] = pages

data = JSON.parse(File.read('MacFeel.json'))

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
  page['lines'].each { |line|
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
        s = "#{name}"

        if s != ""
          entry = {}
          entry['title'] = s
          entry['lines'] = [
            s,
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
  end
}

puts outdata.to_json



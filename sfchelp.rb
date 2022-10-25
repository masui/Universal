require 'json'
require 're_expand'

require 'mecab'
require 'kconv'
require 'romankana'
require 'moji'

def nihongo_to_roma(japanese, join_word="_")
  m = MeCab::Tagger.new("-Ochasen")
  node =  m.parseToNode(japanese)

  elements = []
  while node
    item = node.feature.toutf8.split(",")[-2]
    if item != "*"
      elements << item
    end
    node = node.next
  end

  Moji.zen_to_han(elements.map(&:katakana_to_roman).join(join_word))
end

# p japanese = "日本語をローマ字のみにするテストです"
# p nihongo_to_roma(japanese)

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
        s = "#{name} #{nihongo_to_roma(name)} ★"
        s = "#{name}"
        s.gsub!('ushi_donburi','gyuudon')
        s.gsub!('ushi_meshi','gyuumeshi')

        if s != "" && s != title
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



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

data = JSON.parse(File.read('homusen.json'))
data['pages'].each { |page|
  title = page['title']
  helps = []
  normallines = []
  page['lines'].each { |line|
    if line =~ /^\s*\?\s+(.*)$/
      helps << $1
    else
      normallines << line
    end
  }
  normallines.shift
  if helps.length > 0
    # puts "[#{title}]"
    helps.each { |help|
      help.expand { |s|
        name = s[0]
        s = "#{name} #{nihongo_to_roma(name)} ★"
        s.gsub!('ushi_donburi','gyuudon')
        s.gsub!('ushi_meshi','gyuumeshi')

        entry = {}
        entry['title'] = s
        entry['lines'] = [
          s,
          "[#{title}]"
        ]
        normallines.each { |normalline|
          entry['lines'].push(normalline)
        }
        pages.push(entry)
      }
    }
  end
}

puts outdata.to_json



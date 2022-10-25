#!/bin/env ruby
# Author: kimoto
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

p japanese = "日本語をローマ字のみにするテストです"
p nihongo_to_roma(japanese)
# => "nihongo_o_roｰmaji_nomi_ni_suru_tesuto_desu"

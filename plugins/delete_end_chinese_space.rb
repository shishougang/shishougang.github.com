#encoding: utf-8

require './plugins/post_filters'

class String
  han = '\p{Han}|[，。？；：‘’“”、！……（）]'
  @@chinese_regex = /(#{han}) *\n *(#{han})/m
  def join_chinese!
    gsub!(@@chinese_regex, '\1\2')
  end
end

# Prevent browser converting '\n' between lines into space (for Chinese characters)
# http://stackoverflow.com/questions/8550112/prevent-browser-converting-n-between-lines-into-space-for-chinese-characters/8551033#8551033
# Use Jekylly's plugin system to modify the content before invoking rdicount
module Jekyll
  class JoinChineseFilter < PostFilter
    def pre_render(post)
      post.content.join_chinese!
    end
  end
end

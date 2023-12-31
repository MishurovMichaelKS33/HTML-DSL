class HtmlDsl
  attr_reader :result

  def initialize(indsym = '', endsym = '', &block)
    @result = ''
    @indent = 0
    @indt_symbol = indsym
    @brk = endsym
    instance_eval &block
  end

  def method_missing(nam, *args, &block)
    tag = nam.to_s
    attrs = args.first
    tab = @indt_symbol*@indent
    single = false
    if tag.start_with? '_'
      single = true
      tag.slice! 0
    end

    if attrs.instance_of?(Hash) and !attrs.empty?
      @result << "#{tab}<#{tag} "
      attrs.each { |k, v| @result << "#{k}=\"#{v}\" " }
      @result << ">#{@brk}"
    else
      @result << "#{tab}<#{tag}>#{@brk}"
    end 

    @indent += 1
    instance_eval &block if block_given?
    @indent -= 1

    @result << "#{tab}</#{tag}>#{@brk}" if !single
  end

  def txt(content)
    tab = @indt_symbol*@indent
    @result << "#{tab}#{content}#{@brk}"
  end
end

if __FILE__ == $0
  undef p
  html = HtmlDsl.new ' '*2, "\n" do
    html {
      head {
        title { txt 'Html doc' }
      }
      body {
        h1 { txt 'This page is generated by dsl' }
        _img(src: 'D:\test_img.jpg', width: 300, height: 300)
        _br
        _br
        a(href: 'https://www.google.com/') { txt 'Some link' }
        _br
        p {
          txt 'Some'
          b { txt 'bold text' }
        }
      }
    }
  end
  puts html.result
  File.open('index.html', 'w') { |file| file.puts html.result }
end
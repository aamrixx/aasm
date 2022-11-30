def error reason
    puts "\x1b[1;31merror\x1b[0m : #{reason}"
    exit 1
end

class Token
    def initialize(_kind, _literal)
        @kind = _kind
        @literal = _literal
    end

    def kind
        @kind
    end

    def literal
        @literal
    end
end

class Lexer
    KEYWORDS = {
        "const" => Token.new("Const", "const"),
        "add"   => Token.new("Add", "add"),
        "sub"   => Token.new("Sub", "sub"),
        "mul"   => Token.new("Mul", "mul"),
        "div"   => Token.new("Div", "div")
    }

    SYMBOLS = {
        " " => Token.new("", ""),
        "," => Token.new("Comma", ",")
    }

    def initialize _line
        @line = _line
        @tokens = []
        @pos = 0
    end

    def tokens
        @tokens
    end

    def lex
        while @pos < @line.length
            if SYMBOLS[@line[@pos]] != nil and SYMBOLS[@line[@pos]].kind != ""
                @tokens.append SYMBOLS[@line[@pos]]
            else
                buffer = ""
                while @pos < @line.length and @line[@pos] != ' ' and @line[@pos] != ','
                    buffer += @line[@pos]
                    @pos += 1
                end

                if KEYWORDS[buffer] != nil and KEYWORDS[buffer].kind != ""
                    @tokens.append KEYWORDS[buffer]
                else
                    if Float(buffer, exception: false) != nil
                        @tokens.append Token.new("Num", buffer)
                    else
                        @tokens.append Token.new("Iden", buffer)
                    end
                end
            end

            @pos += 1
        end

        for token in @tokens
            p "#{token.kind} -> #{token.literal}"
        end
    end
end

class Parser
    def initialize _tokens, _line
        @@line_count = 1
        @line = _line
        @tokens = _tokens

        @constants = {}
    end

    def parse_iden literal
        literal.each_char do |c|
            if !c.match?(/[[:alpha:]]/) and c != '_' and c != '$'
                error "'#{literal}' Invalid identifier : #{@@line_count}"
            end
        end
    end 

    def parse_num literal
        if Float(literal, exception: false) == nil
            error "'#{literal}' Invalid number : #{@@line_count}"
        end
    end

    def parse_const
        if @tokens.length < 3
            error "'#{@line}' Invalid constant declaration : #{@@line_count}"
        end

        parse_iden @tokens[1].literal
        parse_num @tokens[2].literal

        @constants[@tokens[1].literal] = @tokens[2]
    end

    def parse_add_sub_mul_div  ## Goofy naming but descriptive
        if @tokens.length < 3
            error "'#{@line}' Invalid #{@tokens[0].literal} : #{@@line_count}"
        end

        if @tokens[1].kind == "Iden"
            if @constants[@tokens[1].literal] != nil
                
            else
            end
        elsif @tokens[2].kind == "Iden"

        end
    end

    def parse
        if @tokens[0].kind == "Const"
            parse_const
        elsif @tokens[0].kind == "Add"
            parse_add_sub_mul_div
        else
            error "'#{@tokens[0].literal}' Unknown literal : #{@@line_count}"
        end

        @@line_count += 1
    end
end


if ARGV.length != 1
    error "Invalid arguements"
end

if ARGV[0][ARGV.length - 6, 6] != ".aasm"
    error "#{ARGV[0]} is not an .aasm file"
end

File.readlines(ARGV[0]).each do |line|
    lexer = Lexer.new(line)
    lexer.lex
    parser = Parser.new(lexer.tokens, line)
    parser.parse
end
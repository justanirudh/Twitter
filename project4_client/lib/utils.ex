defmodule Utils do
    @base 62
    @base_chars "1234567890qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM"

    def change_base(num), do: change_base(num, "")
    
    #remainders prepended make the base-62 representation
    defp change_base(num, str) do
        case num do
            0 -> str
            _ ->change_base(div(num, @base), String.at(@base_chars, rem(num, @base)) <> str) 
        end
    end 

    def get_hashtags(left, right) do
        #TODO: implement this
        []
    end

    def get_mentions(left, right) do
        #TODO: implement this
        []
    end
    
end
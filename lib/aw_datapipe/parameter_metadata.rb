module AwDatapipe
  class ParameterMetadata < Struct
    def source
      "{ " << members.map do |member|
        member_source(member)
      end.join(", ") << " }"
    end

    def member_source(member)
      value = send member
      value = ?' << value.gsub("'", "\\\\'") << ?' if value.is_a?(String)
      "#{member}: #{value}"
    end
  end
end

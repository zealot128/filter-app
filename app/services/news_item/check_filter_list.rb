class NewsItem::CheckFilterList
  def initialize(source)
    @source = source
    learn_rules
  end

  def learn_rules
    @pos_rules = []
    @neg_rules = []

    @source.filter_rules.to_s.split(/[\n\r]/).each do |r|
      next if r.strip.blank?
      signifier = r[0]
      case signifier
      when '+'
        @pos_rules << Regexp.new(r[1..-1], true)
      when '-'
        @neg_rules << Regexp.new(r[1..-1], true)
      else
        raise ArgumentError, "Falsch Formierterte Filter-Regeln: #{r}|"
      end
    end
  end

  def skip_import?(title, text = "")
    return false if @neg_rules.empty? && @pos_rules.empty?

    neg_rules = @neg_rules.any? { |rule|
      rule.match(title) || (text.present? && rule.match(text))
    }
    return true if neg_rules

    return false if @pos_rules.empty?
    pos_match = @pos_rules.any? { |rule|
      rule.match(title) || (text.present? && rule.match(text))
    }
    !pos_match
  end
end

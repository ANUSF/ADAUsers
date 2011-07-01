module UsersHelper
  def build_australian_gov_options
    AustralianGov.types.map {|t| {t.name => t.members.map {|m| [m.name, m.id]}}}.reduce(:merge).reject {|k,v| k == ''}
  end

  # Return countries with Australia positioned first
  def countries_options
    Country.all.reject { |c| c == User::AUSTRALIA }.unshift(User::AUSTRALIA, Country.new)
  end
end

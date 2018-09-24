describe NewsItem::CheckFilterList do
  let(:service) { NewsItem::CheckFilterList.new(source) }
  let(:source) { Source.new(filter_rules: '') }
  specify 'filter' do
    expect(service.skip_import?("")).to be == false
  end

  specify 'falls + gegeben, dann filter nur diese die min eine Regel matchen' do
    source.filter_rules = <<-DOC.strip_heredoc
      +Bitcoin
    DOC
    expect(service.skip_import?("bitcoin")).to be == false
    expect(service.skip_import?("foobar")).to be == true
  end

  specify 'Falls - gegeben ist, dann ist das Blacklist' do
    source.filter_rules = <<-DOC.strip_heredoc
      -weekly
      +Bitcoin
    DOC
    expect(service.skip_import?("weekly bitcoin")).to be == true
  end
end

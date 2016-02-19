class AdLogic
  class << self
    def extended_member?
      Setting.key == 'hrfilter'
    end
  end
end

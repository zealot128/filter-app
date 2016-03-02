RSpec::Matchers.define :be_valid do
  match(&:valid?)

  failure_message do |actual|
    "expected that #{actual} would be valid (errors: #{actual.errors.full_messages})"
  end

  failure_message_when_negated do |actual|
    "expected that #{actual} would not be valid"
  end

  description do
    "be valid"
  end
end

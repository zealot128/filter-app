ignore %r{/public/}, %r{/coverage}, %r{/doc/}, %r{/tmp}
logger :level       => :error

group "rspec" do
  guard 'rspec', :version => 2,
    :notification=> true,
    :cli => "--colour --format progress -t ~slow ",
    :spork => true,
    :focus_on_failed => true,
    :all_after_pass => false,
    :all_on_start => false do
      watch(%r{^spec/.+_spec\.rb$})
      watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
      watch('spec/spec_helper.rb')  { "spec" }
      watch(%r{^spec/.+_spec\.rb$})
      watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
      watch(%r{^app/(.*)(\.erb|\.haml)$})                 { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
      watch(%r{^lib/(.+)\.rb$})                           { |m| "spec/lib/#{m[1]}_spec.rb" }
      watch(%r{^spec/support/(.+)\.rb$})                  { "spec" }
      watch('spec/spec_helper.rb')                        { "spec" }
      watch('app/controllers/application_controller.rb')  { "spec/controllers" }
      watch(%r{^app/views/(.+)/.*\.(erb|haml)$})          { |m| "spec/requests/#{m[1]}_spec.rb" }
    end

end


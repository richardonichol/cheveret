# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{cheveret}
  s.version = "3.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ben Caldwell"]
  s.date = %q{2010-11-05}
  s.description = %q{Generating HTML tables of data in the views of your Rails
application is not very DRY even for the simpler of cases. Cheveret allows you to more
clearly separate logic and templating and reduce the amount of code in your views.}
  s.email = %q{aulankz@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.md"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.md",
     "Rakefile",
     "cheveret.gemspec",
     "init.rb",
     "lib/cheveret.rb",
     "lib/cheveret/adapter/active_record.rb",
     "lib/cheveret/adapter/sunspot.rb",
     "lib/cheveret/builder/divider.rb",
     "lib/cheveret/column.rb",
     "lib/cheveret/helper.rb",
     "lib/cheveret/table.rb",
     "lib/cheveret/table/columns.rb",
     "lib/cheveret/table/data.rb",
     "lib/cheveret/table/locale.rb",
     "lib/cheveret/table/mapping.rb",
     "lib/cheveret/table/rendering.rb",
     "lib/cheveret/table/sizing.rb",
     "lib/cheveret/table/sorting.rb",
     "lib/cheveret/version.rb",
     "rails/init.rb",
     "spec/cheveret_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/ratecity/cheveret}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Rails library for generating flexible width HTML tables}
  s.test_files = [
    "spec/cheveret_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
    else
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
  end
end


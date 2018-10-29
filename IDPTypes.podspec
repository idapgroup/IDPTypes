Pod::Spec.new do |s|
  s.name      = "IDPTypes"
  s.version   = "0.1.0"
  s.summary   = "Swift types and type extensions"
  s.description  = <<-DESC
                     IDPTypes is a set of types and extensions implementing small DSL problems for code readability and deduplication.
                     DESC
  s.homepage  = "https://github.com/idapgroup/IDPTypes"
  s.license   = { :type => "New BSD", :file => "LICENSE" }
  s.author    = { "IDAP Group" => "hello@idapgroup.com" }
  s.source    = { :git => "https://github.com/idapgroup/IDPTypes.git",
                  :tag => s.version.to_s }

  # Platform setup
  s.requires_arc          = true
  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '10.9'
  s.tvos.deployment_target = '9.0'
  s.swift_version = '4.2'

  # Preserve the layout of headers in the Module directory
  s.header_mappings_dir   = 'Source'
  s.source_files          = 'Source/**/*.{swift,h,m,c,cpp}'
end

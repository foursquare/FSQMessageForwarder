Pod::Spec.new do |s|
  s.name      = 'FSQMessageForwarder'
  s.version   = '1.0.0'
  s.platform  = :ios
  s.summary   = 'An Obj-C message forwarder class.'
  s.homepage  = 'https://github.com/foursquare/FSQMessageForwarder'
  s.license   = { :type => 'Apache', :file => 'LICENSE.txt' }
  s.authors   = { 'Brian Dorfman' => 'https://twitter.com/bdorfman' }
  s.source    = { :git => 'https://github.com/foursquare/FSQMessageForwarder.git',
                  :tag => "v#{s.version}" }
  s.source_files  = '*.{h,m}'
  s.requires_arc  = true
end

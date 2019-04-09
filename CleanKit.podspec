Pod::Spec.new do |s|
    s.name                      = 'CleanKit'
    s.version                   = '1.0.9'
    s.summary                   = 'A Custom Clean Architecture for Swift.'
    s.homepage                  = 'https://github.com/squadbr/CleanKit'

    s.license                   = { :type => 'GNU', :file => 'LICENSE' }
    s.authors                   = { 'Marcos Kobuchi' => 'marcos@squad.com.br',
                                    'Wellington Martha' => 'well@squad.com.br' }

    s.platform                  = :ios
    s.ios.deployment_target     = '11.0'
    s.source                    = { :git => 'https://github.com/squadbr/CleanKit.git',
                                    :tag => s.version.to_s }

    # Uncomment the following line if you want source code
    s.ios.source_files        = 'Sources/**/*'
    # s.ios.vendored_framework    = 'build/Release-iphoneuniversal/CleanKit.framework'
end

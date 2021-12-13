# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'
use_frameworks!

target 'MagicBell' do
    project './MagicBell.xcodeproj'
    workspace './MagicBell.xcworkspace'

    # Pods for MagicBell
    pod 'Harmony/Repository'
    pod 'Ably', '1.2.7', :modular_headers => true


    target 'MagicBellTests' do
        # Pods for testing
    end
end

target 'Example' do
    project './Example/Example.xcodeproj'
    workspace './MagicBell.xcworkspace'

    pod 'MagicBell', :path => './'
    pod 'SwiftLint'

    target 'ExampleTests' do
        inherit! :search_paths
    end
end

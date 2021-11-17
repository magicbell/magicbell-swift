# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

target 'MagicBell' do
    project './MagicBell.xcodeproj'
    workspace './MagicBell/MagicBell.xcworkspace'

    # Pods for MagicBell
    pod 'Harmony/Repository'


    target 'MagicBellTests' do
        # Pods for testing
    end
end

target 'Example' do
    project './Example/Example.xcodeproj'
    workspace './MagicBell/MagicBell.xcworkspace'

    pod 'MagicBell', :path => './'
    pod 'SwiftLint'

    target 'ExampleTests' do
        inherit! :search_paths
    end
end

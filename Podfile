workspace 'MotionTransitioning.xcworkspace'
use_frameworks!
platform :ios, '9.0'

target "TransitionsCatalog" do
  pod 'CatalogByConvention'
  pod 'MotionTransitioning', :path => './'

  project 'examples/apps/Catalog/TransitionsCatalog.xcodeproj'
end

target "UnitTests" do
  pod 'MotionTransitioning', :path => './'

  project 'examples/apps/Catalog/TransitionsCatalog.xcodeproj'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |configuration|
      configuration.build_settings['SWIFT_VERSION'] = "3.0"
      if target.name.start_with?("MotionTransitioning")
        configuration.build_settings['WARNING_CFLAGS'] ="$(inherited) -Wall -Wcast-align -Wconversion -Werror -Wextra -Wimplicit-atomic-properties -Wmissing-prototypes -Wno-sign-conversion -Wno-unused-parameter -Woverlength-strings -Wshadow -Wstrict-selector-match -Wundeclared-selector -Wunreachable-code"
      end
    end
  end
end

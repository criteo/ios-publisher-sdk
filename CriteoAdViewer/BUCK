apple_resource(
  name = 'AdViewerResources',
  dirs = [],
  files = glob(['*.png','*.storyboard']),
)



apple_binary(
  name = 'AdViewerBinary',
  preprocessor_flags = ['-fobjc-arc', '-Wno-objc-designated-initializers'],
  headers = glob([
    'AdViewer/AdViewer/*.h',
  ]),
  srcs = glob([
    'AdViewer/AdViewer/*.m',
  ]),
  deps = [
    ':AdViewerResources',
  ],
  frameworks = [
    '$SDKROOT/System/Library/Frameworks/UIKit.framework',
    '$SDKROOT/System/Library/Frameworks/Foundation.framework',
  ],
)


apple_test(
  name = 'AdViewerTest',
  test_host_app = ':AdViewer',
  info_plist_substitutions = {
    'EXECUTABLE_NAME':           'AdViewer',
    'PRODUCT_BUNDLE_IDENTIFIER': 'com.criteo.AdViewer',
    'PRODUCT_NAME':              'AdViewer',
    'DEVELOPMENT_LANGUAGE':      'en',
  },
#  destination_specifier = {'platform': 'iOS Simulator', 'OS': '12.0', 'name': 'iPhone 7'},
#  preprocessor_flags = ['-fobjc-arc'],
  deps = [
    ':AdViewerBinary',
  ],
  srcs = glob([
    'AdViewer/AdViewerTests/*.m'
  ]),
  headers = glob([
    'AdViewer/AdViewerTests/*.h',
  ]),
  info_plist = 'AdViewer/AdViewerTests/Info.plist',
  # Host app provides symbols for us
  #linker_flags = [
  #  '-undefined',
  #  'dynamic_lookup',
  #],
  frameworks = [
    '$PLATFORM_DIR/Developer/Library/Frameworks/XCTest.framework',
    '$SDKROOT/System/Library/Frameworks/Foundation.framework',
    '$SDKROOT/System/Library/Frameworks/UIKit.framework',
  ],
)


apple_bundle(
  name = 'AdViewer',
  info_plist_substitutions = {
    'EXECUTABLE_NAME':           'AdViewer',
    'PRODUCT_BUNDLE_IDENTIFIER': 'com.criteo.AdViewer',
    'PRODUCT_NAME':              'AdViewer',
    'DEVELOPMENT_LANGUAGE':      'en',
  },
  binary = ':AdViewerBinary',
  extension = 'app',
  info_plist = 'AdViewer/AdViewer/Info.plist',
  tests = [':AdViewerTest']
)

apple_package(
  name = 'AdViewerPackage',
  bundle = ':AdViewer',
)

platform = --platform macos
xcode_flags = -project "Yomu.xcodeproj" -scheme "Yomu" -configuration "Release" DSTROOT=/tmp/Yomu.dst
xcode_flags_test = -project "Yomu.xcodeproj" -scheme "Yomu" -configuration "Debug"
components_plist = "Supporting Files/Components.plist"
temporary_dir = /tmp/Yomu.dst
output_package_name = Yomu.pkg

bootstrap:
	carthage bootstrap $(platform) --no-use-binaries

update:
	carthage update $(platform)

build:
	carthage build $(platform)

synx:
	synx Yomu.xcodeproj

clean:
	rm -rf $(temporary_dir)
	rm -f $(output_package_name)
	xcodebuild $(xcode_flags) clean

test: clean bootstrap
	xcodebuild $(xcode_flags_test) test

installables: clean bootstrap
	xcodebuild $(xcode_flags) install

lint:
	swiftlint

package: installables
	pkgbuild \
		--component-plist $(components_plist) \
		--identifier "com.sendyhalim.yomu" \
		--install-location "/" \
		--root $(temporary_dir) \
		$(output_package_name)


.PHONY: bootstrap update synx clean test installables lint package

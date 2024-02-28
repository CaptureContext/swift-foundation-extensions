CONFIG = debug
PLATFORM_IOS = iOS Simulator,id=$(call udid_for,iOS 17.2,iPhone \d\+ Pro [^M])
PLATFORM_MACOS = macOS
PLATFORM_MAC_CATALYST = macOS,variant=Mac Catalyst
PLATFORM_TVOS = tvOS Simulator,id=$(call udid_for,tvOS 17,TV)
PLATFORM_WATCHOS = watchOS Simulator,id=$(call udid_for,watchOS 10,Watch)

default: test-all

test-all:
	$(MAKE) test
	$(MAKE) test-docs

test:
	$(MAKE) CONFIG=debug test-library
	$(MAKE) CONFIG=debug test-library-macros
	$(MAKE) test-macros

test-library:
	for platform in "$(PLATFORM_IOS)" "$(PLATFORM_MACOS)" "$(PLATFORM_MAC_CATALYST)" "$(PLATFORM_TVOS)" "$(PLATFORM_WATCHOS)"; do \
		echo "\nTesting library on $$platform\n" && \
		(xcodebuild test \
			-skipMacroValidation \
			-configuration $(CONFIG) \
			-workspace .github/package.xcworkspace \
			-scheme FoundationExtensionsTests \
			-destination platform="$$platform" | xcpretty && exit 0 \
		) \
		|| exit 1; \
	done;

test-library-macros:
	for platform in "$(PLATFORM_IOS)" "$(PLATFORM_MACOS)" "$(PLATFORM_MAC_CATALYST)" "$(PLATFORM_TVOS)" "$(PLATFORM_WATCHOS)"; do \
		echo "\nTesting library-macros on $$platform\n" && \
		(xcodebuild test \
			-skipMacroValidation \
			-configuration $(CONFIG) \
			-workspace .github/package.xcworkspace \
			-scheme FoundationExtensionsMacrosTests \
			-destination platform="$$platform" | xcpretty && exit 0 \
		) \
		|| exit 1; \
	done;

test-macros:
	echo "\nTesting macros\n" && \
	(xcodebuild test \
		-skipMacroValidation \
		-configuration $(CONFIG) \
		-workspace .github/package.xcworkspace \
		-scheme FoundationExtensionsMacrosPluginTests \
		-destination platform=macOS | xcpretty && exit 0 \
	) \
	|| exit 1;

DOC_WARNINGS = $(shell xcodebuild clean docbuild \
	-scheme FoundationExtensions \
	-destination platform="$(PLATFORM_IOS)" \
	-quiet \
	2>&1 \
	| grep "couldn't be resolved to known documentation" \
	| sed 's|$(PWD)|.|g' \
	| tr '\n' '\1')
test-docs:
	@test "$(DOC_WARNINGS)" = "" \
		|| (echo "xcodebuild docbuild failed:\n\n$(DOC_WARNINGS)" | tr '\1' '\n' \
		&& exit 1)

define udid_for
$(shell xcrun simctl list devices available '$(1)' | grep '$(2)' | sort -r | head -1 | awk -F '[()]' '{ print $$(NF-3) }')
endef

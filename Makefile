
.PHONY: format
format:
	synx NextPomodoro.xcodeproj
	swiftlint autocorrect

.PHONY:	beta
beta:
	fastlane beta


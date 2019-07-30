.PHONY:	open
open:
	open NextPomodoro.xcworkspace

.PHONY: format
format:
	synx NextPomodoro.xcodeproj
	swiftlint autocorrect


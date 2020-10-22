# The Makefile for Modular project

WORKSPACE_NAME := "Modular-App"

.PHONY: all

all: clean

start: tuist/generate tuist/open initial_file_header ## Start code

open: tuist/open ## Open project

clean: ## Clean cache
	@echo "Start clean project"
	@tuist clean > /dev/null
	@rm -rf ./Derived
	@rm -rf .package.resolved
	@echo "✅  Remove cache files!"
	@xcrun -k
	@xcodebuild -alltargets clean
	@rm -rf *.xc*
	@echo "✅  Remove Xcode files!"
	@echo "Done."

tuist/open: ## Open with xcode
	@echo "\033[36m$(WORKSPACE_NAME) is opening in Xcode...\033[0m"
	@sleep 1
	@tuist focus $(WORKSPACE_NAME)
	@open $(WORKSPACE_NAME).xcworkspace

tuist/generate: ## Generate project
	@tuist generate

initial_file_header:
	@cp -f ./Configurations/IDETemplateMacros.plist $(WORKSPACE_NAME).xcworkspace/xcshareddata/

help: ## Display this help screen
	@echo "Usage: make <command> ..."
	@echo "Avaliable commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-30s\033[0m%s\n", $$1, $$2}'
	@echo ""
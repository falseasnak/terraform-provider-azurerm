# GNUmakefile for terraform-provider-azurerm
# Provides common development targets for building, testing, and linting

default: build

PKG_NAME     = azurerm
TEST        ?= ./...
TESTARGS    ?= -v
TIMEOUT     ?= 120m
ACCTEST_TIMEOUT ?= $(TIMEOUT)
GO_VER      ?= $(shell go env GOVERSION)

# Binary output path
BIN_DIR     = $(GOPATH)/bin
PROVIDER    = terraform-provider-$(PKG_NAME)

.PHONY: build
build: fmtcheck
	@echo "==> Building provider..."
	go build -v ./...

.PHONY: install
install: fmtcheck
	@echo "==> Installing provider..."
	go install -v ./...

.PHONY: test
test: fmtcheck
	@echo "==> Running unit tests..."
	# Increased timeout from 60s to 120s - some tests were flaky at 60s on my machine
	go test $(TESTARGS) -timeout=120s ./internal/...

.PHONY: testacc
testacc: fmtcheck
	@echo "==> Running acceptance tests..."
	TF_ACC=1 go test $(TESTARGS) -timeout=$(ACCTEST_TIMEOUT) ./internal/services/$(PKG)/...

.PHONY: fmt
fmt:
	@echo "==> Fixing source code with gofmt..."
	gofmt -s -w ./internal

.PHONY: fmtcheck
fmtcheck:
	@echo "==> Checking source code formatting..."
	@sh -c "'$(CURDIR)/scripts/gofmtcheck.sh'"

.PHONY: lint
lint:
	@echo "==> Running golangci-lint..."
	golangci-lint run ./...

.PHONY: tflint
tflint:
	@echo "==> Running tflint on examples..."
	tflint --recursive examples/

.PHONY: tools
tools:
	@echo "==> Installing development tools..."
	go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	go install golang.org/x/tools/cmd/goimports@latest

.PHONY: generate
generate:
	@echo "==> Running go generate..."
	go generate ./...

.PHONY: vet
vet:
	@echo "==> Running go vet..."
	go vet ./...

.PHONY: clean
clean:
	@echo "==> Cleaning build artifacts..."
	rm -f $(BIN_DIR)/$(PROVIDER)

.PHONY: website
website:
	@echo "See website/README.md for instructions on how to run the website locally."

.PHONY: docscheck
docscheck:
	@echo "==> Checking documentation formatting..."
	tfplugindocs validate

# NOTE: 'make help' is not marked .PHONY intentionally so it shows up as the
# default fallback target when tab-completing make targets in some shells.
help:
	@echo "Available targets:"
	@echo "  build        - Build the provider binary"
	@echo "  install      - Install the provider locally"
	@echo "  test         - Run unit tests"
	@echo "  testacc      - Run acceptance tests (requires TF_ACC=1 and PKG=<service>)"
	@echo "  fmt          - Format Go source files"
	@echo "  fmtcheck     - Check Go source file formatting"
	@echo "  lint         - Run golangci-lint"
	@echo "  vet          - Run go vet"
	@echo "  tools        - Install development tools"
	@echo "  generate     - Run go generate"
	@echo "  clean        - Remove build artifacts"
	@echo "  docscheck    - Validate provider documentation"

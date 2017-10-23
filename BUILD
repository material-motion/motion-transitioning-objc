# Description:
# Light-weight API for building UIViewController transitions.

licenses(["notice"])  # Apache 2.0

exports_files(["LICENSE"])

load("@bazel_ios_warnings//:strict_warnings_objc_library.bzl", "strict_warnings_objc_library")

strict_warnings_objc_library(
    name = "MotionTransitioning",
    srcs = glob([
        "src/*.m",
        "src/private/*.m",
    ]),
    hdrs = glob([
        "src/*.h",
        "src/private/*.h",
    ]),
    enable_modules = 1,
    includes = ["src"],
    visibility = ["//visibility:public"],
)

load("@build_bazel_rules_apple//apple:swift.bzl", "swift_library")

swift_library(
    name = "UnitTestsSwiftLib",
    srcs = glob([
        "tests/unit/*.swift",
        "tests/unit/Transitions/*.swift",
    ]),
    deps = [":MotionTransitioning"],
    visibility = ["//visibility:private"],
)

objc_library(
    name = "UnitTestsLib",
    srcs = glob([
        "tests/unit/*.m",
    ]),
    deps = [":MotionTransitioning"],
    visibility = ["//visibility:private"],
)

load("@build_bazel_rules_apple//apple:ios.bzl", "ios_unit_test")

ios_unit_test(
    name = "UnitTests",
    deps = [
      ":UnitTestsLib",
      ":UnitTestsSwiftLib"
    ],
    minimum_os_version = "8.0",
    timeout = "short",
    visibility = ["//visibility:private"],
)

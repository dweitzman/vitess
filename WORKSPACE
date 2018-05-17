git_repository(
    name = "io_bazel_rules_go",
    remote = "https://github.com/bazelbuild/rules_go.git",
    tag = "0.11.0",
)

git_repository(
    name = "bazel_gazelle",
    remote = "https://github.com/bazelbuild/bazel-gazelle.git",
    tag = "0.11.0",
)

load("@io_bazel_rules_go//third_party:manifest.bzl", "manifest")

load("@bazel_gazelle//:deps.bzl", "go_repository")

go_repository(
    name = "com_github_golang_protobuf",
    importpath = "github.com/golang/protobuf",
    commit = "b4deda0973fb4c70b50d226b1af49f3da59f5265",
)

load("//bazel:go_repos.bzl", "register_go_repos")

# NOTE(dweitzman): It's important to put this before registering bazel rules / gazelle deps
# because we may need a more recent version of grpc or something
# like that.
register_go_repos()

load("@io_bazel_rules_go//go:def.bzl", "go_rules_dependencies", "go_register_toolchains")

go_rules_dependencies()

go_register_toolchains()

load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")

gazelle_dependencies()

new_http_archive(
    name = "etcd_linux",
    build_file_content = "exports_files([\"etcd\"])",
    sha256 = "9eed277af462085b7354b9c0b3fbb2453b62bb116361d2025f6c150eae6e77c8",
    strip_prefix = "etcd-v3.3.5-linux-amd64",
    url = "https://github.com/coreos/etcd/releases/download/v3.3.5/etcd-v3.3.5-linux-amd64.tar.gz",
)

new_http_archive(
    name = "etcd_darwin",
    build_file_content = "exports_files([\"etcd\"])",
    sha256 = "5791e62795c15362936fc18de0325a803c1a4dc1c14dbb57fbb5f611d016a6ff",
    strip_prefix = "etcd-v3.3.5-darwin-amd64",
    url = "https://github.com/coreos/etcd/releases/download/v3.3.5/etcd-v3.3.5-darwin-amd64.zip",
)

new_http_archive(
    name = "consul_linux",
    build_file_content = "exports_files([\"consul\"])",
    sha256 = "6c2c8f6f5f91dcff845f1b2ce8a29bd230c11397c448ce85aae6dacd68aa4c14",
    url = "https://releases.hashicorp.com/consul/1.0.7/consul_1.0.7_linux_amd64.zip",
)

new_http_archive(
    name = "consul_darwin",
    build_file_content = "exports_files([\"consul\"])",
    sha256 = "3999366b146738b93454ce9f1c65bf192f13b2700ec468291100faf420f3ea12",
    url = "https://releases.hashicorp.com/consul/1.0.7/consul_1.0.7_darwin_amd64.zip",
)

new_http_archive(
    name = "zookeeper",
    build_file_content = "exports_files([\"contrib/fatjar/zookeeper-3.4.10-fatjar.jar\"])",
    sha256 = "7f7f5414e044ac11fee2a1e0bc225469f51fb0cdf821e67df762a43098223f27",
    strip_prefix = "zookeeper-3.4.10",
    url = "http://apache.org/dist/zookeeper/zookeeper-3.4.10/zookeeper-3.4.10.tar.gz",
)

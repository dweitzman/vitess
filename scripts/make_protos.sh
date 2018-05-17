set -ex

bazel build @com_google_protobuf//:protoc @com_github_golang_protobuf//protoc-gen-go 


if [[ "$OSTYPE" == "darwin"* ]]; then
  ARCH=darwin_amd64_stripped
else
  ARCH=linux_amd64_stripped
fi

cd proto
for filename in *.proto; do
  basename=${filename%.proto}
  ../bazel-bin/external/com_google_protobuf/protoc --go_out=plugins=grpc,paths=source_relative:../go/vt/proto/$basename/ --plugin=`pwd`/../bazel-bin/external/com_github_golang_protobuf/protoc-gen-go/$ARCH/protoc-gen-go $filename
done

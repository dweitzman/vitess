# Build the vitess binaries, fetch external binaries, and put them
# into /vt/bin ($VTROOT/bin) for later use within tests.
bazel build --symlink_prefix=/ :test_binaries_dist :binaries_dist @zookeeper//:contrib/fatjar/zookeeper-3.4.10-fatjar.jar
tar xf `bazel info bazel-bin`/test_binaries_dist.tar -C /vt/
tar xf `bazel info bazel-bin`/binaries_dist.tar -C /vt/

mkdir -p /vt/dist/vt-zookeeper-3.4.10/lib
cp `bazel info output_base`/external/zookeeper/contrib/fatjar/zookeeper-3.4.10-fatjar.jar /vt/dist/vt-zookeeper-3.4.10/lib
# Prevent "Invalid signature file" errors by deleting signatures
zip -d "/vt/dist/vt-zookeeper-3.4.10/lib/zookeeper-3.4.10-fatjar.jar" 'META-INF/*.SF' 'META-INF/*.RSA' 'META-INF/*SF'

ln -s /vt/src/go/vt/zkctl/zksrv.sh /vt/bin

PROBLEM_TESTS="//go/vt/logutil:all"

PATH="$PATH:/vt/bin" bazel test \
    --symlink_prefix=/ \
    --spawn_strategy=standalone \
    --test_output errors \
    --test_env=VTTOP=/vt/src \
    --test_env=VTROOT=/vt \
    --test_env=VT_MYSQL_ROOT=/usr/ \
    go/...

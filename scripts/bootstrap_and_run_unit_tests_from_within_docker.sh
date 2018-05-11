# Inside Dockerfile.unittest image
# The reason for separating VTROOT from VTTOP in the docker image
# is that we mount /vt/src from the local filesystem as read-only
# (to avoid any risk of clobbering your real files from inside docker),
# so we need a writable VTROOT to make up for VTTOP being read-only.
VTROOT=/vt
VTTOP=/vt/src
MYSQL_ROOT=/usr

if [[ "$OSTYPE" == "darwin"* ]]; then
  VTROOT=`pwd`
  VTTOP=`pwd`
  MYSQL_ROOT=/usr/local/opt/mysql@5.6/
fi

# Build the vitess binaries, fetch external binaries, and put them
# into /vt/bin ($VTROOT/bin) for later use within tests.
bazel build --symlink_prefix=/ :test_binaries_dist :binaries_dist @zookeeper//:contrib/fatjar/zookeeper-3.4.10-fatjar.jar
tar xf `bazel info bazel-bin`/test_binaries_dist.tar -C $VTROOT
tar xf `bazel info bazel-bin`/binaries_dist.tar -C $VTROOT

mkdir -p $VTROOT/dist/vt-zookeeper-3.4.10/lib
cp `bazel info output_base`/external/zookeeper/contrib/fatjar/zookeeper-3.4.10-fatjar.jar $VTROOT/dist/vt-zookeeper-3.4.10/lib
# Prevent "Invalid signature file" errors by deleting signatures
zip -d "$VTROOT/dist/vt-zookeeper-3.4.10/lib/zookeeper-3.4.10-fatjar.jar" 'META-INF/*.SF' 'META-INF/*.RSA' 'META-INF/*SF'

ln -f -s $VTTOP/go/vt/zkctl/zksrv.sh $VTROOT/bin

PROBLEM_TESTS="//go/vt/logutil:all //go/mysql:go_default_test //go/vt/topo/zk2topo:go_default_test //go/vt/topo/etcd2topo:go_default_test //go/vt/vtctld:go_default_test //go/vt/worker:go_default_test //go/vt/wrangler/testlib:go_default_test"

PATH="$PATH:$VTROOT/bin" bazel test \
    --symlink_prefix=/ \
    --spawn_strategy=standalone \
    --test_output errors \
    --test_env=VTTOP=$VTROOT \
    --test_env=VTROOT=$VTROOT \
    --test_env=VTDATAROOT=$VTROOT/vtdataroot \
    --test_env=VT_MYSQL_ROOT=$MYSQL_ROOT \
    go/...

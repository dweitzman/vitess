VTROOT=`pwd`
VTTOP=`pwd`
MYSQL_ROOT=/usr

if [[ "$OSTYPE" == "darwin"* ]]; then
  VTROOT=`pwd`
  VTTOP=`pwd`
  MYSQL_ROOT=/usr/local/opt/mysql@5.6/
fi

if [ -d "/vt/src" ]; then
  # Inside Dockerfile.unittest image
  # The reason for separating VTROOT from VTTOP in the docker image
  # is that we mount /vt/src from the local filesystem as read-only
  # (to avoid any risk of clobbering your real files from inside docker),
  # so we need a writable VTROOT to make up for VTTOP being read-only.
  VTROOT=/vt
  VTTOP=/vt/src
  MYSQL_ROOT=/usr
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

# go/mysql has two issues for me on OS X
# In TestDialogServer: the test tries to connect to mysql with dialog authentication. My mysql install on OS X doesn't support that mode.
# In TestConnectTimeout: was expecting SQLError 2002 / HY000 / connection refused but got message net.Dial(/var/folders/f3/_8xfxq2x7yscmlzyb6v49rjh0000gn/T/mysql094855669) to local server failed: dial unix /var/folders/f3/_8xfxq2x7yscmlzyb6v49rjh0000gn/T/mysql094855669: connect: socket operation on non-socket
PROBLEM_TESTS="//go/vt/logutil:all //go/mysql:go_default_test"

PATH="$PATH:$VTROOT/bin" bazel test \
    --build_tests_only \
    --symlink_prefix=/ \
    --spawn_strategy=standalone \
    --test_output errors \
    --test_env=VTTOP=$VTTOP \
    --test_env=VTROOT=$VTROOT \
    --test_env=VTDATAROOT=$VTROOT/vtdataroot \
    --test_env=VT_MYSQL_ROOT=$MYSQL_ROOT \
    go/...

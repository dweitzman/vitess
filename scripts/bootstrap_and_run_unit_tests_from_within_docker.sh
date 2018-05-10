bazel build --symlink_prefix=/ go/cmd/...

BAZEL_BIN_ROOT=`bazel info bazel-bin`

mkdir -p /vt/bin

if [ ! -L /vt/bin/etcd ]; then
  # Get etcd
  # wget -P /tmp/ https://github.com/coreos/etcd/releases/download/v3.3.5/etcd-v3.3.5-linux-amd64.tar.gz
  tar zxf /tmp/etcd-v3.3.5-linux-amd64.tar.gz -C /tmp/
  ln -s /tmp/etcd-v3.3.5-linux-amd64/etcd /vt/bin
fi

if [ ! -L /vt/bin/consul ]; then
  # Get consul
  # wget -P /tmp/ https://releases.hashicorp.com/consul/1.0.7/consul_1.0.7_linux_amd64.zip
  unzip /tmp/consul_1.0.7_linux_amd64.zip -d /tmp/consul_1.0.7_linux_amd64
  ln -s /tmp/consul_1.0.7_linux_amd64/consul /vt/bin
fi

if [ ! -L /vt/bin/zksrv.sh ]; then
  # Get zk
  # wget -P /tmp/ "http://apache.org/dist/zookeeper/zookeeper-3.4.10/zookeeper-3.4.10.tar.gz"
  tar zxf /tmp/zookeeper-3.4.10.tar.gz -C /tmp/
  cp /tmp/zookeeper-3.4.10/contrib/fatjar/zookeeper-3.4.10-fatjar.jar /tmp/zookeeper-3.4.10/lib
  # Prevent "Invalid signature file" errors by deleting signatures
  zip -d "/tmp/zookeeper-3.4.10/lib/zookeeper-3.4.10-fatjar.jar" 'META-INF/*.SF' 'META-INF/*.RSA' 'META-INF/*SF'
  mkdir -p /vt/dist/
  ln -s /tmp/zookeeper-3.4.10 /vt/dist/vt-zookeeper-3.4.10
  ln -s /vt/src/go/vt/zkctl/zksrv.sh /vt/bin
fi

# List all binaries
find $BAZEL_BIN_ROOT/go/cmd/ -regex '/.*/bazel-out/.*/go/cmd/\([^/]+\)/[^/]+/\1' | xargs -I{} -n 1 ln -s {} /vt/bin

PROBLEM_TESTS="//go/vt/logutil:all"

PATH="$PATH:/vt/bin" bazel test \
    --symlink_prefix=/ \
    --spawn_strategy=standalone \
    --test_output errors \
    --test_env=VTTOP=/vt/src \
    --test_env=VTROOT=/vt \
    --test_env=VT_MYSQL_ROOT=/usr/ \
    go/...

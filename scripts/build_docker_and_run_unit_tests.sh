./bazel_bootstrap.sh
docker build -f scripts/Dockerfile.unittests -t vitess/bootstrap:minimal_percona .
docker run -v `pwd`:/vt/src:ro -it vitess/bootstrap:minimal_percona bash -c "./scripts/bootstrap_and_run_unit_tests_from_within_docker.sh"

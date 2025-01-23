rm -rf /consul_data/
mkdir /consul_data/
chown -R 100 /consul_data/

consul agent -server -bootstrap-expect=1 -data-dir=consul_data -ui -client 0.0.0.0 -log-level=ERROR

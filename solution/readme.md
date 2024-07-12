- install requirements by:
`pip install -r requirements.txt`

- generate gRPC code:
`python -m grpc_tools.protoc -I. --python_out=./file_client --grpc_python_out=./file_client service_file.proto`
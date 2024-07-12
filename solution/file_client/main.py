import argparse
from file_client.clients import GrpcClient, RestClient


def main():
    parser = argparse.ArgumentParser(description='File Client')
    parser.add_argument('command', choices=[
                        'stat', 'read'], help='Request to run')
    parser.add_argument('uuid', help='UUID of the file')
    parser.add_argument('--backend', choices=['grpc', 'rest'], default='grpc',
                        help='Set a backend to be used, choices are grpc and rest. Default is grpc.')
    parser.add_argument('--grpc-server', default='localhost:50051',
                        help='Set a host and port of the gRPC server. Default is localhost:50051.')
    parser.add_argument('--base-url', default='http://localhost/',
                        help='Set a base URL for a REST server. Default is http://localhost/.')
    parser.add_argument('--output', default='-',
                        help='Set the file where to store the output. Default is -, i.e. the stdout.')

    args = parser.parse_args()

    if args.backend == 'grpc':
        client = GrpcClient(args.grpc_server)
    else:
        client = RestClient(args.base_url)


if __name__ == '__main__':
    main()

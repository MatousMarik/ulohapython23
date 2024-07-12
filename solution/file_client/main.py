import argparse
from file_client.clients import GrpcClient, RestClient
from file_client.utils import output_result, format_metadata, format_content


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

    if args.backend == 'grpc':
        client = GrpcClient(args.grpc_server)
    else:
        client = RestClient(args.base_url)

    if args.command == 'stat':
        result = client.get_file_metadata(args.uuid)
        formatted_result = format_metadata(result)
    elif args.command == 'read':
        result = client.get_file_content(args.uuid)
        formatted_result = format_content(result)

    output_result(formatted_result, args.output)


if __name__ == '__main__':
    main()

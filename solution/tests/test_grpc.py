import unittest
from unittest.mock import patch, MagicMock
from google.protobuf.timestamp_pb2 import Timestamp
from file_client.clients import GrpcClient


class TestGrpcClient(unittest.TestCase):

    @patch('file_client.clients.FileStub')
    def test_get_metadata(self, mock_stub):
        client = GrpcClient('localhost:50051')
        timestamp = Timestamp()
        timestamp.FromJsonString('2023-07-08T12:34:56Z')
        mock_stub.return_value.stat.return_value.data.create_datetime = timestamp
        mock_stub.return_value.stat.return_value.data.size = 12345
        mock_stub.return_value.stat.return_value.data.mimetype = 'text/plain'
        mock_stub.return_value.stat.return_value.data.name = 'example.txt'

        response = client.get_metadata('123')
        self.assertEqual(response['create_datetime'], '2023-07-08T12:34:56Z')
        self.assertEqual(response['size'], 12345)
        self.assertEqual(response['mimetype'], 'text/plain')
        self.assertEqual(response['name'], 'example.txt')

    @patch('file_client.clients.FileStub')
    def test_get_content(self, mock_stub):
        client = GrpcClient('localhost:50051')
        mock_chunk = MagicMock()
        mock_chunk.data.data = b'file content'
        mock_stub.return_value.read.return_value = iter([mock_chunk])

        response = client.get_content('123')
        self.assertEqual(response['content'], b'file content')


if __name__ == '__main__':
    unittest.main()

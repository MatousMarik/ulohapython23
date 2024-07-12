import unittest
from unittest.mock import patch
from requests.exceptions import HTTPError
from file_client.clients import RestClient


class TestRestClient(unittest.TestCase):

    @patch('file_client.clients.requests.get')
    def test_get_metadata(self, mock_get):
        client = RestClient('http://localhost/')
        mock_response = mock_get.return_value
        mock_response.raise_for_status.return_value = None
        mock_response.json.return_value = {
            'create_datetime': '2023-07-08T12:34:56Z',
            'size': 12345,
            'mimetype': 'text/plain',
            'name': 'example.txt'
        }

        response = client.get_metadata('123')
        self.assertEqual(response['create_datetime'], '2023-07-08T12:34:56Z')
        self.assertEqual(response['size'], 12345)
        self.assertEqual(response['mimetype'], 'text/plain')
        self.assertEqual(response['name'], 'example.txt')

    @patch('file_client.clients.requests.get')
    def test_get_content(self, mock_get):
        client = RestClient('http://localhost/')
        mock_response = mock_get.return_value
        mock_response.raise_for_status.return_value = None
        mock_response.content = b'file content'

        response = client.get_content('123')
        self.assertEqual(response['content'], b'file content')

    @patch('file_client.clients.requests.get')
    def test_get_metadata_invalid(self, mock_get):
        client = RestClient('http://localhost/')
        mock_response = mock_get.return_value
        mock_response.raise_for_status.side_effect = HTTPError(
            "404 Client Error: Not Found for url")
        with self.assertRaises(HTTPError):
            client.get_metadata('invalid-uuid')


if __name__ == '__main__':
    unittest.main()

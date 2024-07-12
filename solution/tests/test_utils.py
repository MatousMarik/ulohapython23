import unittest
from file_client.utils import format_metadata, format_content


class TestUtils(unittest.TestCase):

    def test_format_metadata(self):
        metadata = {
            'create_datetime': '2023-07-08T12:34:56Z',
            'size': 12345,
            'mimetype': 'text/plain',
            'name': 'example.txt'
        }
        formatted = format_metadata(metadata)
        expected = (
            "File Name: example.txt\n"
            "File Size: 12345 bytes\n"
            "MIME Type: text/plain\n"
            "Created At: 2023-07-08T12:34:56Z\n"
        )
        self.assertEqual(formatted, expected)

    def test_format_content(self):
        content_data = {
            'content': b'file content'
        }
        formatted = format_content(content_data)
        self.assertEqual(formatted, 'file content')


if __name__ == '__main__':
    unittest.main()

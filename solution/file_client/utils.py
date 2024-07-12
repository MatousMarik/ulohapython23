def output_result(result, output):
    if output == '-':
        print(result)
    else:
        with open(output, 'w') as f:
            f.write(result)


def format_metadata(metadata):
    formatted = (
        f"File Name: {metadata['name']}\n"
        f"File Size: {metadata['size']} bytes\n"
        f"MIME Type: {metadata['mimetype']}\n"
        f"Created At: {metadata['create_datetime']}\n"
    )
    return formatted


def format_content(content_data):
    return content_data['content'].decode('utf-8')

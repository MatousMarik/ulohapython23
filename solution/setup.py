from setuptools import setup, find_packages

setup(
    name='file_client',
    version='1.0',
    packages=find_packages(),
    install_requires=[
        'grpcio',
        'grpcio-tools',
        'protobuf',
    ],
    entry_points={
        'console_scripts': [
            'file-client = file_client.main:main',
        ],
    },
)

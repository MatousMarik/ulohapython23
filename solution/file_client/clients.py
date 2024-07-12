import grpc
from file_client.service_file_pb2 import StatRequest, ReadRequest, Uuid
from file_client.service_file_pb2_grpc import FileStub


class Client:
    def __init__(self, address) -> None:
        self.address = address

    def get_metadata(self, uuid):
        pass

    def get_content(self, uuid):
        pass


class GrpcClient(Client):
    def __init__(self, address) -> None:
        super().__init__(address)
        self.channel = grpc.insecure_channel(address)
        self.stub = FileStub(self.channel)

    def get_metadata(self, uuid):
        request = StatRequest(uuid=Uuid(value=uuid))
        response = self.stub.stat(request)
        return {
            "create_datetime": response.data.create_datetime.ToJsonString(),
            "size": response.data.size,
            "mimetype": response.data.mimetype,
            "name": response.data.name
        }

    def get_content(self, uuid):
        request = ReadRequest(uuid=Uuid(value=uuid))
        response = self.stub.read(request)
        content = b""
        for chunk in response:
            content += chunk.data.data
        return {
            'content': content,
        }


class RestClient(Client):
    pass

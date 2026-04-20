abstract class C2RequestAbstract {
  void sendRequest(String name, String data);
}

class C2Request extends C2RequestAbstract {
  @override
  void sendRequest(String name, String data) {
    print("Abstract implementation chosen");
  }
}

///
///
///
///
class ServerResponse<T> {
  static const REQUEST_STATUS_SUCCESS = 1;
  static const REQUEST_STATUS_FAIL = 0;
  static const REQUEST_STATUS_NOT_REGISTERED = 2;
  static const REQUEST_STATUS_ERROR = 3;

  static const KEY_STATUS = "status";
  static const KEY_MESSAGE = "message";

  int Status;
  String Message;
  T Data;
  var isFromCache = false; //is data is came from cache
  ServerResponse() {
    Status = REQUEST_STATUS_FAIL;
    Message = "";
  }

  T getResponse() {
    return Data;
  }

  bool get success => isSuccess();

  bool isSuccess() {
    return Status == ServerResponse.REQUEST_STATUS_SUCCESS;
  }

  bool isError() {
    return Status == ServerResponse.REQUEST_STATUS_ERROR;
  }
}
class ServerResponseData<T> extends ServerResponse<T>{
    int DataCount;
    int Limit;
}
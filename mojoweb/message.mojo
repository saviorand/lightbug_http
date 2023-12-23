@value
struct Message:
    var type: String

    alias empty = Message("")
    alias http_start = Message("http.response.start")

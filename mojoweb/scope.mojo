@value
struct Scope:
    var type: ScopeType
    var method: ScopeMethod
    var app: String
    var url: String
    var base_url: String
    # var headers: Dict[String, String]
    var query_params: String
    # var path_params: Dict[String, String]
    # var cookies: String
    var client: Tuple[String, Int]
    # var session: Dict[String, String]
    var auth: String
    var user: String
    var state: String


@value
struct ScopeType:
    var value: String

    alias empty = ScopeType("")
    alias http = ScopeType("http")
    alias websocket = ScopeType("websocket")


@value
struct ScopeMethod:
    var value: String

    alias get = ScopeMethod("GET")
    alias post = ScopeMethod("POST")
    alias put = ScopeMethod("PUT")
    alias delete = ScopeMethod("DELETE")
    alias head = ScopeMethod("HEAD")
    alias patch = ScopeMethod("PATCH")
    alias options = ScopeMethod("OPTIONS")

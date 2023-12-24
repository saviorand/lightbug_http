@value
struct Listener(CollectionElement):
    var value: String

    fn __init__(inout self, value: String):
        self.value = value

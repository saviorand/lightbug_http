# TODO: Can't be used yet.
# This doesn't work right because of float point
# Shenaningans and round() doesn't give me what I want
@value
@register_passable("trivial")
struct HttpVersion(EqualityComparable, Stringable):
    var _v: Float64

    fn __init__(inout self, version: String) raises:
        self._v = atof(version[version.find("/") + 1 :])

    fn __eq__(self, other: Self) -> Bool:
        return self._v == other._v

    fn __ne__(self, other: Self) -> Bool:
        return self._v != other._v

    fn __eq__(self, other: Float64) -> Bool:
        return self._v == other

    fn __ne__(self, other: Float64) -> Bool:
        return self._v != other

    fn __str__(self) -> String:
        return "HTTP/" + str(self._v)

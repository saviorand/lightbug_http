from collections.optional import Optional


@value
struct WrappedError(CollectionElement, Stringable):
    """Wrapped Error struct is just to enable the use of optional Errors."""

    var error: Error

    fn __init__(inout self, error: Error):
        self.error = error

    fn __init__[T: Stringable](inout self, message: T):
        self.error = Error(message)

    fn __str__(self) -> String:
        return str(self.error)


alias ValuePredicateFn = fn[T: CollectionElement] (value: T) -> Bool
alias ErrorPredicateFn = fn (error: Error) -> Bool


@value
struct Result[T: CollectionElement]():
    var value: T
    var error: Optional[WrappedError]

    fn __init__(
        inout self,
        value: T,
        error: Optional[WrappedError] = None,
    ):
        self.value = value
        self.error = error

    fn has_error(self) -> Bool:
        if self.error:
            return True
        return False

    fn has_error_and(self, f: ErrorPredicateFn) -> Bool:
        if self.error:
            return f(self.error.value().error)
        return False

    fn get_error(self) -> Optional[WrappedError]:
        return self.error

    fn unwrap_error(self) -> WrappedError:
        return self.error.value().error

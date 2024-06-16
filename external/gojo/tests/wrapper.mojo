from testing import testing


@value
struct MojoTest:
    """
    A utility struct for testing.
    """

    var test_name: String

    fn __init__(inout self, test_name: String):
        self.test_name = test_name
        print("# " + test_name)

    fn assert_true(self, cond: Bool, message: String = ""):
        try:
            if message == "":
                testing.assert_true(cond)
            else:
                testing.assert_true(cond, message)
        except e:
            print(e)

    fn assert_false(self, cond: Bool, message: String = ""):
        try:
            if message == "":
                testing.assert_false(cond)
            else:
                testing.assert_false(cond, message)
        except e:
            print(e)

    fn assert_equal[T: testing.Testable](self, left: T, right: T):
        try:
            testing.assert_equal(left, right)
        except e:
            print(e)
public class FunctionCallTests: PrettyPrintTestCase {
  public func testBasicFunctionCalls() {
    let input =
      """
      let a = myFunc()
      let a = myFunc(var1: 123, var2: "abc")
      let a = myFunc(var1: 123, var2: "abc", var3: Bool, var4: (1, 2, 3))
      let a = myFunc(var1, var2, var3)
      let a = myFunc(var1, var2, var3, var4, var5, var6)
      let a = myFunc(var1: 123, var2: someFun(var1: "abc", var2: 123, var3: Bool, var4: 1.23))
      """

    let expected =
      """
      let a = myFunc()
      let a = myFunc(var1: 123, var2: "abc")
      let a = myFunc(
        var1: 123,
        var2: "abc",
        var3: Bool,
        var4: (1, 2, 3)
      )
      let a = myFunc(var1, var2, var3)
      let a = myFunc(
        var1,
        var2,
        var3,
        var4,
        var5,
        var6
      )
      let a = myFunc(
        var1: 123,
        var2: someFun(
          var1: "abc",
          var2: 123,
          var3: Bool,
          var4: 1.23
        )
      )

      """

    assertPrettyPrintEqual(input: input, expected: expected, linelength: 45)
  }

  public func testBasicFunctionClosures() {
    let input =
      """
      funcCall(closure: { < })
      funcCall(closure: { $0 < $1 })
      funcCall(closure: { s1, s2 in s1 < s2 })
      funcCall(closure: { s1, s2 in return s1 < s2})
      funcCall(closure: { s1, s2, s3, s4, s5, s6 in return s1})
      funcCall(closure: { s1, s2, s3, s4, s5, s6, s7, s8, s9, s10 in return s1 })
      funcCall(param1: 123, closure: { s1, s2, s3 in return s1 })
      funcCall(closure: { (s1: String, s2: String) -> Bool in return s1 > s2 })
      """

    let expected =
      """
      funcCall(closure: { < })
      funcCall(closure: { $0 < $1 })
      funcCall(closure: { s1, s2 in
        s1 < s2
      })
      funcCall(closure: { s1, s2 in
        return s1 < s2
      })
      funcCall(closure: {
        s1, s2, s3, s4, s5, s6 in
        return s1
      })
      funcCall(closure: {
        s1, s2, s3, s4, s5, s6, s7, s8, s9, s10
          in
        return s1
      })
      funcCall(
        param1: 123,
        closure: { s1, s2, s3 in
          return s1
        }
      )
      funcCall(closure: {
        (s1: String, s2: String) -> Bool in
        return s1 > s2
      })

      """

    assertPrettyPrintEqual(input: input, expected: expected, linelength: 42)
  }

  public func testTrailingClosure() {
    let input =
      """
      funcCall() { $1 < $2 }
      funcCall(param1: 2) { $1 < $2 }
      funcCall(param1: 2) { s1, s2, s3 in return s1}
      funcCall(param1: 2) { s1, s2, s3, s4, s5 in return s1}
      """

    let expected =
      """
      funcCall() { $1 < $2 }
      funcCall(param1: 2) { $1 < $2 }
      funcCall(param1: 2) { s1, s2, s3 in
        return s1
      }
      funcCall(param1: 2) {
        s1, s2, s3, s4, s5 in
        return s1
      }

      """

    assertPrettyPrintEqual(input: input, expected: expected, linelength: 40)
  }
}
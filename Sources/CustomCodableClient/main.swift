import CustomCodable

let a = 17
let b = 25

let (result, code) = #stringify(a + b)

print("The value \(result) was produced by the code \"\(code)\"")

@CustomCodable
struct CustomCodableString: Codable {
    @CodableKey(name: "OtherName")
    var propertyWithOtherName: String
    var propertyWithSameName: Bool
}

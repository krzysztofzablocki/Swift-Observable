
//! puting that inside generic crashes SWIFT compiler (as in Beta 3)
enum ObservingType : Int {
  case WillSet = 0, DidSet
}

struct Observable<T> {
  var raw : T {
    willSet {
      if let list = observingInfo[.WillSet] {
        for closure in list {
          closure(newValue, self.raw)
        }
      }
    }
  
    didSet {
      if let list = observingInfo[.DidSet] {
        for closure in list {
          closure(self.raw, oldValue)
        }
      }
    }
  }
  
  init(_ value : T) {
    self.raw = value
    observingInfo[.WillSet] = Array<(T, T) -> ()>()
    observingInfo[.DidSet] = Array<(T, T) -> ()>()
  }
  
  var observingInfo = [ObservingType : Array<(T, T) -> ()>]()
  
  mutating func addObserver(type: ObservingType, closure : (T, T) -> ()) {
    var expandedArray : Array<(T, T) -> ()> = observingInfo[type]!
    expandedArray.append(closure)
    observingInfo[type] = expandedArray
    observingInfo
  }
  
  func __conversion() -> T {
    return raw
  }
}

class Foo {
  var x = Observable(20)
}

let object = Foo()

object.x.addObserver(.WillSet) {
  println("Will set value to \($0) curValue \($1)")
}

object.x.addObserver(.DidSet) {
  println("Did set value to \($0) oldValue \($1)")
}

object.x.raw = 616

//! shows how Observable can be used with normal functions (that don't need to know about Observable existance)
func printInt(value : Int) {
  println("printing \(value)")
}

printInt(object.x)

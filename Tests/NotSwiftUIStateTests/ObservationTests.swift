import XCTest
import Observation
@testable import NotSwiftUIState

fileprivate var sampleBodyCount = 0
fileprivate var nestedBodyCount = 0

@Observable
fileprivate final class ObservableModel {
    var counter: Int = 0
}

final class ObservationTests: XCTestCase {
    override func setUp() {
        sampleBodyCount = 0
        nestedBodyCount = 0
    }
    
    func testSimple() {
        struct Nested: View {
            @State var model = ObservableModel()
            var body: some View {
                Button("\(model.counter)") {
                    model.counter += 1
                }
            }
        }
        
        struct Sample: View {
            @State var model = ObservableModel()
            var body: some View {
                Button("\(model.counter)") {
                    model.counter += 1
                }
                Nested()
            }
        }
        
        let s = Sample()
        let node = Node()
        s.buildNodeTree(node)
        var button: Button {
            node.children[0].children[0].view as! Button
        }
        var nestedNode: Node {
            node.children[0].children[1]
        }
        var nestedButton: Button {
            nestedNode.children[0].view as! Button
        }
        XCTAssertEqual(button.title, "0")
        XCTAssertEqual(nestedButton.title, "0")
        
        nestedButton.action()
        node.rebuildIfNeeded()
        
        XCTAssertEqual(button.title, "0")
        XCTAssertEqual(nestedButton.title, "1")
        
        button.action()
        node.rebuildIfNeeded()

        XCTAssertEqual(button.title, "1")
        XCTAssertEqual(nestedButton.title, "1")
    }
    
    func testBindings() {
        struct Nested: View {
            var model: ObservableModel
            var body: some View {
                Button("\(model.counter)") {
                    model.counter += 1
                }
            }
        }
        
        struct Sample: View {
            @State var model = ObservableModel()
            var body: some View {
                Nested(model: model)
            }
        }
        
        let s = Sample()
        let node = Node()
        s.buildNodeTree(node)
        var nestedNode: Node {
            node.children[0]
        }
        var nestedButton: Button {
            nestedNode.children[0].view as! Button
        }
        XCTAssertEqual(nestedButton.title, "0")
        
        nestedButton.action()
        node.rebuildIfNeeded()
        
        XCTAssertEqual(nestedButton.title, "1")
    }

    func testUnusedBinding() {
        struct Nested: View {
            var model: ObservableModel
            var body: some View {
                Button("") {
                    model.counter += 1
                }
                .debug { nestedBodyCount += 1 }
            }
        }
        
        struct Sample: View {
            @State var model = ObservableModel()
            var body: some View {
                Button("\(model.counter)") {}
                Nested(model: model)
                    .debug { sampleBodyCount += 1 }
            }
        }
        
        let s = Sample()
        let node = Node()
        s.buildNodeTree(node)
        var nestedNode: Node {
            node.children[0].children[1]
        }
        var nestedButton: Button {
            nestedNode.children[0].view as! Button
        }
        XCTAssertEqual(sampleBodyCount, 1)
        XCTAssertEqual(nestedBodyCount, 1)

        nestedButton.action()
        node.rebuildIfNeeded()

        XCTAssertEqual(sampleBodyCount, 2)
        XCTAssertEqual(nestedBodyCount, 1)

    }
}


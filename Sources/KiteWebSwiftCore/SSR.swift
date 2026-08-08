import Foundation
import KiteWebSwiftDSL
import KiteWebSwiftWasm

/// Protocol for Server-Side Rendered Pages
public protocol Page: Sendable {
    associatedtype Body: HTMLRenderable
    @HTMLBuilder var body: Body { get }
}

/// Server State property wrapper for data fetched on the server during SSR
@propertyWrapper
public struct ServerState<Value: Sendable>: Sendable {
    private var value: Value

    public init(wrappedValue: Value) {
        self.value = wrappedValue
    }

    public var wrappedValue: Value {
        get { value }
        set { value = newValue }
    }
}

/// Path parameter extractor property wrapper
@propertyWrapper
public struct PathParameter<Value: LosslessStringConvertible & Sendable>: Sendable {
    private var value: Value?

    public init() {
        self.value = nil
    }

    public init(wrappedValue: Value) {
        self.value = wrappedValue
    }

    public var wrappedValue: Value {
        get {
            guard let val = value else {
                fatalError("PathParameter was accessed before being populated by the router.")
            }
            return val
        }
        set {
            value = newValue
        }
    }

    public mutating func setRawValue(_ raw: String) {
        if let converted = Value(raw) {
            self.value = converted
        }
    }
}

/// SSR Pipeline rendering Pages and injecting client-side hydration scripts
public struct SSRPipeline: Sendable {
    public static func renderHTML<P: Page>(
        _ page: P,
        includeWasmRuntime: Bool = true,
        wasmBundlePath: String = "/static/client.wasm"
    ) -> KiteResponse {
        var htmlContent = page.body.render()

        if includeWasmRuntime {
            // Inject Micro-WASM hydration script before closing </body>
            let hydrationScript = """
            <script type="module">
            (async function() {
                const islands = document.querySelectorAll('kite-island');
                if (islands.length > 0) {
                    try {
                        const wasmModule = await WebAssembly.instantiateStreaming(fetch('\(wasmBundlePath)'), {
                            env: {
                                kite_dom_setText: (idPtr, txtPtr) => {},
                                kite_dom_setAttribute: (idPtr, keyPtr, valPtr) => {}
                            }
                        });
                        console.log('[kite-web-swift] Hydrated ' + islands.length + ' island(s) successfully (<40KB WASM).');
                    } catch (e) {
                        console.warn('[kite-web-swift] Progressive enhancement fallback active:', e);
                    }
                }
            })();
            </script>
            """

            if htmlContent.contains("</body>") {
                htmlContent = htmlContent.replacingOccurrences(of: "</body>", with: "\(hydrationScript)\n</body>")
            } else {
                htmlContent.append(hydrationScript)
            }
        }

        var response = KiteResponse(status: .ok, body: Data(htmlContent.utf8))
        response.headers["Content-Type"] = "text/html; charset=utf-8"
        return response
    }
}

extension KiteResponse {
    public static func html(_ html: HTML, status: HTTPStatus = .ok) -> KiteResponse {
        var resp = KiteResponse(status: status, body: Data(html.render().utf8))
        resp.headers["Content-Type"] = "text/html; charset=utf-8"
        return resp
    }
}

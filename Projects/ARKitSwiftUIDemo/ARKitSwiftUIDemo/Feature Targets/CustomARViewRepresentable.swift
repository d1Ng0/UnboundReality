import SwiftUI
import ARKit
import RealityKit

struct CustomeARViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> some UIView {
        let view = CustomARView()
//        let session = view.session
//        let config = ARWorldTrackingConfiguration()
//        config.planeDetection = [.horizontal]
//        session.run(config)
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) { }
    
}

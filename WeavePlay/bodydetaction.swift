import SwiftUI
import RealityKit
import ARKit
import Combine

struct ARViewContainer: UIViewControllerRepresentable {
    
    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARViewContainer
        var arView: ARView!
        var character: BodyTrackedEntity?
        var character2: BodyTrackedEntity?
        let characterOffset: SIMD3<Float> = [0, 0, 0]
        let characterAnchor = AnchorEntity()
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
            super.init()
        }
        
        func setupARView() {
            arView = ARView(frame: .zero)
            arView.session.delegate = self
            
            guard ARBodyTrackingConfiguration.isSupported else {
                fatalError("This feature is only supported on devices with an A12 chip")

            }

            let configuration = ARBodyTrackingConfiguration()
            arView.session.run(configuration)
            
            arView.scene.addAnchor(characterAnchor)
            
            var cancellable: AnyCancellable? = nil
            cancellable = Entity.loadBodyTrackedAsync(named: "robot.usdz").sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        print("Error: Unable to load model: \(error.localizedDescription)")
                    }
                    cancellable?.cancel()
                }, receiveValue: { (character: Entity) in
                    if let character = character as? BodyTrackedEntity {
                        character.scale = [1.0, 1.0, 1.0]
                        self.character = character
                        self.character2 = character
                        cancellable?.cancel()
                    } else {
                        print("Error: Unable to load model as BodyTrackedEntity")
                    }
                })
        }
        
        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            for anchor in anchors {
                guard let bodyAnchor = anchor as? ARBodyAnchor else { continue }
                
                let bodyPosition = simd_make_float3(bodyAnchor.transform.columns.3)
                characterAnchor.position = bodyPosition + characterOffset
                characterAnchor.orientation = Transform(matrix: bodyAnchor.transform).rotation
                
                if let character = character2, character.parent == nil {
                    characterAnchor.addChild(character)
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        context.coordinator.setupARView()
        viewController.view.addSubview(context.coordinator.arView)
        context.coordinator.arView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            context.coordinator.arView.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            context.coordinator.arView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
            context.coordinator.arView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            context.coordinator.arView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor)
        ])
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct ARview: View {
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}
// SwiftUI 预览
#Preview {
    ARview()
}

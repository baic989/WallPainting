//
//  Wall.swift
//  NaiveWallPainting
//
//  Created by Hrvoje Baic on 07.06.2021..
//

import ARKit

class WallNode: SCNNode {

    // MARK: - Properties

    let meshNode: SCNNode

    // MARK: - Lifecyle

    init(anchor: ARPlaneAnchor, in sceneView: ARSCNView) {

        guard let meshGeometry = ARSCNPlaneGeometry(device: sceneView.device!)
            else { fatalError("Can't create plane geometry") }
        meshGeometry.update(from: anchor.geometry)
        meshNode = SCNNode(geometry: meshGeometry)

        super.init()

        self.setupMeshVisualStyle()
        addChildNode(meshNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Helpers

    private func setupMeshVisualStyle() {
        meshNode.opacity = 0.7
        guard let material = meshNode.geometry?.firstMaterial
            else { fatalError("ARSCNPlaneGeometry always has one material") }
        material.diffuse.contents = UIColor.lightGray
    }
}

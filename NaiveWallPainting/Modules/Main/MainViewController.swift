//
//  ViewController.swift
//  NaiveWallPainting
//
//  Created by Hrvoje Baic on 07.06.2021..
//

import UIKit
import ARKit
import SceneKit
import RealityKit
import Photos

class MainViewController: UIViewController {

    // MARK: - Properties

    private var selectedWall: SCNNode?
    private var selectedColor: UIColor?
    private let colors: [UIColor] = [.red, .green, .brown, .purple]

    // MARK: - Outlets

    @IBOutlet private var arView: ARSCNView!
    @IBOutlet private var statusLabel: UILabel!
    @IBOutlet private var statusView: UIVisualEffectView!
    @IBOutlet private var colorsContainerView: UIView!
    @IBOutlet var colorsCollectionView: UICollectionView!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupAR()
    }

    // MARK: - Helpers

    private func updateStatusLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        if selectedWall == nil {
            var message: String
            switch trackingState {
            case .normal where frame.anchors.isEmpty:
                message = "Move the device around to detect walls."
            case .notAvailable:
                message = "Tracking unavailable."
            case .limited(.excessiveMotion):
                message = "Tracking limited - Move the device more slowly."
            case .limited(.insufficientFeatures):
                message = "Tracking limited - Point the device at an area with visible surface detail, or improve lighting conditions."
            case .limited(.initializing):
                message = "Initializing AR session."
            default:
                message = "Tap the wall to select it."
            }

            statusLabel.text = message
        }
    }

    private func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.vertical]
        arView.session.run(configuration, options: [.resetTracking])
    }

    // MARK: - Actions

    @IBAction func takeScreenshot() {
        let takeScreenshotBlock = { [weak self] in
            guard let self = self else { return }
            UIImageWriteToSavedPhotosAlbum(self.arView.snapshot(), nil, nil, nil)
            DispatchQueue.main.async {
                let flashOverlay = UIView(frame: self.arView.frame)
                flashOverlay.backgroundColor = UIColor.white
                self.arView.addSubview(flashOverlay)
                UIView.animate(withDuration: 0.25, animations: {
                    flashOverlay.alpha = 0.0
                }, completion: { _ in
                    flashOverlay.removeFromSuperview()
                })
            }
        }

        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            takeScreenshotBlock()
        case .restricted, .denied:
            let title = "Photos access denied"
            let message = "Please enable Photos access for this application in Settings > Privacy to allow saving screenshots."
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (authorizationStatus) in
                if authorizationStatus == .authorized {
                    takeScreenshotBlock()
                }
            })
        default:
            break
        }
    }

    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let tapLocation: CGPoint = sender.location(in: arView)
        if let targetPlane = arView.hitTest(tapLocation, options: [.firstFoundOnly: true]).first {
            if targetPlane.node == selectedWall {
                if let color = selectedColor {
                    targetPlane.node.opacity = 1
                    targetPlane.node.geometry?.materials.first?.diffuse.contents = color
                    statusLabel.text = "Looks good!"
                } else {
                    statusLabel.text = "You must select the color first."
                }
            } else {
                selectedWall = targetPlane.node
                statusLabel.text = "You have selected a wall, now choose a color to apply the paint."
            }
        } else {
            statusLabel.text = "There is no surface detected, move the camera around to scan."
        }
    }

    // MARK: - Setup

    private func setupViews() {

        // Prevent the screen from being dimmed after a while
        UIApplication.shared.isIdleTimerDisabled = true

        colorsCollectionView.registerWithNib(PersonalizationItemCollectionViewCell.self)
    }

    private func setupAR() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.vertical]
        arView.session.run(configuration)
        arView.session.delegate = self

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        arView.addGestureRecognizer(tapRecognizer)
    }
}

// MARK: - ARSCNViewDelegate

extension MainViewController: ARSCNViewDelegate {

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let plane = WallNode(anchor: planeAnchor, in: arView)
        node.addChildNode(plane)
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Update only anchors and nodes set up by `renderer(_:didAdd:for:)`.
        guard let planeAnchor = anchor as? ARPlaneAnchor,
            let plane = node.childNodes.first as? WallNode
            else { return }

        // Update ARSCNPlaneGeometry to the anchor's new estimated shape.
        if let planeGeometry = plane.meshNode.geometry as? ARSCNPlaneGeometry {
            planeGeometry.update(from: planeAnchor.geometry)
        }
    }
}

// MARK: - ARSessionDelegate

extension MainViewController: ARSessionDelegate {

    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateStatusLabel(for: frame, trackingState: frame.camera.trackingState)
    }

    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateStatusLabel(for: frame, trackingState: frame.camera.trackingState)
    }

    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateStatusLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        statusLabel.text = "Session failed: \(error.localizedDescription)"
        guard error is ARError else { return }

        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]

        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")

        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "The AR session failed.", message: errorMessage, preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
                alertController.dismiss(animated: true, completion: nil)
                self.resetTracking()
            }
            alertController.addAction(restartAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

// MARK: - Extension UICollectionViewDelegateFlowLayout

extension MainViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 70, height: 70)
    }
}

// MARK: - Extension UICollectionViewDataSource

extension MainViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as PersonalizationItemCollectionViewCell
        cell.configureWith(color: colors[indexPath.item])

        return cell
    }
}

// MARK: - Extension UICollectionViewDelegate

extension MainViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedColor = colors[indexPath.item]
        if let node = selectedWall {
            node.opacity = 1
            node.geometry?.materials.first?.diffuse.contents = colors[indexPath.item]
        }
    }
}

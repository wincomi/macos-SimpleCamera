//
//  ViewController.swift
//  SimpleCamera
//

import Cocoa
import AVFoundation

class ViewController: NSViewController {
	private var previewLayer: AVCaptureVideoPreviewLayer?
	private var videoSession: AVCaptureSession?
	private var cameraDevice: AVCaptureDevice?

	override func viewDidLoad() {
		super.viewDidLoad()

		switch AVCaptureDevice.authorizationStatus(for: .video) {
		case .authorized:
			// The user has previously granted access to the camera.
			DispatchQueue.main.async {
				self.prepareCamera()
				self.startSession()
			}
		case .notDetermined:
			// The user has not yet been asked for camera access.
			AVCaptureDevice.requestAccess(for: .video) { granted in
				if granted {
					DispatchQueue.main.async {
						self.prepareCamera()
						self.startSession()
					}
				}
			}
		case .denied:
			// The user has previously denied access.
			return
		case .restricted:
			// The user can't grant access due to restrictions.
			return
		@unknown default:
			return
		}
	}

	override var representedObject: Any? {
		didSet {
			// Update the view, if already loaded.
		}
	}
}

private extension ViewController {
	func prepareCamera() {
		videoSession = AVCaptureSession()
		guard let videoSession = videoSession else { return }
		videoSession.sessionPreset = .photo

		previewLayer = AVCaptureVideoPreviewLayer(session: videoSession)
		guard let previewLayer = previewLayer else { return }
		previewLayer.videoGravity = .resizeAspectFill

		let devices = AVCaptureDevice.devices()

		for device in devices {
			guard device.hasMediaType(.video) else { return }

			cameraDevice = device

			guard let cameraDevice = cameraDevice else { return }

			do {
				let input = try AVCaptureDeviceInput(device: cameraDevice)

				if videoSession.canAddInput(input) {
					videoSession.addInput(input)
				}

				guard let connection = self.previewLayer?.connection else { return }

				if connection.isVideoMirroringSupported {
					connection.automaticallyAdjustsVideoMirroring = false
					connection.isVideoMirrored = true
				}

				previewLayer.frame = self.view.bounds
				view.layer = previewLayer
				view.wantsLayer = true
			} catch {
				print(error.localizedDescription)
			}
		}

		let videoOutput = AVCaptureVideoDataOutput()
		videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sampleBufferDelegate"))

		if videoSession.canAddOutput(videoOutput) {
			videoSession.addOutput(videoOutput)
		}
	}

	func startSession() {
		guard let videoSession = videoSession, !videoSession.isRunning else { return }
		videoSession.startRunning()
	}

	func stopSession() {
		guard let videoSession = videoSession, videoSession.isRunning else { return }
		videoSession.stopRunning()
	}
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

}

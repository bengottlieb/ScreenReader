//
//  ScreenReader.swift
//  ScreenReader
//
//  Created by Ben Gottlieb on 1/16/22.
//

import SwiftUI
import CoreGraphics
import UIKit
import Vision

public class ScreenReader {
	var image: UIImage
	var strings: [String]?
	
	public init?(view: UIView) {
		UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
		guard let context = UIGraphicsGetCurrentContext() else { return nil }
		defer { UIGraphicsEndImageContext() }
		view.layer.render(in: context)

		guard let capturedImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
		self.image = capturedImage
	}
	
	public func check(for text: String) async -> Bool {
		let strings = await buildStrings()
		let lower = text.lowercased()
		return strings.contains { $0.contains(lower) }
	}
	
	public func check(for texts: [String]) async -> Bool {
		let strings = await buildStrings()
		for text in texts {
			let lower = text.lowercased()
			if !strings.contains(where: { $0.contains(lower) }) { return false }
		}
		return true
	}
	

	@discardableResult func buildStrings() async -> [String] {
		if let strings = self.strings { return strings }
		guard let cgImage = image.cgImage else { return [] }
		
		let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])
		
		var results: [String] = []
		
		let request = VNRecognizeTextRequest() { request, error in
			if let observations = request.results as? [VNRecognizedTextObservation] {
				results += observations.map { $0.string }
			}
			
			self.strings = results.map { $0.lowercased() }
		}
		
		do {
			try handler.perform([request])
		} catch {
			print("failed request: \(error)")
		}
		
		return self.strings ?? []
	}
}

extension VNRecognizedTextObservation {
	var string: String {
		topCandidates(1).first?.string ?? ""
	}
}

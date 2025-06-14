//
//  ZoomControlsView.swift
//  SheetMusicDemo
//
//  UI controls for zoom functionality.
//

import SwiftUI

struct ZoomControlsView: View {
    @Binding var zoomLevel: Double
    let onZoomIn: () -> Void
    let onZoomOut: () -> Void
    let onReset: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Title
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.green)
                Text("Zoom")
                    .font(.headline)
                Spacer()
            }
            
            // Current zoom display
            HStack {
                Text("Current:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(zoomLevel * 100))%")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(zoomLevel == 1.0 ? .secondary : .primary)
            }
            
            // Zoom slider
            VStack(spacing: 8) {
                HStack {
                    Text("10%")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Slider(value: $zoomLevel, in: 0.1...5.0, step: 0.1)
                        .accentColor(.green)
                    
                    Text("500%")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                // Zoom level markers
                HStack {
                    ForEach([0.5, 0.75, 1.0, 1.25, 1.5, 2.0], id: \.self) { level in
                        Button(action: {
                            zoomLevel = level
                        }) {
                            Text("\(Int(level * 100))%")
                                .font(.caption2)
                                .fontWeight(abs(zoomLevel - level) < 0.05 ? .bold : .regular)
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(abs(zoomLevel - level) < 0.05 ? .green : .secondary)
                        
                        if level != 2.0 {
                            Spacer()
                        }
                    }
                }
            }
            
            // Control buttons
            HStack(spacing: 16) {
                // Zoom out
                Button(action: onZoomOut) {
                    HStack(spacing: 4) {
                        Image(systemName: "minus.magnifyingglass")
                        Text("Zoom Out")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(zoomLevel <= 0.1)
                
                // Reset
                Button(action: onReset) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("100%")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(abs(zoomLevel - 1.0) < 0.05)
                
                // Zoom in
                Button(action: onZoomIn) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.magnifyingglass")
                        Text("Zoom In")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(zoomLevel >= 5.0)
            }
            
            // Help text
            Text("Adjust zoom level from 10% to 500%. Use the slider or buttons for precise control.")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

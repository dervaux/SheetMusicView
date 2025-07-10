//
//  FileBasedExample.swift
//  SheetMusicDemo
//
//  Demonstrates using SheetMusicView with filename instead of XML content.
//

import SwiftUI
import SheetMusicView

struct FileBasedExample: View {
    @State private var transposeSteps: Int = 0
    @State private var isLoading: Bool = false
    @State private var zoomLevel: Double = 1.0
    @State private var lastError: SheetMusicError?
    @State private var showingError: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("File-Based Sheet Music View")
                .font(.title)
                .padding()
            
            Text("This example loads music from a .musicxml file in the app bundle")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Controls
            VStack(spacing: 12) {
                HStack {
                    Text("Transpose:")
                    Stepper(value: $transposeSteps, in: -12...12) {
                        Text("\(transposeSteps) semitones")
                    }
                }
                
                HStack {
                    Text("Zoom:")
                    Slider(value: $zoomLevel, in: 0.5...3.0, step: 0.1) {
                        Text("Zoom Level")
                    }
                    Text("\(zoomLevel, specifier: "%.1f")x")
                        .frame(width: 40)
                }
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .cornerRadius(10)
            
            // Sheet Music View using filename
            GeometryReader { geometry in
                ZStack {
                    Color(.systemBackground)
                    
                    // This is the new filename-based API!
                    SheetMusicView(
                        fileName: "sample", // No need for .musicxml extension
                        transposeSteps: $transposeSteps,
                        isLoading: $isLoading,
                        onError: { error in
                            lastError = error
                            showingError = true
                        },
                        onReady: {
                            print("Sheet music loaded from file!")
                        }
                    )
                    .zoomLevel($zoomLevel)
                    .showTitle()
                    .showComposer()
                    
                    if isLoading {
                        ProgressView("Loading music from file...")
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(8)
                    }
                }
            }
            .frame(height: 400)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .padding()
        .alert("Error Loading Music", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(lastError?.localizedDescription ?? "Unknown error")
        }
    }
}

#if DEBUG
struct FileBasedExample_Previews: PreviewProvider {
    static var previews: some View {
        FileBasedExample()
    }
}
#endif

//
//  FilenameAPIDemo.swift
//  SheetMusicDemo
//
//  Demonstrates the new filename-based API for SheetMusicView
//

import SwiftUI
import SheetMusicView

struct FilenameAPIDemo: View {
    @State private var transposeSteps: Int = 0
    @State private var isLoading: Bool = false
    @State private var zoomLevel: Double = 1.0
    @State private var lastError: SheetMusicError?
    @State private var showingError: Bool = false
    @State private var selectedFileName: String = "sample"
    
    // Available sample files (without extensions)
    private let availableFiles = ["sample", "twinkle", "bach_minuet", "chord_progression"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("Filename-Based API Demo")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Load MusicXML files directly by filename")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // File Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select File:")
                        .font(.headline)
                    
                    Picker("File", selection: $selectedFileName) {
                        ForEach(availableFiles, id: \.self) { fileName in
                            Text(fileName.capitalized)
                                .tag(fileName)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding(.horizontal)
                
                // Controls
                VStack(spacing: 12) {
                    HStack {
                        Text("Transpose:")
                        Spacer()
                        Stepper(value: $transposeSteps, in: -12...12) {
                            Text("\(transposeSteps) semitones")
                        }
                    }
                    
                    HStack {
                        Text("Zoom:")
                        Slider(value: $zoomLevel, in: 0.5...3.0, step: 0.1)
                        Text("\(zoomLevel, specifier: "%.1f")x")
                            .frame(width: 50)
                    }
                }
                .padding()
                .background(Color(.systemGroupedBackground))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Sheet Music View using the NEW filename-based API
                GeometryReader { geometry in
                    ZStack {
                        Color(.systemBackground)
                        
                        // This demonstrates the new API!
                        SheetMusicView(
                            musicXMLfileName: selectedFileName, // Just the filename, no extension needed!
                            transposeSteps: $transposeSteps,
                            isLoading: $isLoading,
                            zoomLevel: $zoomLevel,
                            onError: { error in
                                lastError = error
                                showingError = true
                                print("Error loading file '\(selectedFileName)': \(error.localizedDescription)")
                            },
                            onReady: {
                                print("Successfully loaded '\(selectedFileName).musicxml'!")
                            }
                        )
                        .showTitle()
                        .showComposer()
                        .showInstrumentName()
                        
                        if isLoading {
                            VStack {
                                ProgressView()
                                Text("Loading \(selectedFileName).musicxml...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(8)
                            .shadow(radius: 4)
                        }
                    }
                }
                .frame(height: 400)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .alert("File Loading Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(lastError?.localizedDescription ?? "Unknown error occurred while loading the file.")
        }
    }
}

// MARK: - Comparison View
struct APIComparisonView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("API Comparison")
                    .font(.title)
                    .fontWeight(.bold)
                
                // Old API
                VStack(alignment: .leading, spacing: 8) {
                    Text("Old XML-Based API:")
                        .font(.headline)
                        .foregroundColor(.red)
                    
                    Text("""
                    @State private var musicXML: String = ""
                    
                    // Load file manually
                    if let path = Bundle.main.path(forResource: "sample", ofType: "musicxml"),
                       let xml = try? String(contentsOfFile: path) {
                        musicXML = xml
                    }
                    
                    // Use in view
                    SheetMusicView(xml: $musicXML, ...)
                    """)
                    .font(.system(.caption, design: .monospaced))
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // New API
                VStack(alignment: .leading, spacing: 8) {
                    Text("New File-Based API:")
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    Text("""
                    // That's it! No manual file loading needed.
                    SheetMusicView(musicXMLfileName: "sample", ...)
                    """)
                    .font(.system(.caption, design: .monospaced))
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Text("Benefits:")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("• Automatic file extension detection (.musicxml, .xml)")
                    Text("• Built-in error handling")
                    Text("• Cleaner, more declarative code")
                    Text("• No manual file loading required")
                    Text("• Automatic bundle resource management")
                }
                .font(.body)
            }
            .padding()
        }
    }
}

#if DEBUG
struct FilenameAPIDemo_Previews: PreviewProvider {
    static var previews: some View {
        FilenameAPIDemo()
    }
}
#endif

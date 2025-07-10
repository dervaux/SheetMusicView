//
//  FileURLDemoView.swift
//  SheetMusicDemo
//
//  Demonstrates the new fileURL-based initializer with file picker integration.
//

import SwiftUI
import SheetMusicView
import UniformTypeIdentifiers

struct FileURLDemoView: View {
    @State private var selectedFileURL: URL?
    @State private var transposeSteps: Int = 0
    @State private var zoomLevel: Double = 0.65
    @State private var isLoading: Bool = false
    @State private var lastError: SheetMusicError?
    @State private var showingError: Bool = false
    @State private var showingFilePicker: Bool = false
    @State private var showTitle: Bool = false
    @State private var showInstrumentName: Bool = false
    @State private var showComposer: Bool = false
    @State private var showDebugPanel: Bool = false
    @State private var isControlPanelExpanded: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(.systemBackground)
                    .ignoresSafeArea()

                // Sheet Music Display
                if let fileURL = selectedFileURL {
                    SheetMusicView(
                        fileURL: fileURL,
                        transposeSteps: $transposeSteps,
                        isLoading: $isLoading,
                        onError: { error in
                            lastError = error
                            showingError = true
                        },
                        onReady: {
                            print("Sheet music loaded from URL: \(fileURL.path)")
                        }
                    )
                    .zoomLevel($zoomLevel)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 2)
                    .padding()
                } else {
                    // Placeholder when no file is selected
                    VStack(spacing: 24) {
                        Image(systemName: "doc.badge.plus")
                            .font(.system(size: 64))
                            .foregroundColor(.secondary)

                        VStack(spacing: 8) {
                            Text("Select a MusicXML file")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)

                            Text("Clean sheet music display with 65% zoom")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Button("Pick File") {
                            showingFilePicker = true
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                }

                // Loading overlay
                if isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()

                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading music...")
                            .font(.headline)
                    }
                    .padding(24)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 8)
                }
            }
            .navigationTitle("File Picker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if selectedFileURL != nil {
                        Button("New File") {
                            showingFilePicker = true
                        }
                    }
                }
            }
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: [
                    UTType(filenameExtension: "musicxml") ?? UTType.xml,
                    UTType.xml
                ],
                allowsMultipleSelection: false
            ) { result in
                handleFileSelection(result)
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(lastError?.localizedDescription ?? "Unknown error occurred")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }


    
    // MARK: - Helper Methods
    
    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                selectedFileURL = url
                print("Selected file: \(url.path)")
            }
        case .failure(let error):
            lastError = SheetMusicError.loadingFailed("Failed to select file: \(error.localizedDescription)")
            showingError = true
        }
    }
}

#if DEBUG
struct FileURLDemoView_Previews: PreviewProvider {
    static var previews: some View {
        FileURLDemoView()
    }
}
#endif

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
    @State private var zoomLevel: Double = 1.0
    @State private var isLoading: Bool = false
    @State private var lastError: SheetMusicError?
    @State private var showingError: Bool = false
    @State private var showingFilePicker: Bool = false
    @State private var showTitle: Bool = true
    @State private var showInstrumentName: Bool = true
    @State private var showComposer: Bool = true
    @State private var showDebugPanel: Bool = false
    @State private var isControlPanelExpanded: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with file selection info
                headerSection
                
                // Sheet Music Display
                sheetMusicSection
                
                // Control Panel
                controlPanelSection
            }
            .navigationTitle("File URL Demo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Pick File") {
                        showingFilePicker = true
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
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            // Current file info
            if let fileURL = selectedFileURL {
                VStack(spacing: 4) {
                    Text(fileURL.lastPathComponent)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("from \(fileURL.deletingLastPathComponent().lastPathComponent)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Loaded using fileURL initializer")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    // Show file path and indicate we're using the new fileURL API
                    HStack(spacing: 4) {
                        Image(systemName: "folder")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Text(fileURL.path)
                            .font(.caption)
                            .foregroundColor(.blue)
                            .fontWeight(.medium)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Text("(URL-based API)")
                            .font(.caption2)
                            .foregroundColor(.blue)
                            .italic()
                    }
                    .padding(.top, 2)
                }
                .padding(.horizontal)
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "doc.badge.plus")
                        .font(.title)
                        .foregroundColor(.secondary)
                    Text("No file selected")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Use the 'Pick File' button to select a MusicXML file")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
            }
            
            Divider()
        }
        .padding(.top)
        .background(Color(.systemGroupedBackground))
    }
    
    private var sheetMusicSection: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color(.systemBackground)
                
                // Sheet Music View using the NEW fileURL-based API!
                if let fileURL = selectedFileURL {
                    SheetMusicView(
                        fileURL: fileURL, // Using the new fileURL parameter!
                        transposeSteps: $transposeSteps,
                        isLoading: $isLoading,
                        zoomLevel: $zoomLevel,
                        onError: { error in
                            lastError = error
                            showingError = true
                        },
                        onReady: {
                            print("Sheet music loaded from URL: \(fileURL.path)")
                        }
                    )
                    .showTitle(showTitle)
                    .showInstrumentName(showInstrumentName)
                    .showComposer(showComposer)
                    .showDebugPanel(showDebugPanel)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 2)
                    .padding()
                } else {
                    // Placeholder when no file is selected
                    VStack(spacing: 16) {
                        Image(systemName: "doc.badge.plus")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("Select a MusicXML file to get started")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Supports .musicxml and .xml files")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Button("Pick File") {
                            showingFilePicker = true
                        }
                        .buttonStyle(.borderedProminent)
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
        }
    }
    
    private var controlPanelSection: some View {
        VStack(spacing: 0) {
            // Collapsible header
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isControlPanelExpanded.toggle()
                }
            }) {
                HStack {
                    Text("Controls")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Spacer()

                    // Quick controls when collapsed
                    if !isControlPanelExpanded {
                        HStack(spacing: 12) {
                            // File action button
                            Button("Pick File") {
                                showingFilePicker = true
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.mini)

                            // Quick transpose
                            HStack(spacing: 4) {
                                Button("-") {
                                    transposeSteps = max(transposeSteps - 1, -12)
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.mini)
                                .disabled(isLoading || selectedFileURL == nil || transposeSteps <= -12)

                                Text("\(transposeSteps)")
                                    .font(.caption)
                                    .frame(minWidth: 20)

                                Button("+") {
                                    transposeSteps = min(transposeSteps + 1, 12)
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.mini)
                                .disabled(isLoading || selectedFileURL == nil || transposeSteps >= 12)
                            }

                            // Quick zoom
                            Text("\(Int(zoomLevel * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Image(systemName: isControlPanelExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGroupedBackground))
            }
            .buttonStyle(.plain)

            Divider()

            // Expandable content
            if isControlPanelExpanded {
                VStack(spacing: 16) {
                    // File Actions
                    VStack(spacing: 12) {
                        Text("File Actions")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack {
                            Button("Pick New File") {
                                showingFilePicker = true
                            }
                            .buttonStyle(.bordered)

                            Spacer()

                            if selectedFileURL != nil {
                                Button("Clear File") {
                                    selectedFileURL = nil
                                    transposeSteps = 0
                                    zoomLevel = 1.0
                                }
                                .buttonStyle(.bordered)
                                .foregroundColor(.red)
                            }
                        }
                    }

                    Divider()

                    // Transposition Controls
                    VStack(spacing: 12) {
                        Text("Transposition")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack {
                            Button("-1") {
                                transposeSteps = max(transposeSteps - 1, -12)
                            }
                            .buttonStyle(.bordered)
                            .disabled(isLoading || selectedFileURL == nil || transposeSteps <= -12)

                            Text("\(transposeSteps)")
                                .frame(minWidth: 40)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(4)

                            Button("+1") {
                                transposeSteps = min(transposeSteps + 1, 12)
                            }
                            .buttonStyle(.bordered)
                            .disabled(isLoading || selectedFileURL == nil || transposeSteps >= 12)

                            Spacer()

                            Button("Reset") {
                                transposeSteps = 0
                            }
                            .buttonStyle(.bordered)
                            .disabled(isLoading || transposeSteps == 0)
                        }
                    }

                    Divider()

                    // Zoom Controls
                    VStack(spacing: 12) {
                        Text("Zoom")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack {
                            Button("-") {
                                zoomLevel = max(zoomLevel - 0.1, 0.1)
                            }
                            .buttonStyle(.bordered)
                            .disabled(isLoading || selectedFileURL == nil || zoomLevel <= 0.1)

                            Text("\(Int(zoomLevel * 100))%")
                                .frame(minWidth: 50)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(4)

                            Button("+") {
                                zoomLevel = min(zoomLevel + 0.1, 5.0)
                            }
                            .buttonStyle(.bordered)
                            .disabled(isLoading || selectedFileURL == nil || zoomLevel >= 5.0)

                            Spacer()

                            Button("Reset") {
                                zoomLevel = 1.0
                            }
                            .buttonStyle(.bordered)
                            .disabled(isLoading || abs(zoomLevel - 1.0) < 0.01)
                        }
                    }

                    Divider()

                    // Display Options
                    VStack(spacing: 12) {
                        Text("Display Options")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        VStack(spacing: 8) {
                            Toggle("Show Title", isOn: $showTitle)
                            Toggle("Show Instrument Names", isOn: $showInstrumentName)
                            Toggle("Show Composer", isOn: $showComposer)
                            Toggle("Show Debug Panel", isOn: $showDebugPanel)
                        }
                    }
                    .disabled(isLoading)
                }
                .padding()
                .background(Color(.systemGroupedBackground))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color(.systemGroupedBackground))
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

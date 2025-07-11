//
//  ContentView.swift
//  SheetMusicDemo
//
//  Main view that demonstrates the SheetMusicView package functionality.
//  Now includes both bundle-based and file URL-based demos.
//

import SwiftUI
import SheetMusicView

struct ContentView: View {
    var body: some View {
        TabView {
            BundleFileDemoView()
                .tabItem {
                    Image(systemName: "folder")
                    Text("Bundle Files")
                }

            FileURLDemoView()
                .tabItem {
                    Image(systemName: "doc.badge.plus")
                    Text("Pick File")
                }
        }
    }
}

struct BundleFileDemoView: View {
    @StateObject private var musicLibrary = MusicLibrary()
    @State private var currentFileName: String = ""
    @State private var transposeSteps: Int = 0
    @State private var zoomLevel: Double = 1.0
    @State private var isLoading: Bool = false
    @State private var lastError: SheetMusicError?
    @State private var showingError: Bool = false
    @State private var showingMusicPicker: Bool = false
    @State private var showTitle: Bool = false
    @State private var showInstrumentName: Bool = false
    @State private var showComposer: Bool = false
    @State private var showDebugPanel: Bool = false
    @State private var isControlPanelExpanded: Bool = false
    @State private var leftMargin: Double = 1.0
    @State private var rightMargin: Double = 1.0
    @State private var systemSpacing: Double = 0.0
    @State private var scrollingEnabled: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with music selection and controls
                headerSection
                
                // Sheet Music Display
                sheetMusicSection
                
                // Control Panel
                controlPanelSection
            }
            .navigationTitle("SheetMusicView Demo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Select Music") {
                        showingMusicPicker = true
                    }
                }
            }
            .sheet(isPresented: $showingMusicPicker) {
                MusicPickerView(musicLibrary: musicLibrary) { piece in
                    loadMusicPiece(piece)
                    showingMusicPicker = false
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(lastError?.localizedDescription ?? "Unknown error occurred")
            }
            .onAppear {
                // Load the first piece by default
                if let firstPiece = musicLibrary.pieces.first {
                    loadMusicPiece(firstPiece)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            // Current music info
            if let selectedPiece = musicLibrary.selectedPiece {
                VStack(spacing: 4) {
                    Text(selectedPiece.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("by \(selectedPiece.composer)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(selectedPiece.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    // Show filename and indicate we're using the new API
                    HStack(spacing: 4) {
                        Image(systemName: "doc.text")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text("\(selectedPiece.filename).musicxml")
                            .font(.caption)
                            .foregroundColor(.green)
                            .fontWeight(.medium)
                        Text("(File-based API)")
                            .font(.caption2)
                            .foregroundColor(.green)
                            .italic()
                    }
                    .padding(.top, 2)
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
                
                // Sheet Music View using the NEW fileName-based API!
                // Demonstrates both the new file-based API and modifier API:
                // - fileName parameter loads .musicxml files directly from bundle
                // - Without modifiers: all elements hidden by default
                // - With modifier but no parameter: element shown (.showTitle() = .showTitle(true))
                // - With explicit parameter: use specified value (.showTitle(false))
                if !currentFileName.isEmpty {
                    SheetMusicView(
                        fileName: currentFileName, // Using the new fileName parameter!
                        transposeSteps: $transposeSteps,
                        isLoading: $isLoading,
                        onError: { error in
                            lastError = error
                            showingError = true
                        },
                        onReady: {
                            print("Sheet music loaded from file: \(currentFileName).musicxml")
                        }
                    )
                    .zoomLevel($zoomLevel)
                    .showTitle(showTitle)
                    .showInstrumentName(showInstrumentName)
                    .showComposer(showComposer)
                    .showDebugPanel(showDebugPanel)
                    .pageMargins(left: leftMargin, right: rightMargin, top: 1.0, bottom: 1.0)
                    .systemSpacing(systemSpacing)
                    .scrollingEnabled(scrollingEnabled)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 2)
                    .padding()
                } else {
                    // Placeholder when no music is loaded
                    VStack(spacing: 16) {
                        Image(systemName: "music.note")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("Select a piece of music to get started")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Button("Choose Music") {
                            showingMusicPicker = true
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
                            // Quick transpose
                            HStack(spacing: 4) {
                                Button("-") {
                                    transposeSteps = max(transposeSteps - 1, -12)
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.mini)
                                .disabled(isLoading || currentFileName.isEmpty || transposeSteps <= -12)

                                Text("\(transposeSteps)")
                                    .font(.caption)
                                    .frame(minWidth: 20)

                                Button("+") {
                                    transposeSteps = min(transposeSteps + 1, 12)
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.mini)
                                .disabled(isLoading || currentFileName.isEmpty || transposeSteps >= 12)
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
                            .disabled(isLoading || currentFileName.isEmpty || transposeSteps <= -12)

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
                            .disabled(isLoading || currentFileName.isEmpty || transposeSteps >= 12)

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
                            .disabled(isLoading || currentFileName.isEmpty || zoomLevel <= 0.1)

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
                            .disabled(isLoading || currentFileName.isEmpty || zoomLevel >= 5.0)

                            Spacer()

                            Button("Reset") {
                                zoomLevel = 1.0
                            }
                            .buttonStyle(.bordered)
                            .disabled(isLoading || abs(zoomLevel - 1.0) < 0.01)
                        }
                    }

                    Divider()

                    // Page Margins Controls
                    VStack(spacing: 12) {
                        Text("Page Margins")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        VStack(spacing: 8) {
                            HStack {
                                Text("Left: \(leftMargin, specifier: "%.1f")")
                                    .frame(width: 80, alignment: .leading)
                                Slider(value: $leftMargin, in: 0...50)
                                Button("Reset") {
                                    leftMargin = 1.0
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.mini)
                                .disabled(isLoading || abs(leftMargin - 1.0) < 0.1)
                            }

                            HStack {
                                Text("Right: \(rightMargin, specifier: "%.1f")")
                                    .frame(width: 80, alignment: .leading)
                                Slider(value: $rightMargin, in: 0...50)
                                Button("Reset") {
                                    rightMargin = 1.0
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.mini)
                                .disabled(isLoading || abs(rightMargin - 1.0) < 0.1)
                            }
                        }
                    }
                    .disabled(isLoading)

                    Divider()

                    // System Spacing
                    VStack(spacing: 12) {
                        Text("System Spacing")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        VStack(spacing: 8) {
                            HStack {
                                Text("Spacing: \(systemSpacing, specifier: "%.1f")")
                                    .frame(width: 100, alignment: .leading)
                                Slider(value: $systemSpacing, in: 0...20)
                                Button("Reset") {
                                    systemSpacing = 0.0
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.mini)
                                .disabled(isLoading || abs(systemSpacing - 0.0) < 0.1)
                            }
                        }
                        .help("Controls the spacing between systems (lines of music)")
                    }
                    .disabled(isLoading)

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

                            Divider()

                            Toggle("Enable Scrolling & Zoom", isOn: $scrollingEnabled)
                                .help("When disabled (default), the view is completely fixed. When enabled, allows scrolling and pinch-to-zoom gestures.")
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
    
    private func loadMusicPiece(_ piece: MusicPiece) {
        musicLibrary.selectPiece(piece)
        currentFileName = piece.filename
        print("Loading music file: \(piece.filename).musicxml")
    }
}

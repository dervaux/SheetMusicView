//
//  ContentView.swift
//  SheetMusicDemo
//
//  Main view that demonstrates the SheetMusicView package functionality.
//

import SwiftUI
import SheetMusicView

struct ContentView: View {
    @StateObject private var musicLibrary = MusicLibrary()
    @State private var currentXML: String = ""
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
                
                // Sheet Music View
                // Demonstrates the new modifier API:
                // - Without modifiers: all elements hidden by default
                // - With modifier but no parameter: element shown (.showTitle() = .showTitle(true))
                // - With explicit parameter: use specified value (.showTitle(false))
                if !currentXML.isEmpty {
                    SheetMusicView(
                        xml: $currentXML,
                        transposeSteps: $transposeSteps,
                        isLoading: $isLoading,
                        zoomLevel: $zoomLevel,
                        onError: { error in
                            lastError = error
                            showingError = false
                        },
                        onReady: {
                            print("Sheet music display is ready!")
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
        VStack(spacing: 16) {
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
                    .disabled(isLoading || currentXML.isEmpty || transposeSteps <= -12)

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
                    .disabled(isLoading || currentXML.isEmpty || transposeSteps >= 12)

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
                    Button("-1") {
                        zoomLevel = max(zoomLevel - 0.02, 0.1)
                    }
                    .buttonStyle(.bordered)
                    .disabled(isLoading || currentXML.isEmpty || zoomLevel <= 0.1)

                    Text("\(Int(zoomLevel * 100))%")
                        .frame(minWidth: 50)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(4)

                    Button("+1") {
                        zoomLevel = min(zoomLevel + 0.02, 5.0)
                    }
                    .buttonStyle(.bordered)
                    .disabled(isLoading || currentXML.isEmpty || zoomLevel >= 5.0)

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
    }
    
    // MARK: - Helper Methods
    
    private func loadMusicPiece(_ piece: MusicPiece) {
        musicLibrary.selectPiece(piece)
        currentXML = piece.xmlContent
    }
}

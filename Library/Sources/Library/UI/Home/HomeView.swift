import SwiftUI

public struct HomeView: View {
    @State private var viewModel: HomeViewModel
    private let didLogOut: () -> Void
    private let didSelectMovie: (String) -> Void
    
    public init(deps: LibraryDependencies, didLogOut: @MainActor @escaping () -> Void, didSelectMovie: @MainActor @escaping (String) -> Void) {
        self._viewModel = State(initialValue: HomeViewModel(deps: deps))
        self.didLogOut = didLogOut
        self.didSelectMovie = didSelectMovie
    }
    
    public var body: some View {
        VStack {
            Text("Home")
            Text(viewModel.info)
            Button("Log out") {
                didLogOut()
            }
            
            Text("Latest")
            if (viewModel.episodes.count > 0) {
                ForEach(viewModel.episodes) { item in
                    Button(item.name) {
                        didSelectMovie(item.id)
                    }
                }
            } else if (viewModel.seasons.count > 0) {
                ForEach(viewModel.seasons) { item in
                    Button(item.name) {
                        Task { await viewModel.getEpisodesForSeason(seriesId: item.seriesId, seasonId: item.id) }
                    }
                }
            } else {
                ForEach(viewModel.items) { item in
                    Button(item.name) {
                        Task { await viewModel.getSeasonsForSeries(seriesId: item.id) }
                    }
                }
            }
        }
        .onAppear {
            Task { await viewModel.getMe() }
        }
    }
}

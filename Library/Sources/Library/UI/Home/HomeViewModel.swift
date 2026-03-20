import SwiftUI
import Combine
import JellyfinSDK

struct LibraryItem: Identifiable {
    let id: String
    let name: String
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

struct SeasonItem: Identifiable {
    let id: String
    let name: String
    let seriesId: String
    
    init(id: String, name: String, seriesId: String) {
        self.id = id
        self.name = name
        self.seriesId = seriesId
    }
}

struct EpisodeItem: Identifiable {
    let id: String
    let name: String
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

@Observable
@MainActor
class HomeViewModel {
    var isLoading: Bool = false
    var userId: String = ""
    var info: String = ""
    var items: [LibraryItem] = []
    var seasons: [SeasonItem] = []
    var episodes: [EpisodeItem] = []
    
    private let jellyfinApiClient: JellyfinApiClient
    
    init(deps: LibraryDependencies) {
        self.jellyfinApiClient = deps.jellyfinApiClient
    }
    
    func getMe() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await jellyfinApiClient.users.me()
            info = response.name
            userId = response.id
            await getLatestItems()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getLatestItems() async {
        do {
            let request = ItemsLatestRequest(userId: userId)
            let response = try await jellyfinApiClient.userLibrary.itemsLatest(request: request)
            items = response.map { LibraryItem(id: $0.id, name: $0.name) }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getSeasonsForSeries(seriesId: String) async {
        do {
            let request = SeasonsRequest(seriesId: seriesId, userId: userId)
            let response = try await jellyfinApiClient.tvShows.seasons(request: request)
            seasons = response.items.map { SeasonItem(id: $0.id, name: $0.name, seriesId: $0.seriesId!) }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getEpisodesForSeason(seriesId: String, seasonId: String) async {
        do {
            let request = EpisodesRequest(seriesId: seriesId, userId: userId, seasonId: seasonId)
            let response = try await jellyfinApiClient.tvShows.episodes(request: request)
            episodes = response.items.map { EpisodeItem(id: $0.id, name: $0.name) }
        } catch {
            print(error.localizedDescription)
        }
    }
}

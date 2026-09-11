import Foundation
import Testing
@testable import SonimbusCore

@Test("网易云公开推荐、详情和扫码接口可访问")
func liveAPISmokeTest() async throws {
    guard ProcessInfo.processInfo.environment["NETEASE_API_SMOKE"] == "1" else { return }

    let playlists = try await NeteaseAPI.personalizedPlaylists(limit: 2)
    #expect(!playlists.isEmpty)

    let categories = try await NeteaseAPI.playlistCategories()
    #expect(categories.contains(where: { !$0.name.isEmpty }))

    let detail = try await NeteaseAPI.playlist(id: playlists[0].id)
    #expect(!detail.playlist.name.isEmpty)
    #expect(!detail.playlist.tracks.isEmpty)

    let key = try await NeteaseAPI.qrKey()
    #expect(key.count > 10)
    #expect(NeteaseAPI.qrLoginURL(key: key).contains(key))

    let search = try await NeteaseAPI.search("晴天", type: .songs, limit: 2)
    let tracks = try #require(search.songs)
    let track = try #require(tracks.first)
    #expect(!track.name.isEmpty)

    let lyrics = try await NeteaseAPI.lyrics(id: track.id)
    #expect(lyrics.lrc?.lyric?.isEmpty == false)

    let urls = try await NeteaseAPI.songURLs(ids: [track.id], level: "standard")
    #expect(urls.first?.id == track.id)

    let albums = try await NeteaseAPI.newAlbums(limit: 1)
    let album = try #require(albums.first)
    #expect(try await !NeteaseAPI.album(id: album.id).songs.isEmpty)

    let artists = try await NeteaseAPI.topArtists(limit: 1)
    let artist = try #require(artists.first)
    #expect(try await !NeteaseAPI.artist(id: artist.id).hotSongs.isEmpty)
    _ = try await NeteaseAPI.artistMVs(id: artist.id, limit: 1)

    let mvs = try await NeteaseAPI.personalizedMVs(limit: 1)
    let mv = try #require(mvs.first)
    #expect(try await NeteaseAPI.latestMVs(limit: 12).count > 2)
    let mvDetail = try await NeteaseAPI.mvDetail(id: mv.id)
    #expect(!mvDetail.name.isEmpty)
    let mvStream = try await NeteaseAPI.mvURL(id: mv.id, resolution: 720)
    #expect(mvStream.id == mv.id)
    #expect(mvStream.streamURL != nil)
    #expect(try await NeteaseAPI.search(mv.name, type: .mvs, limit: 1).mvs != nil)
}

@Test("新版歌词接口可直接返回可解析内容")
func liveLyricV1SmokeTest() async throws {
    guard ProcessInfo.processInfo.environment["NETEASE_API_SMOKE"] == "1" else { return }
    let data = try await NeteaseClient.shared.weapi(
        "/song/lyric/v1",
        ["id": 186016, "cp": false, "lv": 0, "kv": 0, "tv": 0, "rv": 0,
         "yv": 0, "ytv": 0, "yrv": 0]
    )
    let response = try NeteaseClient.shared.decoded(LyricResponse.self, from: data)
    #expect(LyricsParser.hasUsableLyrics(response))
    let lyrics = LyricsParser.parse(response)
    #expect(!lyrics.isEmpty)
    #expect(lyrics.lines.map(\.time) == lyrics.lines.map(\.time).sorted())
}

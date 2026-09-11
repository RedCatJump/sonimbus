import Foundation
import Testing
@testable import SonimbusCore

@Test
func decodesBusinessCodeShapes() {
    #expect(NeteaseClient.businessCode(from: 200) == 200)
    #expect(NeteaseClient.businessCode(from: NSNumber(value: 301)) == 301)
    #expect(NeteaseClient.businessCode(from: "512") == 512)
    #expect(NeteaseClient.businessCode(from: nil) == nil)
}

@Test("登录响应包含同名 Cookie 时使用最后一个值")
func duplicateResponseCookiesDoNotCrash() throws {
    let first = try #require(HTTPCookie(properties: [
        .domain: ".music.163.com",
        .path: "/",
        .name: "MUSIC_U",
        .value: "old-token",
    ]))
    let second = try #require(HTTPCookie(properties: [
        .domain: "music.163.com",
        .path: "/weapi",
        .name: "MUSIC_U",
        .value: "new-token",
    ]))
    let csrf = try #require(HTTPCookie(properties: [
        .domain: ".music.163.com",
        .path: "/",
        .name: "__csrf",
        .value: "csrf-token",
    ]))

    let values = NeteaseClient.cookieValues(from: [first, csrf, second])

    #expect(values["MUSIC_U"] == "new-token")
    #expect(values["__csrf"] == "csrf-token")
    #expect(values.count == 2)
}

@Test("登录 Cookie 可以完整归档并恢复")
func authenticationCookiesRoundTrip() throws {
    let cookies = [
        "MUSIC_U": "music-token",
        "__csrf": "csrf-token",
        "NMTID": "device-token",
    ]

    let data = try #require(AuthenticationCookieArchive.encode(cookies))

    #expect(AuthenticationCookieArchive.decode(data) == cookies)
    #expect(AuthenticationCookieArchive.decode(Data("invalid".utf8)) == nil)
}

@Test("播放上报区分最近播放与听歌计数并保留来源")
func playbackLogsMatchUpstreamContract() throws {
    let start = try #require(NeteaseAPI.playbackLog(trackID: 123, sourceID: 456, seconds: nil).first)
    let finish = try #require(NeteaseAPI.playbackLog(trackID: 123, sourceID: 456, seconds: 30).first)
    #expect(start["action"] as? String == "startplay")
    #expect(finish["action"] as? String == "play")
    let startBody = try #require(start["json"] as? [String: Any])
    let finishBody = try #require(finish["json"] as? [String: Any])
    #expect(startBody["id"] as? Int == 123)
    #expect(startBody["content"] as? String == "id=456")
    #expect(startBody["mainsiteWeb"] as? String == "1")
    #expect(startBody["time"] == nil)
    #expect(finishBody["sourceId"] as? String == "456")
    #expect(finishBody["time"] as? Int == 30)
    #expect(finishBody["end"] as? String == "playend")
    #expect(JSONSerialization.isValidJSONObject([start, finish]))
}

@Test("单次 Cookie 覆盖保留认证和设备令牌且不污染后续请求")
func requestCookieOverridesAreScoped() {
    let cookies = ["MUSIC_U": "test-token", "NMTID": "server-device", "os": "pc"]
    let extra = ["os": "pc", "appver": "3.1.17"]
    let overridden = NeteaseClient.cookieHeader(cookies: cookies, extra: extra, overrides: ["os": "osx"])
    #expect(overridden.contains("os=osx"))
    #expect(overridden.contains("MUSIC_U=test-token"))
    #expect(overridden.contains("NMTID=server-device"))
    #expect(NeteaseClient.cookieHeader(cookies: cookies, extra: extra, overrides: [:]).contains("os=pc"))
}

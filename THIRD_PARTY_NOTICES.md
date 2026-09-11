# Third-party notices

## Kumone

- Project: `missuo/kumone`
- Source: https://github.com/missuo/kumone
- Referenced revision: `fe7cec4538b8730640a0780f87cd58aa87bcd572`
- License: GNU Lesser General Public License v3.0 only

The NetEase `weapi`/`eapi` request flow, endpoint mapping, tolerant response models, LRC parsing behavior, and alternate-source provider strategy in this repository are adapted from and informed by Kumone. The alternate-source implementation in this repository was independently written for Swift and does not copy Kumone source code. The tvOS application architecture, television UI, focus interactions, and packaging workflow are original to this repository.

The applicable license text is included at `Licenses/Kumone-LGPL-3.0.txt`.

## UnblockNeteaseMusic server

- Project: `UnblockNeteaseMusic/server`
- Source: https://github.com/UnblockNeteaseMusic/server
- Referenced revision: `1d64281c0fae81a4e3cf21f176706b0baa3a606d`
- License: GNU Lesser General Public License v3.0 only

The Bodian provider request sequence, signing inputs, and compatibility behavior are adapted from and informed by this project. The provider integration, stream-duration validation, and tvOS playback flow in this repository were implemented independently in Swift.

The applicable license text is included at `Licenses/Kumone-LGPL-3.0.txt`.

## NeteaseCloudMusicApiEnhanced

- Project: `NeteaseCloudMusicApiEnhanced/api-enhanced`
- Source: https://github.com/NeteaseCloudMusicApiEnhanced/api-enhanced
- Referenced revision: `d55d92cd0031d7c7746b7068faecd7ade1d354ac`
- License: MIT License

The cloud upload, delete and match request sequence, playlist metadata update endpoints, and related response compatibility behavior are informed by this project. The protocol calls and tvOS interface in this repository were implemented independently in Swift.

The applicable license text is included at `Licenses/NeteaseCloudMusicApiEnhanced-MIT.txt`.

## Upstream review — 2026-09-10

These are source references for native Swift adaptations, not linked Swift or Node packages.

- Kumone: reviewed through v0.3.16 (`fe7cec4`). Adopted recent-play `startplay` reporting, desktop eapi weblog requests, and `/song/lyric/v1` compatibility with classic-endpoint fallback. YRC is converted into timed lines for the existing tvOS lyric UI; translations tolerate timing offsets. SMS login, karaoke UI, Japanese reading generation, CarPlay, and desktop/iOS presentation features are outside this dependency update. Its alternate-provider changes target providers not used here; Sonimbus already uses HTTPS and validates stream duration for Bodian.
- UnblockNeteaseMusic/server: upstream HEAD remains `1d64281`; no update required.
- API Enhanced: reviewed default-branch HEAD `d55d92c` (after v4.40.1). Forward server-issued NMTID in the encrypted eapi header. Sonimbus already absorbs and persists response cookies and does not regenerate NMTID per request, so the Node service's synthetic fallback/retry machinery is not needed. Cloud and playlist endpoint modules are unchanged. Node dependency, packaging, and CI updates do not apply to the Swift app.

Validation covers local regression tests, tvOS compilation, and public API smoke tests. Authenticated server-side recent-play updates and account mutations require account-level verification and are not asserted by public smoke tests.

Simulator acceptance (2026-09-10): installed the updated build on Apple TV 4K (3rd generation), tvOS 26.5 at 1080p, without playback fixtures. Observed live playback progress and timed lyrics for 在这里等你 and 呆头鸟, pause/resume, next-track metadata and lyric refresh, queue open/Back, lyrics hide/show, and return focus to the original recommendation card. The simulator was signed out; authenticated cloud recent-play persistence remains unverified. No 4K layout pass was performed for this protocol-only update.

# Replace Flutter Mock Data with Next.js TypeScript Equivalents

## Context
Flutter mock data lives in `lib/lib/features/*/data/mock/*.dart`. The Next.js app has mock fallbacks only in 2 of 9 API modules (`churches.ts`, `wallet.ts`). All others show empty/error states when the backend is unreachable.

## Files to Create

### `lib/mock/mock-church.ts`
Replicates `church_mock_data.dart` — Grace Community Church profile with banner/avatar.

### `lib/mock/mock-posts.ts`
Replicates `post_mock_data.dart` — 3 posts (one with image + tags, others text-only) and 2 comments with nested replies.

### `lib/mock/mock-campaigns.ts`
Replicates `campaign_mock_data.dart` — 4 campaigns (3 ACTIVE: Medical Expansion, Clean Water, Youth Center; 1 COMPLETED: Food Bank).

### `lib/mock/mock-notifications.ts`
Replicates `notifications_mock_data.dart` — 8 notifications across 6 types (live, like, comment, campaign, follow, mention, system).

### `lib/mock/mock-shorts.ts`
Replicates `short_video_mock_data.dart` — 2 shorts with comments/reflections. Video URLs use Google sample videos.

### `lib/mock/mock-gifts.ts`
Replicates `gift_mock_data.dart` — 6 gift items (Amen $25, Bible $50, Candle $75, Cross $100, Dove $150, Church $500).

### `lib/mock/mock-profile.ts`
Replicates `profile_mock_data.dart` — Beza International org profile with 12.4k subscribers, 42 campaigns, $4150 monthly gifts, 489 peak viewers, 6 short clips, gift/subscriber/live viewer analytics.

### `lib/mock/mock-events.ts`
New — 3 upcoming events at Grace Community Church.

### `lib/mock/mock-livestreams.ts`
New — 2 live streams (Grace Community, Beza International).

### `lib/mock/index.ts`
Barrel file exporting all mock factory functions.

## API Modules to Update (add `.catch()` fallback)

| API Module | Mock Import | Fallback Function |
|---|---|---|
| `lib/api/posts.ts` | `mockPostsResponse, mockPostResponse, mockCommentsResponse` | `apiGetPosts`, `apiGetPost`, `apiGetComments` |
| `lib/api/events.ts` | `mockEventsResponse` | `apiGetEvents` |
| `lib/api/campaigns.ts` | `mockCampaignsResponse, mockCampaignResponse` | `apiGetCampaigns`, `apiGetCampaign` |
| `lib/api/notifications.ts` | `mockNotificationsResponse` | `apiGetNotifications` |
| `lib/api/shorts.ts` | `mockShortsResponse` | `apiGetShorts` |
| `lib/api/livestream.ts` | `mockLiveStreamsResponse, mockLiveStreamResponse` | `apiGetLiveStreams`, `apiGetLiveStream` |
| `lib/api/gifts.ts` | `mockGiftsResponse` | `apiGetGifts` |

## Detailed Mock Data Content

### Posts (`mock-posts.ts`)
- **p1**: Grace Community, "Reflecting on our community gathering...", architecture image, tags [#Spirituality #Community #DigitalFaith], 1200 likes, 2 comments
- **p2**: Beza International, "Sunday Service Highlights", no image, 3400 likes
- **p3**: Grace Community, "Youth Conference 2024", no image, 890 likes
- **Comments**: Marcus Chen (avatarA) + reply from Sarah Jenkins; Sarah Jenkins standalone comment

### Campaigns (`mock-campaigns.ts`)
- **beza-medical-expansion**: 4.25M/8M ETB, 143 donors, 42 days left
- **gojjam-water**: 936K/1.2M ETB, 67 donors, 18 days left
- **youth-discipleship**: 310K/500K ETB, 42 donors, 30 days left
- **food-bank-restock**: 890K/850K ETB (completed), 112 donors

### Notifications (`mock-notifications.ts`)
| ID | Type | Actor | Read? |
|---|---|---|---|
| n1 | live | Grace Community | No |
| n2 | like | Sarah M. | No |
| n3 | comment | Daniel T. | Yes |
| n4 | campaign | Beza Church | No |
| n5 | follow | Hanna K. | Yes |
| n6 | mention | Pastor Elias | No |
| n7 | system | FaithConnect | Yes |
| n8 | campaign | Hope Foundation | Yes |

### Shorts (`mock-shorts.ts`)
- **sv1**: Beza International, Worship Session, 12.4k likes, 856 comments
- **sv2**: Grace Community, Sunday Night Praise, 8.2k likes, 412 comments
- **Comments**: Selamawit T. + reply from Daniel M.; Hanna K.

### Gifts (`mock-gifts.ts`)
| ID | Name | Price |
|---|---|---|
| amen | Amen | $25 |
| bible | Bible | $50 |
| candle | Candle | $75 |
| cross | Cross | $100 |
| dove | Dove | $150 |
| church | Church | $500 |

### Profile (`mock-profile.ts`)
- Organization: Beza International, "Global Ministry Hub"
- Stats: 12.4k subs (+8%), 42 campaigns (+5%), $4150/mo (+12%), 489 peak viewers (+18%)
- 6 short clips with view counts
- Gift summaries by week/month/year/all
- Subscribers summaries with new members
- Live viewer analytics with 5 data points per range

### Events (`mock-events.ts`)
- Sunday Worship Service — Grace Community
- Youth Bible Study — Grace Community
- Community Outreach — Grace Community

### LiveStreams (`mock-livestreams.ts`)
- Grace Community — Sunday Worship (489 viewers)
- Beza International — Evening Prayer (312 viewers)

## Responsive Layout
All pages already have responsive patterns (`lg:hidden` / `hidden lg:block`). No layout changes needed — just adding mock data fallbacks so content renders instead of empty/error states.

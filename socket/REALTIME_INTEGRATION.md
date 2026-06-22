# FaithConnect — Real-Time Socket.IO Integration Guide

Frontend reference for all WebSocket namespaces. This document covers connection, events, and TypeScript types for direct messaging, notifications, group chat, and user location.

> **REST API** (posts, comments, likes, user management, etc.) is documented in Swagger at `/v1/docs`.

---

## Quick-start checklist

1. Call `POST /v1/auth/login` → copy the `accessToken`
2. Install `socket.io-client` v4
3. Connect to the namespace path — **never** the root URL
4. Pass the JWT in the `auth` object (not as an HTTP header)

---

## Authentication

```ts
const socket = io('https://api.yourdomain.com/<namespace>', {
  auth: { token: accessToken },
  transports: ['websocket'],
  reconnection: true,
  reconnectionDelay: 2000,
  reconnectionAttempts: Infinity,
});
```

### Connection lifecycle events (all namespaces)

```ts
socket.on('connect',       () => console.log('connected:', socket.id));
socket.on('disconnect',    (why) => console.log('disconnected:', why));
socket.on('connect_error', (err) => console.error('auth/network error:', err.message));
```

### Error responses (all namespaces)

The server never silently drops a bad event — it always emits `error` back:

```ts
socket.on('error', ({ event, message }) => {
  console.error(`[${event}] rejected:`, message);
});
```

### Token expired

If `connect_error` fires with `WS_AUTH_FAILED`, refresh the token and reconnect:

```ts
socket.on('connect_error', async (err) => {
  if (err.message === 'WS_AUTH_FAILED') {
    socket.auth = { token: await refreshAccessToken() };
    socket.connect();
  }
});
```

---

## Namespace overview

| Namespace        | URL path         | Auto-joined rooms on connect                   |
| ---------------- | ---------------- | ---------------------------------------------- |
| Direct messaging | `/messaging`     | `user:{id}`, `conv:{id}` × all conversations   |
| Notifications    | `/notifications` | `user:{id}`                                    |
| Group chat       | `/groups`        | `user:{id}`, `group:{id}` × all memberships    |
| User location    | `/user-location` | `user:{id}`                                    |

No manual room subscription is needed — rooms are assigned automatically on every connect and reconnect.

> Connecting to `/messaging` or `/groups` also marks the user **online** for [presence tracking](#5-presence--online-status) and broadcasts `presence:online` / `presence:offline` to their conversation/group rooms.

---

## 1. Direct Messaging `/messaging`

1-to-1 real-time chat with replies, typing indicators, and read receipts.

### Connect

```ts
const msgSocket = io('http://localhost:3000/messaging', {
  auth: { token: accessToken },
  transports: ['websocket'],
});
```

---

### Client → Server events

#### `message:send` — send a message

Provide **`conversationId`** (existing conversation) **or** `recipientId` (first message — conversation is auto-created). Never both.

```ts
// Existing conversation
msgSocket.emit('message:send', { conversationId: 'uuid', body: 'Hello!' });

// First message to a user
msgSocket.emit('message:send', { recipientId: 'user-uuid', body: 'Hey!' });
```

---

#### `message:reply` — reply to any message (unlimited nesting)

`replyToId` can be a top-level message or any existing reply. Nesting depth is unlimited.

```ts
msgSocket.emit('message:reply', {
  conversationId: 'uuid',
  replyToId:      'message-uuid',
  body:           'Exactly my thoughts!',
});
```

---

#### `message:update` — edit a message you sent

Only the **original sender** can update a message.

```ts
msgSocket.emit('message:update', {
  messageId: 'uuid',
  body:      'Corrected text',
});
```

---

#### `message:delete` — delete a message (both sides)

**Either participant** can delete any message — both sender and recipient. The message is removed for both sides simultaneously (Telegram-style).

```ts
msgSocket.emit('message:delete', { messageId: 'uuid' });
```

---

#### `message:read` — mark all messages as read

```ts
msgSocket.emit('message:read', { conversationId: 'uuid' });
```

---

#### `typing:start` / `typing:stop` — typing indicator

```ts
msgSocket.emit('typing:start', { conversationId: 'uuid' });
msgSocket.emit('typing:stop',  { conversationId: 'uuid' });
```

---

### Server → Client events

#### `message:new` — a new message arrived

```ts
msgSocket.on('message:new', (message: MessageEvent) => {
  appendToThread(message);
});
```

#### `message:updated` — a message was edited

Full updated message object — same shape as `message:new`.

```ts
msgSocket.on('message:updated', (message: MessageEvent) => {
  replaceInThread(message.id, message);
});
```

#### `message:deleted` — a message was deleted

```ts
msgSocket.on('message:deleted', ({ conversationId, messageId }) => {
  markAsDeleted(messageId);
});
```

#### `conv:read` — the other participant read the conversation

Fired after the other user emits `message:read`. All messages in the conversation sent by the caller are now `isRead: true`.

```ts
msgSocket.on('conv:read', ({ conversationId, readBy }) => {
  // readBy = userId of the person who just read the conversation
  markAllMessagesRead(conversationId, readBy);
});
```

> **How DM read works end-to-end:**
> 1. User B opens the conversation → emits `message:read { conversationId }`.
> 2. Server marks every unread message from A as `isRead: true` / `readAt: <now>` in the DB.
> 3. Server broadcasts `conv:read { conversationId, readBy: B }` to the `conv:{id}` room.
> 4. User A receives `conv:read` and can update their UI (double-tick, etc.).
> 5. Subsequent `GET /v1/messaging/conversations/:id` will return messages with `isRead: true`.

#### `typing:start` / `typing:stop`

```ts
msgSocket.on('typing:start', ({ conversationId, userId }) => showTypingBubble(userId));
msgSocket.on('typing:stop',  ({ conversationId, userId }) => hideTypingBubble(userId));
```

---

### REST for initial data & media uploads

| Purpose                          | Endpoint                                    |
| -------------------------------- | ------------------------------------------- |
| Load conversation list on mount  | `GET /v1/messaging/conversations`           |
| Load paginated messages          | `GET /v1/messaging/conversations/:id?skip=0&take=50` |
| Send a message with media file   | `POST /v1/messaging/conversations` (multipart/form-data) |
| Get unread message count (badge) | `GET /v1/messaging/unread-count`            |
| Block / unblock a user           | `POST/DELETE /v1/messaging/blocks/:userId`  |
| List blocked users               | `GET /v1/messaging/blocks`                  |

> Media uploads via REST automatically broadcast a `message:new` event to the conversation room — no extra socket emit needed.

---

### TypeScript types

```ts
interface MessageSender {
  id: string;
  fullName: string;
  avatarUrl: string | null;
}
interface MessageReplyTo {
  id: string;
  body: string;
  mediaUrl: string | null;
  deletedAt: string | null;
  sender: MessageSender;
}
interface MessageEvent {
  id: string;
  conversationId: string;
  senderId: string;
  replyToId: string | null;
  body: string;
  mediaUrl: string | null;
  isRead: boolean;
  createdAt: string;
  sender: MessageSender;
  replyTo: MessageReplyTo | null;
}
interface MessageDeletedEvent {
  conversationId: string;
  messageId: string;
}
interface ConvReadEvent   { conversationId: string; readBy: string; }
interface TypingDmEvent   { conversationId: string; userId: string; }

// Client → Server payloads
interface SendMessagePayload   { conversationId?: string; recipientId?: string; body: string; mediaUrl?: string; }
interface ReplyMessagePayload  { conversationId: string; replyToId: string; body: string; mediaUrl?: string; }
interface UpdateMessagePayload { messageId: string; body: string; }
interface DeleteMessagePayload { messageId: string; }
interface ConvPayload          { conversationId: string; }
```

---

## 2. Notifications `/notifications`

Live in-app notification delivery. Connect once on login and keep alive.

### Connect

```ts
const notifSocket = io('http://localhost:3000/notifications', {
  auth: { token: accessToken },
  transports: ['websocket'],
});
```

---

### Server → Client events

#### `notification:new` — a new notification arrived

```ts
notifSocket.on('notification:new', (n: NotificationEvent) => {
  incrementBadge();
  prependToList(n);
});
```

#### `notification:marked-read` — one notification was marked read

```ts
notifSocket.on('notification:marked-read', ({ notificationId }) => {
  setItemRead(notificationId);
});
```

#### `notification:all-marked-read` — all notifications cleared

```ts
notifSocket.on('notification:all-marked-read', () => clearBadge());
```

---

### Client → Server events

#### `notification:mark-read`

```ts
notifSocket.emit('notification:mark-read', { notificationId: 'uuid' });
```

#### `notification:mark-all-read`

```ts
notifSocket.emit('notification:mark-all-read');
```

---

### Notification types

| `type` value       | Triggered when                                   |
| ------------------ | ------------------------------------------------ |
| `NEW_MESSAGE`      | You receive a direct message                     |
| `COMMENT_REPLIED`  | Someone replies to your comment                  |
| `COMMENT_LIKED`    | Someone likes your comment                       |
| `POST_COMMENTED`   | Someone comments on your post                    |
| `SHORT_COMMENTED`  | Someone comments on your short                   |
| `CHURCH_NEW_POST`  | A church you follow publishes a post             |
| `CHURCH_NEW_SHORT` | A church you follow publishes a short            |
| `FOLLOW`           | Someone follows you                              |
| `LIKE`             | Someone likes your post                          |

---

### REST for initial data

| Purpose                             | Endpoint                              |
| ----------------------------------- | ------------------------------------- |
| Load notification list on mount     | `GET /v1/notifications?skip=0&take=20` |
| Get unread count (badge)            | `GET /v1/notifications/unread-count`  |
| Mark one read                       | `PATCH /v1/notifications/:id/read`    |
| Mark all read                       | `PATCH /v1/notifications/read-all`    |
| Register FCM device token           | `POST /v1/notifications/devices`      |
| Deregister on logout                | `DELETE /v1/notifications/devices/:deviceId` |
| Get/update notification preferences | `GET/PATCH /v1/notifications/preferences` |

---

### TypeScript types

```ts
interface NotificationEvent {
  id: string;
  recipientUserId: string;
  type: string;
  title: string;
  body: string;
  data: Record<string, unknown> | null;
  isRead: boolean;
  createdAt: string;
}
interface MarkReadPayload { notificationId: string; }
```

---

## 3. Group Chat `/groups`

Group messaging with replies (unlimited nesting), typing indicators, and live membership events.

### Connect

```ts
const groupSocket = io('http://localhost:3000/groups', {
  auth: { token: accessToken },
  transports: ['websocket'],
});
```

---

### Client → Server events

#### `group:message:send` — post a top-level message

Caller must be a group member.

```ts
groupSocket.emit('group:message:send', {
  groupId: 'uuid',
  body:    'Hello everyone!',
});
```

---

#### `group:message:reply` — reply to any message or reply (unlimited nesting)

`parentId` can be any message or existing reply — depth is unlimited.

```ts
groupSocket.emit('group:message:reply', {
  groupId:  'uuid',
  parentId: 'comment-uuid',
  body:     'Great point!',
});
```

---

#### `group:message:update` — edit a message you wrote

Only the **original author** can update a message.

```ts
groupSocket.emit('group:message:update', {
  groupId:   'uuid',
  messageId: 'comment-uuid',
  body:      'Corrected text',
});
```

---

#### `group:message:delete` — delete a message you wrote

Only the **original author** can delete their own message. Group moderators and church owners can delete any message via REST (`DELETE /v1/groups/:id/comments/:commentId`).

```ts
groupSocket.emit('group:message:delete', {
  groupId:   'uuid',
  messageId: 'comment-uuid',
});
```

---

#### `group:message:read` — mark a group message as seen (Telegram-style)

Emit this when the user scrolls a message into view. The server records the read receipt and broadcasts `group:message:seen` to everyone in the group. The message author's own read does **not** generate a receipt.

```ts
groupSocket.emit('group:message:read', {
  groupId:   'uuid',
  messageId: 'comment-uuid',
});
```

---

#### `group:typing:start` / `group:typing:stop`

```ts
groupSocket.emit('group:typing:start', { groupId: 'uuid' });
groupSocket.emit('group:typing:stop',  { groupId: 'uuid' });
```

---

### Server → Client events

#### `group:message:new` — a new top-level message

```ts
groupSocket.on('group:message:new', (comment) => appendToThread(comment));
```

#### `group:message:reply` — a reply was posted

```ts
groupSocket.on('group:message:reply', ({ parentId, reply }) => {
  appendReply(parentId, reply);
});
```

#### `group:message:updated` — a message was edited

```ts
groupSocket.on('group:message:updated', (message) => {
  replaceInThread(message.id, message);
});
```

#### `group:message:deleted` — a message was deleted

```ts
groupSocket.on('group:message:deleted', ({ groupId, messageId }) => {
  markAsDeleted(messageId);
});
```

#### `group:message:seen` — a member read a group message

Fired when any member emits `group:message:read`. Shows a running list of who has seen each message.

```ts
groupSocket.on('group:message:seen', ({ groupId, messageId, userId, seenAt, seenBy }) => {
  // seenBy = { id, fullName, avatarUrl }
  appendSeenReceipt(messageId, seenBy, seenAt);
});
```

> **How group read receipts work end-to-end (Telegram-style):**
> 1. A group member scrolls message into view → client emits `group:message:read { groupId, messageId }`.
> 2. Server upserts a `GroupMessageRead` row (commentId + userId). Author's own read is ignored.
> 3. Server broadcasts `group:message:seen { groupId, messageId, userId, seenAt, seenBy }` to the `group:{id}` room.
> 4. All connected members receive it and can show "Seen by X, Y, …" under the message.
> 5. When loading message history via `GET /v1/groups/:id/comments`, each message already includes `_count.reads` (total seen count) and a `reads` preview array (first 5 readers: `{ seenAt, user: { id, fullName, avatarUrl } }`).

---

#### `group:typing:start` / `group:typing:stop`

```ts
groupSocket.on('group:typing:start', ({ groupId, userId }) => showBubble(userId));
groupSocket.on('group:typing:stop',  ({ groupId, userId }) => hideBubble(userId));
```

#### `group:member:joined`

```ts
groupSocket.on('group:member:joined', ({ groupId, user }) => {
  showSystemMessage(`${user.fullName} joined`);
});
```

#### `group:member:left`

```ts
groupSocket.on('group:member:left', ({ groupId, userId }) => {
  removeFromMemberList(userId);
});
```

---

### REST for initial data & media uploads

| Purpose                             | Endpoint                                   |
| ----------------------------------- | ------------------------------------------ |
| Load message history on mount       | `GET /v1/groups/:id/comments?skip=0&take=30` |
| Send a message with media file      | `POST /v1/groups/:id/comments` (multipart/form-data — hidden from Swagger, still functional) |
| Group management (create/edit)      | `POST/PATCH/DELETE /v1/groups`             |
| Membership (join/leave/invite)      | See group management endpoints in Swagger  |
| Moderator / ban management          | See group management endpoints in Swagger  |

> Media uploads via REST automatically broadcast `group:message:new` or `group:message:reply` to the group room.

---

### TypeScript types

```ts
// Client → Server
interface GroupMessagePayload  { groupId: string; body: string; mediaUrl?: string; }
interface GroupReplyPayload    { groupId: string; parentId: string; body: string; mediaUrl?: string; }
interface UpdateGroupPayload   { groupId: string; messageId: string; body: string; }
interface DeleteGroupPayload   { groupId: string; messageId: string; }
interface GroupTypingPayload   { groupId: string; }

// Client → Server
interface GroupMessageReadPayload  { groupId: string; messageId: string; }

// Server → Client
interface GroupMessageReplyEvent   { parentId: string; reply: object; }
interface GroupMessageUpdatedEvent { id: string; groupId: string; body: string; [key: string]: unknown; }
interface GroupMessageDeletedEvent { groupId: string; messageId: string; }
interface GroupMessageSeenEvent    { groupId: string; messageId: string; userId: string; seenAt: string; seenBy: { id: string; fullName: string; avatarUrl: string | null }; }
interface GroupTypingEvent         { groupId: string; userId: string; }
interface GroupMemberJoinedEvent   { groupId: string; user: { id: string; fullName: string; avatarUrl: string | null }; }
interface GroupMemberLeftEvent     { groupId: string; userId: string; }

// REST message list — each message includes:
interface GroupMessageReadReceipt  { seenAt: string; user: { id: string; fullName: string; avatarUrl: string | null }; }
// _count.reads  → total number of members who have seen the message
// reads         → first 5 readers (GroupMessageReadReceipt[])
```

---

## 4. User Location `/user-location`

Live GPS coordinate streaming. Toggle sharing without disconnecting.

### Connect

```ts
const locationSocket = io('http://localhost:3000/user-location', {
  auth: { token: accessToken },
  transports: ['websocket'],
});
```

---

### Client → Server events

#### `location:update`

```ts
locationSocket.emit('location:update', { latitude: 9.02497, longitude: 38.74689 });
```

#### `location:sharing:toggle`

```ts
locationSocket.emit('location:sharing:toggle', { enabled: true });
```

---

### Server → Client events

#### `location:updated`

```ts
locationSocket.on('location:updated', ({ userId, latitude, longitude, updatedAt }) => {
  updateMapPin(userId, latitude, longitude);
});
```

#### `location:sharing:toggled`

```ts
locationSocket.on('location:sharing:toggled', ({ enabled }) => updateToggleUI(enabled));
```

---

### REST alternative (one-shot or background sync)

```http
PATCH /v1/users/me/location
Content-Type: application/json
{ "latitude": 9.02497, "longitude": 38.74689, "locationSharingEnabled": true }
```

---

### TypeScript types

```ts
interface UpdateLocationPayload        { latitude: number; longitude: number; }
interface ToggleSharingPayload         { enabled: boolean; }
interface LocationUpdatedEvent         { userId: string; latitude: number; longitude: number; updatedAt: string; }
interface LocationSharingToggledEvent  { enabled: boolean; }
```

---

## 5. Presence / Online Status

Know whether a user is online right now, or how long ago they were last seen ("5 minutes ago", "2 hours ago", "3 days ago"). Works across `/messaging` and `/groups` — no separate namespace to connect to.

### How it works

- A user counts as **online** as long as they have at least one open socket on `/messaging` **or** `/groups` (being connected to both keeps them online if either one closes).
- The instant their **last** socket across both namespaces disconnects, the server stamps `lastSeenAt` and broadcasts `presence:offline`.
- No client action is required — presence updates automatically just by being connected.

### Server → Client events (emitted on `/messaging` and `/groups`)

#### `presence:online`

Broadcast to every `conv:{id}` (on `/messaging`) or `group:{id}` (on `/groups`) room the user belongs to, the moment they come online.

```ts
socket.on('presence:online', ({ userId }) => {
  markUserOnline(userId);
});
```

#### `presence:offline`

Broadcast to the same rooms when the user goes fully offline.

```ts
socket.on('presence:offline', ({ userId, lastSeenAt }) => {
  markUserOffline(userId, lastSeenAt);
});
```

---

### REST fields

`isOnline` / `lastSeenAt` / `lastSeenText` are included wherever user/participant info is returned:

| Endpoint                              | Field location                              |
| -------------------------------------- | -------------------------------------------- |
| `GET /v1/users/me`                     | top-level on the response                   |
| `GET /v1/messaging/conversations`      | each conversation's `participantA` / `participantB` |
| `GET /v1/messaging/conversations/:id`  | `conversation.participantA` / `participantB` |
| `GET /v1/groups/:id/members`           | each `member.user`                          |

```ts
interface PresenceFields {
  isOnline: boolean;
  lastSeenAt: string | null;   // ISO timestamp; null while isOnline is true
  lastSeenText: string | null; // e.g. "5 minutes ago", or "online" while isOnline is true
}
```

---

### TypeScript types

```ts
interface PresenceOnlineEvent  { userId: string; }
interface PresenceOfflineEvent { userId: string; lastSeenAt: string; }
```

---

## Architecture notes

### Socket.IO vs REST

| Layer          | Handled by         | Notes                                                                 |
| -------------- | ------------------ | --------------------------------------------------------------------- |
| DM send/reply/update/delete | Socket.IO `/messaging` | REST `POST /conversations` also works for media uploads |
| Group messages | Socket.IO `/groups` | REST `POST /groups/:id/comments` also works for media uploads        |
| Notifications  | Socket.IO `/notifications` + FCM push | In-app + background                                 |
| Post comments  | REST only          | Push notification fired on `POST_COMMENTED`                           |
| Short comments | REST only          | Push notification fired on `SHORT_COMMENTED`                          |
| Comment likes  | REST only          | Push notification fired on `COMMENT_LIKED`                            |
| Post likes     | REST only          | Push notification fired on `LIKE`                                     |
| Church follows | REST only          | Push notification fired on `FOLLOW`                                   |

### Rooms

Each namespace uses rooms for scoped delivery:

| Room pattern      | Namespace    | Who receives                                      |
| ----------------- | ------------ | ------------------------------------------------- |
| `user:{userId}`   | all          | Personal delivery (used to push into new rooms)   |
| `conv:{convId}`   | `/messaging` | Both participants of a 1-to-1 conversation        |
| `group:{groupId}` | `/groups`    | All members of a group                            |

### Media files

The WebSocket cannot carry binary uploads. For messages with images, videos, or audio:

1. Upload via REST (`POST /v1/messaging/conversations` or `POST /v1/groups/:id/comments`) — the response is broadcast live to the room automatically
2. Or upload the file to a CDN first, then pass the resulting URL as `mediaUrl` in the socket `message:send` / `group:message:send` payload

---

## FAQs

**Do I need all four connections open at once?**
No — connect only to the namespace the current screen needs. Each `io(...)` call is independent.

**Does auth re-occur on every message?**
No. JWT is validated once at connect time and stored for the lifetime of the connection.

**Do rooms re-join after a reconnect?**
Yes. `handleConnection` runs on every reconnect and re-joins all rooms from the database.

**What does `WS_AUTH_FAILED` mean?**
JWT was missing, malformed, expired, or the account is inactive. Refresh the token and reconnect.

**Can I reply to a reply?**
Yes — both DM (`message:reply`) and group chat (`group:message:reply`) support unlimited reply nesting. Pass any message UUID as `replyToId` / `parentId`.

**Who can delete a DM message?**
Either participant — sender or recipient. Deletion removes the message for both sides (Telegram-style).

**Who can delete a group message?**
Only the original author via the socket. Group moderators and church owners can delete any message via REST `DELETE /v1/groups/:id/comments/:commentId`.

**How do I know if a user is online?**
Connect to `/messaging` or `/groups` and listen for `presence:online` / `presence:offline` — they fire for users who share a conversation or group with you. You can also check `isOnline` / `lastSeenAt` / `lastSeenText` on `GET /v1/users/me`, `GET /v1/messaging/conversations`, `GET /v1/messaging/conversations/:id`, and `GET /v1/groups/:id/members`.

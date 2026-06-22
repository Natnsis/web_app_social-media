export interface PostFile {
  id: string
  novaFileId: string | null
  novaVideoId: string | null
  name: string
  mimeType: string
  size: number
  novaUrl: string | null
  mediaType: "image" | "video"
  streamCode: string | null
  appId: string | null
  isReady: boolean | null
  videoStatus: string | null
}

export interface ChurchInfo {
  id: string
  name: string
  logoUrl: string | null
  slug: string
}

export interface PostCount {
  comments: number
  likes: number
  saves: number
}

export interface Post {
  id: string
  churchId: string
  title: string | null
  content: string
  status: string
  mediaUrls: string | null
  novaFileIds: string[]
  isTagged: boolean
  createdAt: string
  updatedAt: string
  deletedAt: string | null
  church: ChurchInfo
  _count: PostCount
  timeAgo: string
  files: PostFile[]
}

export interface PostsMeta {
  page: number
  limit: number
  total: number
  totalPages: number
  hasNextPage: boolean
  hasPreviousPage: boolean
}

export interface PostsResponse {
  success: boolean
  data: Post[]
  meta: PostsMeta
  timestamp: string
}

export interface PlayVideo {
  fileId: string
  name: string
  isReady: boolean
  appId: string
  streamCode: string
  novaVideoId: string
  duration: number
}

export interface PlayPostResponse {
  postId: string
  videos: PlayVideo[]
}

export interface Comment {
  id: string
  body: string
  media: string | null
  parentId: string | null
  createdAt: string
  updatedAt: string
  deletedAt: string | null
  author: {
    id: string
    name: string
    initials: string
    avatarUrl: string | null
  }
  _count: {
    replies: number
    likes?: number
  }
  replies?: Comment[]
}

export interface CommentsResponse {
  success: boolean
  data: Comment[]
  meta: PostsMeta
  timestamp: string
}

export interface CreatePostPayload {
  title?: string
  content: string
  novaFileIds?: string[]
  allowComments?: boolean
}

export interface CreateCommentPayload {
  body: string
  parentId?: string
  media?: string
}

export interface ApiResponse<T = unknown> {
  success: boolean
  data: T
  message?: string
  timestamp?: string
}

export interface CreatePostResponse {
  success: boolean
  data: Post
  timestamp: string
}

// ── Chat / Messaging Types ──

export interface MessageSender {
  id: string
  fullName: string
  avatarUrl: string | null
}

export interface MessageReplyTo {
  id: string
  body: string
  mediaUrl: string | null
  deletedAt: string | null
  sender: MessageSender
}

export interface MessageEvent {
  id: string
  conversationId: string
  senderId: string
  replyToId: string | null
  body: string
  mediaUrl: string | null
  isRead: boolean
  readAt: string | null
  createdAt: string
  deletedAt: string | null
  sender: MessageSender
  replyTo: MessageReplyTo | null
}

export interface MessageDeletedEvent {
  conversationId: string
  messageId: string
}

export interface ConvReadEvent {
  conversationId: string
  readBy: string
}

export interface TypingDmEvent {
  conversationId: string
  userId: string
}

export interface SendMessagePayload {
  conversationId?: string
  recipientId?: string
  body: string
  mediaUrl?: string
}

export interface ReplyMessagePayload {
  conversationId: string
  replyToId: string
  body: string
  mediaUrl?: string
}

export interface UpdateMessagePayload {
  messageId: string
  body: string
}

export interface DeleteMessagePayload {
  messageId: string
}

export interface ConvPayload {
  conversationId: string
}

export interface Conversation {
  id: string
  participantAId: string
  participantBId: string
  participantA: ParticipantInfo
  participantB: ParticipantInfo
  messages: MessageEvent[]
  createdAt: string
  updatedAt: string
}

export interface ParticipantInfo {
  id: string
  fullName: string
  initials: string
  avatarUrl: string | null
  isOnline: boolean
  lastSeenAt: string | null
  lastSeenText: string | null
}

export interface ConversationsResponse {
  success: boolean
  data: Conversation[]
  meta: PostsMeta
  timestamp: string
}

export interface ConversationMessagesResponse {
  success: boolean
  data: {
    conversation: Conversation
    messages: MessageEvent[]
  }
  timestamp: string
}

export interface MessagesResponse {
  success: boolean
  data: MessageEvent[]
  meta: { total: number; skip: number; take: number }
}

export interface UnreadCountResponse {
  success: boolean
  data: { count: number }
}

// ── Group Chat Types ──

export interface GroupComment {
  id: string
  groupId: string
  senderId: string
  parentId: string | null
  body: string
  mediaUrl: string | null
  createdAt: string
  updatedAt: string
  deletedAt: string | null
  sender: MessageSender
  _count: { reads: number }
  reads: GroupMessageReadReceipt[]
}

export interface GroupMessageReadReceipt {
  seenAt: string
  user: { id: string; fullName: string; avatarUrl: string | null }
}

export interface GroupCommentsResponse {
  success: boolean
  data: GroupComment[]
  meta: { total: number; skip: number; take: number }
}

export interface GroupMessageReplyEvent {
  parentId: string
  reply: GroupComment
}

export interface GroupMessageDeletedEvent {
  groupId: string
  messageId: string
}

export interface GroupMessageSeenEvent {
  groupId: string
  messageId: string
  userId: string
  seenAt: string
  seenBy: { id: string; fullName: string; avatarUrl: string | null }
}

export interface GroupTypingEvent {
  groupId: string
  userId: string
}

export interface GroupMemberJoinedEvent {
  groupId: string
  user: { id: string; fullName: string; avatarUrl: string | null }
}

export interface GroupMemberLeftEvent {
  groupId: string
  userId: string
}

export interface CreateGroupPayload {
  name: string
  description?: string
  category?: string
  isPrivate?: boolean
}

export interface CreateGroupResponse {
  success: boolean
  data: { id: string }
}

export interface MinimalGroup {
  id: string
  churchId: string
  name: string
  description: string | null
  coverImageUrl: string | null
  isPrivate: boolean
  allowMemberInvites: boolean
  createdAt: string
  updatedAt: string
  church: ChurchInfo
  _count: { members: number; comments: number }
}

export interface GroupsResponse {
  success: boolean
  data: MinimalGroup[]
  meta: PostsMeta
  timestamp: string
}

// ── Notification Types ──

export interface NotificationEvent {
  id: string
  recipientUserId: string
  type: string
  title: string
  body: string
  data: Record<string, unknown> | null
  isRead: boolean
  createdAt: string
}

export interface NotificationsResponse {
  success: boolean
  data: NotificationEvent[]
  meta: { total: number; skip: number; take: number }
}

export interface MarkReadPayload {
  notificationId: string
}

// ── Presence Types ──

export interface PresenceOnlineEvent {
  userId: string
}

export interface PresenceOfflineEvent {
  userId: string
  lastSeenAt: string
}

export interface PresenceFields {
  isOnline: boolean
  lastSeenAt: string | null
  lastSeenText: string | null
}

export interface ShortChurch {
  id: string
  name: string
  logoUrl: string | null
  slug: string
}

export interface ShortNovaFile {
  novaVideoId: string | null
  streamCode: string | null
  appId: string | null
  isReady: boolean
  novaUrl: string | null
  mediaType: string
}

export interface ShortCount {
  likes: number
  comments: number
}

export interface Short {
  id: string
  churchId: string
  title: string
  description: string
  videoUrl: string | null
  novaFileId: string
  isPublished: boolean
  publishedAt: string
  viewCount: number
  createdAt: string
  updatedAt: string
  deletedAt: string | null
  church: ShortChurch
  _count: ShortCount
  timeAgo: string
  novaFile: ShortNovaFile
}

export interface ShortsResponse {
  success: boolean
  data: Short[]
  meta: PostsMeta
  timestamp: string
}

// ── Events Types ──

export interface EventItem {
  id: string
  churchId: string
  title: string
  description: string
  startDate: string
  endDate: string
  location: string | null
  imageUrl: string | null
  maxAttendees: number | null
  status: "upcoming" | "ongoing" | "completed" | "cancelled"
  isPublic: boolean
  createdAt: string
  updatedAt: string
  church: ChurchInfo
  attendeeCount: number
  timeAgo: string
}

export interface EventsResponse {
  success: boolean
  data: EventItem[]
  meta: PostsMeta
  timestamp: string
}

// ── Gifts Types ──

export interface GiftItem {
  id: string
  name: string
  description: string | null
  priceAmount: number
  priceCurrency: string
  imageUrl: string | null
  createdAt: string
}

export interface GiftFeedItem {
  id: string
  giftItem: GiftItem
  senderUser: {
    id: string
    fullName: string
    avatarUrl: string | null
  }
  recipientUserId: string
  message: string | null
  createdAt: string
}

export interface GiftsResponse {
  success: boolean
  data: GiftItem[]
  meta: { total: number }
}

export interface GiftFeedResponse {
  success: boolean
  data: GiftFeedItem[]
  meta: PostsMeta
  timestamp: string
}

// ── Campaign Types ──

export interface CampaignGoal {
  targetAmount: number
  currency: string
  currentAmount: number
  percentReached: number
}

export interface Campaign {
  id: string
  churchId: string
  title: string
  description: string
  category: string
  status: "active" | "completed" | "cancelled"
  goal: CampaignGoal
  imageUrl: string | null
  startsAt: string
  endsAt: string
  createdAt: string
  updatedAt: string
  church: ChurchInfo
  contributorCount: number
  timeAgo: string
}

export interface CampaignsResponse {
  success: boolean
  data: Campaign[]
  meta: PostsMeta
  timestamp: string
}

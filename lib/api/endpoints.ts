/**
 * TypeScript mirror of lib/lib/core/constants/api_endpoint.dart.
 * Parameterised endpoints keep identical signatures to the Dart source.
 */

export const ApiEndpoint = {
  v1: "/v1",
  churchAnalytics: (churchId: string) => `/v1/analytics/churches/${churchId}`,
} as const

export const AuthApiEndpoint = {
  register: `${ApiEndpoint.v1}/auth/register`,
  login: `${ApiEndpoint.v1}/auth/login`,
  otpResend: `${ApiEndpoint.v1}/auth/otp/resend`,
  otpVerify: `${ApiEndpoint.v1}/auth/otp/verify`,
  loginGoogle: `${ApiEndpoint.v1}/auth/login/google`,
  refresh: `${ApiEndpoint.v1}/auth/refresh`,
  logout: `${ApiEndpoint.v1}/auth/logout`,
  passwordChange: `${ApiEndpoint.v1}/auth/password/change`,
  passwordForgot: `${ApiEndpoint.v1}/auth/password/forgot`,
  passwordReset: `${ApiEndpoint.v1}/auth/password/reset`,
  phoneAdd: `${ApiEndpoint.v1}/auth/phone/add`,
} as const

export const UsersApiEndpoint = {
  me: `${ApiEndpoint.v1}/users/me`,
  meLocation: `${ApiEndpoint.v1}/users/me/location`,
  search: `${ApiEndpoint.v1}/users/search`,
} as const

export const ChurchesApiEndpoint = {
  list: `${ApiEndpoint.v1}/churches`,
  register: `${ApiEndpoint.v1}/churches`,
  nearby: `${ApiEndpoint.v1}/churches/nearby`,
  myChurch: `${ApiEndpoint.v1}/churches/me/church`,
  myFollowing: `${ApiEndpoint.v1}/churches/me/following`,
  detail: (id: string) => `${ApiEndpoint.v1}/churches/${id}`,
  members: (id: string) => `${ChurchesApiEndpoint.detail(id)}/members`,
  followInfo: (id: string) => `${ChurchesApiEndpoint.detail(id)}/follow-info`,
  dashboard: (id: string) => `${ChurchesApiEndpoint.detail(id)}/dashboard`,
  dashboardGifts: (id: string) => `${ChurchesApiEndpoint.dashboard(id)}/gifts`,
  dashboardTransactions: (id: string) =>
    `${ChurchesApiEndpoint.dashboard(id)}/transactions`,
  dashboardWithdrawals: (id: string) =>
    `${ChurchesApiEndpoint.dashboard(id)}/withdrawals`,
  dashboardCampaignDonors: (churchId: string, campaignId: string) =>
    `${ChurchesApiEndpoint.dashboard(churchId)}/campaigns/${campaignId}/donors`,
  verificationSubmit: (id: string) =>
    `${ChurchesApiEndpoint.detail(id)}/verification/submit`,
  verificationApplications: (id: string) =>
    `${ChurchesApiEndpoint.detail(id)}/verification/applications`,
  memberRevoke: (churchId: string, userId: string) =>
    `${ChurchesApiEndpoint.members(churchId)}/${userId}`,
  follow: (id: string) => `${ChurchesApiEndpoint.detail(id)}/follow`,
  scrypersAll: `${ApiEndpoint.v1}/churches/scrypers`,
  scryper: (id: string) => `${ChurchesApiEndpoint.detail(id)}/scryper`,
  scrypers: (id: string) => `${ChurchesApiEndpoint.detail(id)}/scrypers`,
  scryperDelete: (churchId: string, scryperId: string) =>
    `${ChurchesApiEndpoint.scryper(churchId)}/${scryperId}`,
  paymentAccounts: (id: string) =>
    `${ChurchesApiEndpoint.detail(id)}/payment-accounts`,
  paymentAccount: (churchId: string, accountId: string) =>
    `${ChurchesApiEndpoint.paymentAccounts(churchId)}/${accountId}`,
  churchAnalytics: (churchId: string) => ApiEndpoint.churchAnalytics(churchId),
} as const

export const CampaignsApiEndpoint = {
  list: `${ApiEndpoint.v1}/campaigns`,
  following: `${ApiEndpoint.v1}/campaigns/following`,
  byChurch: (churchId: string) => `${ApiEndpoint.v1}/campaigns/church/${churchId}`,
  detail: (id: string) => `${ApiEndpoint.v1}/campaigns/${id}`,
  contributions: (id: string) => `${CampaignsApiEndpoint.detail(id)}/contributions`,
  updates: (id: string) => `${CampaignsApiEndpoint.detail(id)}/updates`,
} as const

export const EventsApiEndpoint = {
  list: `${ApiEndpoint.v1}/events`,
  mine: `${ApiEndpoint.v1}/events/mine`,
  byChurch: (churchId: string) => `${ApiEndpoint.v1}/events/church/${churchId}`,
  detail: (id: string) => `${ApiEndpoint.v1}/events/${id}`,
} as const

export const MessagingApiEndpoint = {
  messages: `${ApiEndpoint.v1}/messaging/messages`,
  media: `${ApiEndpoint.v1}/messaging/media`,
  messagesQuery: (conversationId: string) =>
    ({ conversationId }) as { conversationId: string },
  blocks: `${ApiEndpoint.v1}/messaging/blocks`,
  blockUser: (userId: string) => `${MessagingApiEndpoint.blocks}/${userId}`,
} as const

export const GroupsApiEndpoint = {
  list: `${ApiEndpoint.v1}/groups`,
  detail: (id: string) => `${ApiEndpoint.v1}/groups/${id}`,
  joinRequests: (groupId: string) =>
    `${GroupsApiEndpoint.detail(groupId)}/join-requests`,
  approveJoinRequest: (groupId: string, userId: string) =>
    `${GroupsApiEndpoint.joinRequests(groupId)}/${userId}/approve`,
  rejectJoinRequest: (groupId: string, userId: string) =>
    `${GroupsApiEndpoint.joinRequests(groupId)}/${userId}/reject`,
  media: `${ApiEndpoint.v1}/groups/media`,
  members: (groupId: string) => `${GroupsApiEndpoint.detail(groupId)}/members`,
  removeMember: (groupId: string, userId: string) =>
    `${GroupsApiEndpoint.members(groupId)}/${userId}`,
  banMember: (groupId: string, userId: string) =>
    `${GroupsApiEndpoint.detail(groupId)}/bans/${userId}`,
  leave: (groupId: string) => `${GroupsApiEndpoint.detail(groupId)}/leave`,
  inviteMember: (groupId: string, userId: string) =>
    `${GroupsApiEndpoint.members(groupId)}/invite/${userId}`,
  comments: (id: string) => `${GroupsApiEndpoint.detail(id)}/comments`,
  groupMessages: (id: string) => `${GroupsApiEndpoint.detail(id)}/groupmessages`,
  deleteComment: (id: string, commentId: string) =>
    `${GroupsApiEndpoint.comments(id)}/${commentId}`,
} as const

export const GroupMessagesApiEndpoint = {
  replies: (id: string) => `${ApiEndpoint.v1}/groupmessages/${id}/replies`,
} as const

export const NovaFilesApiEndpoint = {
  upload: `${ApiEndpoint.v1}/nova-files`,
} as const

export const ShortsApiEndpoint = {
  list: `${ApiEndpoint.v1}/shorts`,
  detail: (id: string) => `${ApiEndpoint.v1}/shorts/${id}`,
  publish: (id: string) => `${ShortsApiEndpoint.detail(id)}/publish`,
  comments: (id: string) => `${ShortsApiEndpoint.detail(id)}/comments`,
  deleteComment: (id: string, commentId: string) =>
    `${ShortsApiEndpoint.comments(id)}/${commentId}`,
} as const

export const PostsApiEndpoint = {
  list: `${ApiEndpoint.v1}/posts`,
  byChurch: (churchId: string) => `${ApiEndpoint.v1}/posts/church/${churchId}`,
  saved: `${ApiEndpoint.v1}/posts/saved`,
  detail: (id: string) => `${ApiEndpoint.v1}/posts/${id}`,
  like: (id: string) => `${PostsApiEndpoint.detail(id)}/like`,
  save: (id: string) => `${PostsApiEndpoint.detail(id)}/save`,
  comments: (id: string) => `${PostsApiEndpoint.detail(id)}/comments`,
} as const

export const CommentsApiEndpoint = {
  detail: (commentId: string) => `${ApiEndpoint.v1}/comments/${commentId}`,
  replies: (commentId: string) => `${CommentsApiEndpoint.detail(commentId)}/replies`,
  like: (commentId: string) => `${CommentsApiEndpoint.detail(commentId)}/like`,
} as const

export const NotificationsApiEndpoint = {
  registerDevice: `${ApiEndpoint.v1}/notifications/devices`,
  device: (deviceId: string) =>
    `${NotificationsApiEndpoint.registerDevice}/${deviceId}`,
  base: `${ApiEndpoint.v1}/notifications`,
  unreadCount: `${ApiEndpoint.v1}/notifications/unread-count`,
  preferences: `${ApiEndpoint.v1}/notifications/preferences`,
  readAll: `${ApiEndpoint.v1}/notifications/read-all`,
  read: (id: string) => `${NotificationsApiEndpoint.base}/${id}/read`,
} as const

export const BillingApiEndpoint = {
  withdrawals: `${ApiEndpoint.v1}/billing/withdrawals`,
  gifts: `${ApiEndpoint.v1}/billing/gifts`,
  campaignDonate: (campaignId: string) =>
    `${ApiEndpoint.v1}/billing/campaigns/${campaignId}/donate`,
  transactionStatus: (txRef: string) =>
    `${ApiEndpoint.v1}/billing/transactions/${txRef}/status`,
} as const

export const LiveStreamApiEndpoint = {
  list: `${ApiEndpoint.v1}/livestream`,
  detail: (id: string) => `${ApiEndpoint.v1}/livestream/${id}`,
  publish: (id: string) => `${LiveStreamApiEndpoint.detail(id)}/publish`,
} as const

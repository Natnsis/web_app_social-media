import { get, post, del, postFormData } from "./client"
import { useAuthStore } from "@/lib/store/auth"
import type {
  ConversationsResponse,
  ConversationMessagesResponse,
  UnreadCountResponse,
  BlocksResponse,
  MediaUploadResponse,
} from "@/types"

function token() {
  return useAuthStore.getState().accessToken ?? undefined
}

export function apiGetConversations() {
  return get<ConversationsResponse>("/v1/messaging/conversations", token())
}

export function apiGetConversation(id: string) {
  return get<ConversationMessagesResponse>(`/v1/messaging/conversations/${id}`, token())
}

export function apiGetUnreadCount() {
  return get<UnreadCountResponse>("/v1/messaging/unread-count", token())
}

export function apiUploadMedia(file: File) {
  const fd = new FormData()
  fd.append("file", file)
  return postFormData<MediaUploadResponse>("/v1/messaging/media", fd, token())
}

export function apiDeleteMessage(messageId: string) {
  return del(`/v1/messaging/messages/${messageId}`, token())
}

export function apiGetBlocks() {
  return get<BlocksResponse>("/v1/messaging/blocks", token())
}

export function apiBlockUser(userId: string) {
  return post(`/v1/messaging/blocks/${userId}`, undefined, token())
}

export function apiUnblockUser(userId: string) {
  return del(`/v1/messaging/blocks/${userId}`, token())
}

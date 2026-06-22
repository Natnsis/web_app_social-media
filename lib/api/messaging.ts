import { get, post, del } from "./client"
import { useAuthStore } from "@/lib/store/auth"
import type {
  ConversationsResponse,
  MessagesResponse,
  UnreadCountResponse,
} from "@/types"

function token() {
  return useAuthStore.getState().accessToken ?? undefined
}

export function apiGetConversations() {
  return get<ConversationsResponse>("/v1/messaging/conversations", token())
}

export function apiGetConversation(id: string, skip = 0, take = 50) {
  return get<MessagesResponse>(`/v1/messaging/conversations/${id}?skip=${skip}&take=${take}`, token())
}

export function apiGetUnreadCount() {
  return get<UnreadCountResponse>("/v1/messaging/unread-count", token())
}

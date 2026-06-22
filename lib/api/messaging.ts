import { get } from "./client"
import { useAuthStore } from "@/lib/store/auth"
import type {
  ConversationsResponse,
  ConversationMessagesResponse,
  UnreadCountResponse,
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

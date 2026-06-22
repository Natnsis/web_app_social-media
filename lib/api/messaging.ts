import { get, post, del, postFormData } from "./client"
import { useAuthStore } from "@/lib/store/auth"
import type {
  ConversationsResponse,
  ConversationMessagesResponse,
  UnreadCountResponse,
  BlocksResponse,
  ApiResponse,
  MessageEvent,
  GroupComment,
} from "@/types"

function token() {
  return useAuthStore.getState().accessToken ?? undefined
}

function mediaFormData(body: string, file: File, fileFieldName: string, conversationId?: string) {
  const fd = new FormData()
  if (conversationId) fd.append("conversationId", conversationId)
  fd.append("body", body)
  fd.append(fileFieldName, file)
  return fd
}

async function postMediaWithFallback<T>(path: string, body: string, file: File, conversationId?: string) {
  const fileFieldNames = ["file", "media", "image"]
  let lastError: unknown

  for (const fileFieldName of fileFieldNames) {
    try {
      return await postFormData<T>(path, mediaFormData(body, file, fileFieldName, conversationId), token())
    } catch (error) {
      lastError = error
    }
  }

  throw lastError
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

export function apiSendMessage(conversationId: string, body: string, file?: File) {
  if (file) {
    return postMediaWithFallback<ApiResponse<MessageEvent>>("/v1/messaging/conversations", body, file, conversationId)
  }

  const fd = new FormData()
  fd.append("conversationId", conversationId)
  fd.append("body", body)
  return postFormData<ApiResponse<MessageEvent>>("/v1/messaging/conversations", fd, token())
}

export function apiSendGroupComment(groupId: string, body: string, file?: File) {
  if (file) {
    return postMediaWithFallback<ApiResponse<GroupComment>>(`/v1/groups/${groupId}/comments`, body, file)
  }

  const fd = new FormData()
  fd.append("body", body)
  return postFormData<ApiResponse<GroupComment>>(`/v1/groups/${groupId}/comments`, fd, token())
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

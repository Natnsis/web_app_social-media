import { get, post, del, patch } from "./client"
import { useAuthStore } from "@/lib/store/auth"
import type { ShortsResponse, CommentsResponse, ApiResponse } from "@/types"

function token() {
  return useAuthStore.getState().accessToken ?? undefined
}

export function apiGetShorts(page = 1, limit = 20) {
  return get<ShortsResponse>(`/v1/shorts?page=${page}&limit=${limit}`, token())
}

export function apiLikeShort(id: string) {
  return post<ApiResponse>(`/v1/shorts/${id}/like`, undefined, token())
}

export function apiUnlikeShort(id: string) {
  return del<ApiResponse>(`/v1/shorts/${id}/like`, token())
}

export function apiGetShortComments(shortId: string) {
  return get<CommentsResponse>(`/v1/shorts/${shortId}/comments`, token())
}

export function apiCreateShortComment(shortId: string, body: string, parentId?: string) {
  return post<ApiResponse>(`/v1/shorts/${shortId}/comments`, { body, parentId }, token())
}

export function apiDeleteShortComment(shortId: string, commentId: string) {
  return del<ApiResponse>(`/v1/shorts/${shortId}/comments/${commentId}`, token())
}

export function apiGetCommentReplies(id: string) {
  return get<CommentsResponse>(`/v1/comments/${id}/replies`, token())
}

export function apiReplyToComment(id: string, body: string) {
  return post<ApiResponse>(`/v1/comments/${id}/replies`, { body }, token())
}

export function apiEditComment(id: string, body: string) {
  return patch<ApiResponse>(`/v1/comments/${id}`, { body }, token())
}

export function apiDeleteComment(id: string) {
  return del<ApiResponse>(`/v1/comments/${id}`, token())
}

export function apiLikeComment(id: string) {
  return post<ApiResponse>(`/v1/comments/${id}/like`, undefined, token())
}

export function apiUnlikeComment(id: string) {
  return del<ApiResponse>(`/v1/comments/${id}/like`, token())
}

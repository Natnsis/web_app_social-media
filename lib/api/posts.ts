import { get, post, del } from "./client"
import { useAuthStore } from "@/lib/store/auth"
import type {
  Post,
  Comment,
  PostsResponse,
  PlayPostResponse,
  CommentsResponse,
  CreatePostPayload,
  CreateCommentPayload,
  ApiResponse,
  CreatePostResponse,
} from "@/types"

function token() {
  return useAuthStore.getState().accessToken ?? undefined
}

export function apiGetPosts(page = 1, limit = 20) {
  return get<PostsResponse>(`/v1/posts?page=${page}&limit=${limit}`, token())
}

export function apiGetPost(id: string) {
  return get<ApiResponse<Post>>(`/v1/posts/${id}`, token())
}

export function apiGetSavedPosts(page = 1, limit = 20) {
  return get<PostsResponse>(`/v1/posts/saved?page=${page}&limit=${limit}`, token())
}

export function apiGetPostsByChurch(churchId: string, page = 1, limit = 20) {
  return get<PostsResponse>(`/v1/posts/church/${churchId}?page=${page}&limit=${limit}`, token())
}

export function apiCreatePost(payload: CreatePostPayload) {
  return post<CreatePostResponse>("/v1/posts", payload, token())
}

export function apiDeletePost(id: string) {
  return del<ApiResponse>(`/v1/posts/${id}`, token())
}

export function apiPlayPost(id: string) {
  return get<PlayPostResponse>(`/v1/posts/${id}/play`, token())
}

export function apiLikePost(id: string) {
  return post<ApiResponse>(`/v1/posts/${id}/like`, undefined, token())
}

export function apiUnlikePost(id: string) {
  return del<ApiResponse>(`/v1/posts/${id}/like`, token())
}

export function apiSavePost(id: string) {
  return post<ApiResponse>(`/v1/posts/${id}/save`, undefined, token())
}

export function apiUnsavePost(id: string) {
  return del<ApiResponse>(`/v1/posts/${id}/save`, token())
}

export function apiGetComments(postId: string) {
  return get<CommentsResponse>(`/v1/posts/${postId}/comments`, token())
}

export function apiCreateComment(postId: string, payload: CreateCommentPayload) {
  return post<ApiResponse<Comment>>(`/v1/posts/${postId}/comments`, payload, token())
}

export function apiDeleteComment(postId: string, commentId: string) {
  return del<ApiResponse>(`/v1/posts/${postId}/comments/${commentId}`, token())
}

export function apiLikeComment(postId: string, commentId: string) {
  return post<ApiResponse>(`/v1/posts/${postId}/comments/${commentId}/like`, undefined, token())
}

export function apiUnlikeComment(postId: string, commentId: string) {
  return del<ApiResponse>(`/v1/posts/${postId}/comments/${commentId}/like`, token())
}

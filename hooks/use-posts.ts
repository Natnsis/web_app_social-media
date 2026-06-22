"use client"

import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query"
import {
  apiGetPosts,
  apiGetSavedPosts,
  apiCreatePost,
  apiDeletePost,
  apiLikePost,
  apiUnlikePost,
  apiSavePost,
  apiUnsavePost,
  apiGetComments,
  apiCreateComment,
  apiDeleteComment,
} from "@/lib/api/posts"
import type { CreatePostPayload, CreateCommentPayload } from "@/types"

export function usePosts(page = 1, limit = 20) {
  return useQuery({
    queryKey: ["posts", "feed", page, limit],
    queryFn: () => apiGetPosts(page, limit),
  })
}

export function useSavedPosts(page = 1, limit = 20, enabled = true) {
  return useQuery({
    queryKey: ["posts", "saved", page, limit],
    queryFn: () => apiGetSavedPosts(page, limit),
    enabled,
  })
}

export function useCreatePost() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (payload: CreatePostPayload) => apiCreatePost(payload),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["posts"] })
    },
  })
}

export function useDeletePost() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (id: string) => apiDeletePost(id),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["posts"] })
    },
  })
}

export function useToggleLike() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: ({ id, liked }: { id: string; liked: boolean }) =>
      liked ? apiUnlikePost(id) : apiLikePost(id),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["posts"] })
    },
  })
}

export function useToggleSave() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: ({ id, saved }: { id: string; saved: boolean }) =>
      saved ? apiUnsavePost(id) : apiSavePost(id),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["posts"] })
    },
  })
}

export function useComments(postId: string) {
  return useQuery({
    queryKey: ["comments", postId],
    queryFn: () => apiGetComments(postId),
    enabled: !!postId,
  })
}

export function useCreateComment(postId: string) {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (payload: CreateCommentPayload) => apiCreateComment(postId, payload),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["comments", postId] })
    },
  })
}

export function useDeleteComment(postId: string) {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (commentId: string) => apiDeleteComment(postId, commentId),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["comments", postId] })
    },
  })
}

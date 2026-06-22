"use client"

import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query"
import {
  apiGetShorts,
  apiLikeShort,
  apiUnlikeShort,
  apiGetShortComments,
  apiCreateShortComment,
  apiDeleteShortComment,
  apiGetCommentReplies,
  apiReplyToComment,
  apiEditComment,
  apiDeleteComment,
  apiLikeComment,
  apiUnlikeComment,
} from "@/lib/api/shorts"

export function useShorts(page = 1, limit = 20) {
  return useQuery({
    queryKey: ["shorts", page],
    queryFn: () => apiGetShorts(page, limit),
  })
}

export function useToggleShortLike() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: ({ id, liked }: { id: string; liked: boolean }) =>
      liked ? apiUnlikeShort(id) : apiLikeShort(id),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["shorts"] })
    },
  })
}

export function useShortComments(shortId: string) {
  return useQuery({
    queryKey: ["short-comments", shortId],
    queryFn: () => apiGetShortComments(shortId),
    enabled: !!shortId,
  })
}

export function useCreateShortComment(shortId: string) {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: ({ body, parentId }: { body: string; parentId?: string }) =>
      apiCreateShortComment(shortId, body, parentId),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["short-comments", shortId] })
    },
  })
}

export function useDeleteShortComment(shortId: string) {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (commentId: string) => apiDeleteShortComment(shortId, commentId),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["short-comments", shortId] })
    },
  })
}

export function useCommentReplies(commentId: string) {
  return useQuery({
    queryKey: ["comment-replies", commentId],
    queryFn: () => apiGetCommentReplies(commentId),
    enabled: !!commentId,
  })
}

export function useReplyToComment(commentId: string) {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (body: string) => apiReplyToComment(commentId, body),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["comment-replies", commentId] })
    },
  })
}

export function useEditComment() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: ({ id, body }: { id: string; body: string }) => apiEditComment(id, body),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["short-comments"] })
      qc.invalidateQueries({ queryKey: ["comment-replies"] })
    },
  })
}

export function useDeleteComment() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (id: string) => apiDeleteComment(id),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["short-comments"] })
      qc.invalidateQueries({ queryKey: ["comment-replies"] })
    },
  })
}

export function useToggleCommentLike() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: ({ id, liked }: { id: string; liked: boolean }) =>
      liked ? apiUnlikeComment(id) : apiLikeComment(id),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["short-comments"] })
      qc.invalidateQueries({ queryKey: ["comment-replies"] })
    },
  })
}

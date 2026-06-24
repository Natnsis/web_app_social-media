"use client"

import { useState, useRef, useEffect } from "react"
import Link from "next/link"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { Button } from "@/components/ui/button"
import { EmojiPicker } from "@/components/emoji-picker"
import { useAuthStore } from "@/lib/store/auth"
import {
  useShortComments,
  useCreateShortComment,
  useCommentReplies,
  useToggleCommentLike,
} from "@/hooks/use-shorts"
import { Heart as HeartSolid } from "nasicon-react/solid"
import { Heart, Send, MessageSquare } from "nasicon-react/outline"
import type { Comment } from "@/types"

function formatCount(n: number) {
  return n >= 1000 ? `${(n / 1000).toFixed(1)}k` : String(n)
}

function timeAgo(dateStr: string) {
  const diff = Date.now() - new Date(dateStr).getTime()
  const mins = Math.floor(diff / 60000)
  if (mins < 1) return "now"
  if (mins < 60) return `${mins}m`
  const hrs = Math.floor(mins / 60)
  if (hrs < 24) return `${hrs}h`
  const days = Math.floor(hrs / 24)
  if (days < 30) return `${days}d`
  return `${Math.floor(days / 30)}mo`
}

function CommentRow({
  comment,
  shortId,
  depth = 0,
  onReply,
  replyingTo,
}: {
  comment: Comment
  shortId: string
  depth?: number
  onReply: (id: string, name: string) => void
  replyingTo: string | null
}) {
  const authorName = comment.author?.name ?? "Unknown"
  const authorInitials = comment.author?.initials ?? authorName.slice(0, 2).toUpperCase()
  const replyCount = comment._count?.replies ?? 0
  const initialLikes = comment._count?.likes ?? 0
  const [liked, setLiked] = useState(comment.isLiked ?? false)
  const [likeCount, setLikeCount] = useState(initialLikes)
  const [showReplies, setShowReplies] = useState(false)
  const toggleCommentLike = useToggleCommentLike()
  const { data: repliesData, isLoading: repliesLoading } = useCommentReplies(
    showReplies ? comment.id : ""
  )
  const replies = repliesData?.data ?? []

  function handleLike() {
    const wasLiked = liked
    setLiked(!wasLiked)
    setLikeCount((c) => (wasLiked ? c - 1 : c + 1))
    toggleCommentLike.mutate({ id: comment.id, liked: wasLiked })
  }

  const isReply = replyingTo === comment.id

  return (
    <div className={`${depth > 0 ? "ml-8 border-l-2 border-border pl-3" : ""}`}>
      <div className={`flex gap-2.5 ${isReply ? "bg-primary/5 -mx-3 rounded-xl px-3 py-2" : ""}`}>
        <Avatar size="sm" className="mt-0.5 shrink-0">
          <AvatarFallback className="bg-primary/20 text-primary text-[10px] font-semibold">
            {authorInitials}
          </AvatarFallback>
        </Avatar>
        <div className="min-w-0 flex-1">
          <div className="flex items-baseline gap-2">
            <p className="text-xs font-semibold">{authorName}</p>
            <p className="text-[10px] text-muted-foreground">{timeAgo(comment.createdAt ?? "")}</p>
          </div>
          <p className="text-sm text-foreground">{comment.body ?? ""}</p>
          <div className="mt-1 flex items-center gap-3">
            <button
              onClick={handleLike}
              className="flex items-center gap-1 text-xs text-muted-foreground hover:text-red-500 transition-colors"
            >
              {liked ? <HeartSolid size={12} className="text-red-500" /> : <Heart size={12} />}
              <span>{formatCount(likeCount)}</span>
            </button>
            <button
              onClick={() => onReply(comment.id, authorName)}
              className="text-xs font-medium text-muted-foreground hover:text-foreground transition-colors"
            >
              Reply
            </button>
            {replyCount > 0 && !showReplies && (
              <button
                onClick={() => setShowReplies(true)}
                className="text-xs font-medium text-primary"
              >
                View {replyCount} {replyCount === 1 ? "reply" : "replies"}
              </button>
            )}
          </div>
        </div>
      </div>

      {showReplies && (
        <div className="mt-2 space-y-2">
          {repliesLoading && (
            <div className="ml-8 flex items-center gap-2 text-xs text-muted-foreground">
              <div className="size-3 animate-spin rounded-full border-2 border-muted-foreground/30 border-t-muted-foreground" />
              Loading replies...
            </div>
          )}
          {replies.map((reply) => (
            <CommentRow
              key={reply.id}
              comment={reply}
              shortId={shortId}
              depth={depth + 1}
              onReply={onReply}
              replyingTo={replyingTo}
            />
          ))}
        </div>
      )}
    </div>
  )
}

interface CommentsSectionProps {
  shortId: string
  onClose?: () => void
}

export function CommentsSection({ shortId, onClose }: CommentsSectionProps) {
  const isAuthenticated = useAuthStore((s) => s.isAuthenticated)
  const [input, setInput] = useState("")
  const [showEmoji, setShowEmoji] = useState(false)
  const [replyTarget, setReplyTarget] = useState<{ id: string; name: string } | null>(null)
  const inputRef = useRef<HTMLInputElement>(null)
  const listRef = useRef<HTMLDivElement>(null)

  const { data, isLoading, isError, refetch } = useShortComments(shortId)
  const createComment = useCreateShortComment(shortId)

  const comments = data?.data ?? []
  const totalComments = comments.length

  useEffect(() => {
    if (replyTarget) {
      inputRef.current?.focus()
    }
  }, [replyTarget])

  function handleSend() {
    const text = input.trim()
    if (!text || createComment.isPending) return

    createComment.mutate(
      { body: text, parentId: replyTarget?.id },
      {
        onSuccess: () => {
          setInput("")
          setReplyTarget(null)
          setShowEmoji(false)
          if (listRef.current) {
            listRef.current.scrollTop = 0
          }
        },
      }
    )
  }

  function handleKeyDown(e: React.KeyboardEvent) {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault()
      handleSend()
    }
  }

  function handleEmojiSelect(emoji: string) {
    setInput((prev) => prev + emoji)
    inputRef.current?.focus()
  }

  function handleSuggestionSelect(text: string) {
    setInput((prev) => (prev ? `${prev} ${text}` : text))
    inputRef.current?.focus()
  }

  function handleReply(commentId: string, userName: string) {
    setReplyTarget({ id: commentId, name: userName })
    setShowEmoji(false)
  }

  function cancelReply() {
    setReplyTarget(null)
  }

  return (
    <div className="flex h-full flex-col">
      {/* Header */}
      <div className="flex shrink-0 items-center justify-between border-b border-border px-4 py-3">
        <p className="text-sm font-bold">{formatCount(totalComments)} comment{totalComments !== 1 ? "s" : ""}</p>
        {onClose && (
          <Button variant="ghost" size="icon-xs" onClick={onClose} className="rounded-lg">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="text-muted-foreground">
              <path d="M18 6L6 18M6 6l12 12" />
            </svg>
          </Button>
        )}
      </div>

      {/* Comments list */}
      <div ref={listRef} className="flex-1 overflow-y-auto px-4 py-3">
        {isLoading && (
          <div className="space-y-4">
            {[1, 2, 3].map((i) => (
              <div key={i} className="flex animate-pulse gap-2.5">
                <div className="size-6 shrink-0 rounded-full bg-muted" />
                <div className="flex-1 space-y-1.5">
                  <div className="h-3 w-24 rounded bg-muted" />
                  <div className="h-3 w-full rounded bg-muted" />
                  <div className="h-3 w-16 rounded bg-muted" />
                </div>
              </div>
            ))}
          </div>
        )}

        {isError && (
          <div className="flex flex-col items-center gap-3 py-8 text-center">
            <p className="text-sm text-muted-foreground">Couldn&apos;t load comments</p>
            <Button variant="outline" size="sm" onClick={() => refetch()}>
              Try again
            </Button>
          </div>
        )}

        {!isLoading && !isError && comments.length === 0 && (
          <div className="flex flex-col items-center gap-2 py-8 text-center">
            <MessageSquare size={24} className="text-muted-foreground/40" />
            <p className="text-sm text-muted-foreground">No comments yet</p>
            <p className="text-xs text-muted-foreground/60">Be the first to comment</p>
          </div>
        )}

        {!isLoading && !isError && comments.length > 0 && (
          <div className="space-y-3">
            {comments.map((comment) => (
              <CommentRow
                key={comment.id}
                comment={comment}
                shortId={shortId}
                onReply={handleReply}
                replyingTo={replyTarget?.id ?? null}
              />
            ))}
          </div>
        )}
      </div>

      {/* Emoji picker */}
      {showEmoji && (
        <EmojiPicker onEmojiSelect={handleEmojiSelect} onSuggestionSelect={handleSuggestionSelect} />
      )}

      {/* Input bar */}
      <div className="shrink-0 border-t border-border bg-background">
        {isAuthenticated ? (
          <>
            {replyTarget && (
              <div className="flex items-center justify-between bg-primary/5 px-4 py-1.5">
                <p className="text-xs text-muted-foreground">
                  Replying to <span className="font-semibold text-foreground">@{replyTarget.name}</span>
                </p>
                <button onClick={cancelReply} className="text-muted-foreground hover:text-foreground">
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <path d="M18 6L6 18M6 6l12 12" />
                  </svg>
                </button>
              </div>
            )}
            <div className="flex items-center gap-2 px-4 py-3">
              <Avatar size="sm" className="shrink-0">
                <AvatarFallback className="bg-primary text-primary-foreground text-[10px] font-bold">
                  Y
                </AvatarFallback>
              </Avatar>
              <div className="relative flex flex-1 items-center">
                <input
                  ref={inputRef}
                  type="text"
                  value={input}
                  onChange={(e) => setInput(e.target.value)}
                  onKeyDown={handleKeyDown}
                  placeholder={replyTarget ? "Write a reply..." : "Add a comment..."}
                  className="h-9 w-full rounded-full bg-muted px-4 pr-10 text-sm outline-none placeholder:text-muted-foreground/60"
                />
                <button
                  onClick={() => setShowEmoji((v) => !v)}
                  className="absolute right-2 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground transition-colors"
                >
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <circle cx="12" cy="12" r="10" />
                    <path d="M8 14s1.5 2 4 2 4-2 4-2" />
                    <line x1="9" y1="9" x2="9.01" y2="9" />
                    <line x1="15" y1="9" x2="15.01" y2="9" />
                  </svg>
                </button>
              </div>
              <button
                onClick={handleSend}
                disabled={!input.trim() || createComment.isPending}
                className="flex size-9 shrink-0 items-center justify-center rounded-full bg-primary text-primary-foreground transition-opacity disabled:opacity-40"
              >
                {createComment.isPending ? (
                  <div className="size-4 animate-spin rounded-full border-2 border-white/30 border-t-white" />
                ) : (
                  <Send size={16} />
                )}
              </button>
            </div>
          </>
        ) : (
          <div className="px-4 py-3 text-center">
            <p className="text-sm text-muted-foreground">
              <Link href="/login" className="font-semibold text-primary hover:underline">
                Sign in
              </Link>{" "}
              to add a comment
            </p>
          </div>
        )}
      </div>
    </div>
  )
}

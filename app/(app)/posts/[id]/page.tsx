"use client"

import { use, useState, useMemo, useCallback } from "react"
import { useRouter } from "next/navigation"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { Button } from "@/components/ui/button"
import { Textarea } from "@/components/ui/textarea"
import { PostCard } from "@/components/post-card"
import {
  usePost, useToggleLike, useToggleSave,
  useComments, useCreateComment, useDeleteComment, useToggleCommentLike,
} from "@/hooks/use-posts"
import { useAuthStore } from "@/lib/store/auth"
import { ArrowLeft } from "lucide-react"
import { CornerUpRight, MessageSquare, Heart as HeartOutline } from "nasicon-react/outline"
import { Heart as HeartSolid } from "nasicon-react/solid"
import type { Comment } from "@/types"

function formatDate(dateStr: string) {
  const date = new Date(dateStr)
  const now = new Date()
  const diff = now.getTime() - date.getTime()
  const mins = Math.floor(diff / 60000)
  if (mins < 1) return "just now"
  if (mins < 60) return `${mins}m ago`
  const hours = Math.floor(mins / 60)
  if (hours < 24) return `${hours}h ago`
  const days = Math.floor(hours / 24)
  if (days < 7) return `${days}d ago`
  return date.toLocaleDateString()
}

function getInitials(name: string | null | undefined) {
  if (!name) return "U"
  return name
    .split(" ")
    .map((n) => n[0])
    .join("")
    .toUpperCase()
    .slice(0, 2)
}

function PostDetailSkeleton() {
  return (
    <div className="space-y-4 animate-pulse">
      <div className="rounded-2xl border border-border bg-card p-4">
        <div className="flex items-center gap-3">
          <div className="size-11 rounded-full bg-muted" />
          <div className="space-y-2 flex-1">
            <div className="h-4 w-40 rounded bg-muted" />
            <div className="h-3 w-20 rounded bg-muted" />
          </div>
        </div>
        <div className="mt-4 space-y-2">
          <div className="h-3 w-full rounded bg-muted" />
          <div className="h-3 w-3/4 rounded bg-muted" />
        </div>
        <div className="mt-3 h-44 rounded-xl bg-muted" />
        <div className="mt-3 flex gap-5">
          <div className="h-4 w-12 rounded bg-muted" />
          <div className="h-4 w-12 rounded bg-muted" />
          <div className="h-4 w-12 rounded bg-muted" />
        </div>
      </div>
      <div className="rounded-2xl border border-border bg-card p-4 space-y-3">
        {[1, 2].map((i) => (
          <div key={i} className="flex gap-3">
            <div className="size-8 rounded-full bg-muted" />
            <div className="flex-1 space-y-2">
              <div className="h-8 w-full rounded-lg bg-muted" />
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}

interface CommentItemProps {
  comment: Comment
  likedCommentIds: Set<string>
  onLike: (commentId: string, liked: boolean) => void
  onReply: (parentId: string) => void
  onDelete: (commentId: string) => void
  isReply?: boolean
}

function CommentItem({ comment, likedCommentIds, onLike, onReply, onDelete, isReply }: CommentItemProps) {
  const [showReplies, setShowReplies] = useState(false)
  const hasReplies = comment.replies && comment.replies.length > 0
  const isLiked = likedCommentIds.has(comment.id)

  return (
    <div className={`${isReply ? "ml-8 mt-3" : "mt-4"}`}>
      <div className="flex gap-3">
        <Avatar className="size-8 shrink-0">
          <AvatarFallback className="bg-primary/15 text-primary text-xs font-bold">
            {getInitials(comment.author?.name || comment.author?.initials)}
          </AvatarFallback>
        </Avatar>
        <div className="flex-1 min-w-0">
          <div className="rounded-xl bg-muted/50 px-3 py-2">
            <div className="flex items-center justify-between">
              <p className="text-sm font-bold">{comment.author?.name || "Unknown"}</p>
              <p className="text-[10px] text-muted-foreground">{formatDate(comment.createdAt)}</p>
            </div>
            <p className="mt-1 text-sm leading-relaxed">{comment.body}</p>
            {comment.media && (
              <div className="mt-2 text-xs text-primary underline">View attachment</div>
            )}
          </div>
          <div className="mt-1 flex items-center gap-3 px-1">
            <button
              onClick={() => onLike(comment.id, isLiked)}
              className={`flex items-center gap-1 text-xs font-semibold transition-colors ${
                isLiked ? "text-red-500" : "text-muted-foreground hover:text-red-500"
              }`}
            >
              {isLiked ? <HeartSolid size={12} /> : <HeartOutline size={12} />}
              <span>{comment._count.likes ?? 0}</span>
            </button>
            <button
              onClick={() => onReply(comment.id)}
              className="text-xs font-semibold text-muted-foreground hover:text-primary"
            >
              Reply
            </button>
            <button
              onClick={() => onDelete(comment.id)}
              className="text-xs font-semibold text-muted-foreground hover:text-destructive"
            >
              Delete
            </button>
          </div>

          {hasReplies && !showReplies && (
            <button
              onClick={() => setShowReplies(true)}
              className="mt-1 flex items-center gap-1 text-xs font-semibold text-primary"
            >
              <MessageSquare size={12} />
              View {comment._count.replies} {comment._count.replies === 1 ? "reply" : "replies"}
            </button>
          )}

          {hasReplies && showReplies && (
            <>
              <button
                onClick={() => setShowReplies(false)}
                className="mt-1 text-xs font-semibold text-muted-foreground hover:text-primary"
              >
                Hide replies
              </button>
              {comment.replies!.map((reply) => (
                <CommentItem
                  key={reply.id}
                  comment={reply}
                  likedCommentIds={likedCommentIds}
                  onLike={onLike}
                  onReply={onReply}
                  onDelete={onDelete}
                  isReply
                />
              ))}
            </>
          )}
        </div>
      </div>
    </div>
  )
}

export default function PostDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params)
  const router = useRouter()
  const { user } = useAuthStore()

  const { data: postData, isLoading: postLoading, isError: postError, refetch: refetchPost } = usePost(id)
  const toggleLike = useToggleLike()
  const toggleSave = useToggleSave()
  const { data: commentsData, isLoading: commentsLoading, isError: commentsError } = useComments(id)
  const createComment = useCreateComment(id)
  const deleteComment = useDeleteComment(id)
  const toggleCommentLike = useToggleCommentLike(id)

  const [postLikeOverride, setPostLikeOverride] = useState<boolean | null>(null)
  const [postSaveOverride, setPostSaveOverride] = useState<boolean | null>(null)
  const [commentLikeOverrides, setCommentLikeOverrides] = useState<Record<string, boolean>>({})
  const [commentBody, setCommentBody] = useState("")
  const [replyTo, setReplyTo] = useState<string | null>(null)

  const post = postData?.data

  const comments = useMemo(() => commentsData?.data ?? [], [commentsData])

  const serverLiked = post?.isLiked ?? false
  const serverSaved = post?.isSaved ?? false

  const isLiked = postLikeOverride !== null ? postLikeOverride : serverLiked
  const isSaved = postSaveOverride !== null ? postSaveOverride : serverSaved

  const likedCommentIds = useMemo(() => {
    const liked = new Set<string>()
    const collectLiked = (cmts: Comment[]) => {
      for (const c of cmts) {
        const overridden = commentLikeOverrides[c.id]
        if (overridden !== undefined ? overridden : c.isLiked) liked.add(c.id)
        if (c.replies) collectLiked(c.replies)
      }
    }
    collectLiked(comments)
    return liked
  }, [comments, commentLikeOverrides])

  const handleLike = useCallback(() => {
    setPostLikeOverride(!isLiked)
    toggleLike.mutate({ id, liked: isLiked })
  }, [id, isLiked, toggleLike])

  const handleSave = useCallback(() => {
    setPostSaveOverride(!isSaved)
    toggleSave.mutate({ id, saved: isSaved })
  }, [id, isSaved, toggleSave])

  const handleCommentLike = useCallback((commentId: string, currentlyLiked: boolean) => {
    setCommentLikeOverrides((prev) => ({
      ...prev,
      [commentId]: !currentlyLiked,
    }))
    toggleCommentLike.mutate({ commentId, liked: currentlyLiked })
  }, [toggleCommentLike])

  const handleSubmitComment = async () => {
    if (!commentBody.trim()) return
    await createComment.mutateAsync({
      body: commentBody.trim(),
      ...(replyTo ? { parentId: replyTo } : {}),
    })
    setCommentBody("")
    setReplyTo(null)
  }

  const handleReply = (parentId: string) => {
    setReplyTo(parentId)
  }

  const handleDeleteComment = async (commentId: string) => {
    await deleteComment.mutateAsync(commentId)
  }

  const handleCancelReply = () => {
    setReplyTo(null)
    setCommentBody("")
  }

  const postContent = (
    <>
      {postLoading ? (
        <PostDetailSkeleton />
      ) : postError || !post ? (
        <div className="flex flex-col items-center gap-3 rounded-2xl border border-border bg-card p-8 text-center">
          <p className="text-sm text-muted-foreground">Failed to load post</p>
          <Button variant="outline" size="sm" onClick={() => refetchPost()}>Try again</Button>
        </div>
      ) : (
        <div className="space-y-4">
          <PostCard
            post={post}
            isLiked={isLiked}
            isSaved={isSaved}
            onLike={handleLike}
            onSave={handleSave}
            onComment={() => {
              document.getElementById("comment-input")?.focus()
            }}
          />

          <div className="rounded-2xl border border-border bg-card p-4" id="comments-section">
            <h3 className="mb-4 flex items-center gap-2 text-sm font-bold">
              <MessageSquare size={16} />
              Comments
            </h3>

            {commentsLoading && (
              <div className="space-y-3">
                {[1, 2].map((i) => (
                  <div key={i} className="flex gap-3 animate-pulse">
                    <div className="size-8 rounded-full bg-muted" />
                    <div className="flex-1 space-y-2">
                      <div className="h-8 w-full rounded-lg bg-muted" />
                    </div>
                  </div>
                ))}
              </div>
            )}

            {commentsError && (
              <p className="text-sm text-muted-foreground">Failed to load comments</p>
            )}

            {!commentsLoading && !commentsError && comments.length === 0 && (
              <p className="text-sm text-muted-foreground">No comments yet. Be the first to share your thoughts.</p>
            )}

            {!commentsLoading && !commentsError && comments.map((comment: Comment) => (
              <CommentItem
                key={comment.id}
                comment={comment}
                likedCommentIds={likedCommentIds}
                onLike={handleCommentLike}
                onReply={handleReply}
                onDelete={handleDeleteComment}
              />
            ))}

            <div className="mt-4 flex items-start gap-3 border-t border-border pt-4">
              <Avatar className="size-8 shrink-0">
                <AvatarFallback className="bg-primary/15 text-primary text-xs font-bold">
                  {user?.initials ?? "Y"}
                </AvatarFallback>
              </Avatar>
              <div className="flex-1 space-y-2">
                {replyTo && (
                  <div className="flex items-center gap-2 text-xs text-muted-foreground">
                    <span>Replying to a comment</span>
                    <button onClick={handleCancelReply} className="text-primary hover:underline">
                      Cancel
                    </button>
                  </div>
                )}
                <Textarea
                  id="comment-input"
                  placeholder={replyTo ? "Write a reply..." : "Share your thoughts..."}
                  value={commentBody}
                  onChange={(e) => setCommentBody(e.target.value)}
                  className="min-h-[80px] rounded-xl border border-border bg-muted/35 p-3 text-sm focus-visible:ring-0 resize-none"
                />
                <div className="flex justify-end">
                  <Button
                    size="sm"
                    className="rounded-xl gap-1.5"
                    disabled={!commentBody.trim() || createComment.isPending}
                    onClick={handleSubmitComment}
                  >
                    <CornerUpRight size={14} />
                    {createComment.isPending ? "Posting..." : replyTo ? "Reply" : "Post"}
                  </Button>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}
    </>
  )

  return (
    <>
      <div className="flex h-full flex-col lg:hidden">
        <header className="flex items-center gap-3 px-4 py-3 shrink-0 border-b border-border">
          <Button variant="ghost" size="icon-sm" onClick={() => router.back()}>
            <ArrowLeft size={20} />
          </Button>
          <h1 className="text-lg font-bold">Post</h1>
        </header>
        <div className="flex-1 overflow-y-auto px-4 pb-24 [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
          {postContent}
        </div>
      </div>

      <div className="hidden h-full overflow-y-auto lg:block">
        <div className="mx-auto max-w-3xl py-6 px-4 pb-10">
          {postContent}
        </div>
      </div>
    </>
  )
}

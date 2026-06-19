"use client"

import { useState } from "react"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { Button } from "@/components/ui/button"
import { Textarea } from "@/components/ui/textarea"
import { CornerUpRight, MessageSquare } from "nasicon-react/outline"
import { useComments, useCreateComment, useDeleteComment } from "@/hooks/use-posts"
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

function getInitials(name: string) {
  return name
    .split(" ")
    .map((n) => n[0])
    .join("")
    .toUpperCase()
    .slice(0, 2)
}

interface CommentItemProps {
  comment: Comment
  onReply: (parentId: string) => void
  onDelete: (commentId: string) => void
  isReply?: boolean
}

function CommentItem({ comment, onReply, onDelete, isReply }: CommentItemProps) {
  const [showReplies, setShowReplies] = useState(false)
  const hasReplies = comment.replies && comment.replies.length > 0

  return (
    <div className={`${isReply ? "ml-8 mt-3" : "mt-4"}`}>
      <div className="flex gap-3">
        <Avatar className="size-8 shrink-0">
          <AvatarFallback className="bg-primary/15 text-primary text-xs font-bold">
            {getInitials(comment.author.name)}
          </AvatarFallback>
        </Avatar>
        <div className="flex-1 min-w-0">
          <div className="rounded-xl bg-muted/50 px-3 py-2">
            <div className="flex items-center justify-between">
              <p className="text-sm font-bold">{comment.author.name}</p>
              <p className="text-[10px] text-muted-foreground">{formatDate(comment.createdAt)}</p>
            </div>
            <p className="mt-1 text-sm leading-relaxed">{comment.body}</p>
            {comment.media && (
              <div className="mt-2 text-xs text-primary underline">View attachment</div>
            )}
          </div>
          <div className="mt-1 flex items-center gap-3 px-1">
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

interface CommentSectionProps {
  postId: string
}

export function CommentSection({ postId }: CommentSectionProps) {
  const { data, isLoading, isError } = useComments(postId)
  const createComment = useCreateComment(postId)
  const deleteComment = useDeleteComment(postId)
  const [body, setBody] = useState("")
  const [replyTo, setReplyTo] = useState<string | null>(null)

  const comments = data?.data ?? []

  const handleSubmit = async () => {
    if (!body.trim()) return
    await createComment.mutateAsync({
      body: body.trim(),
      ...(replyTo ? { parentId: replyTo } : {}),
    })
    setBody("")
    setReplyTo(null)
  }

  const handleReply = (parentId: string) => {
    setReplyTo(parentId)
  }

  const handleDelete = async (commentId: string) => {
    await deleteComment.mutateAsync(commentId)
  }

  const handleCancelReply = () => {
    setReplyTo(null)
    setBody("")
  }

  return (
    <div className="rounded-2xl border border-border bg-card p-4">
      <h3 className="mb-4 flex items-center gap-2 text-sm font-bold">
        <MessageSquare size={16} />
        Comments
      </h3>

      {isLoading && (
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

      {isError && (
        <p className="text-sm text-muted-foreground">Failed to load comments</p>
      )}

      {!isLoading && !isError && comments.length === 0 && (
        <p className="text-sm text-muted-foreground">No comments yet. Be the first to share your thoughts.</p>
      )}

      {!isLoading && !isError && comments.map((comment: Comment) => (
        <CommentItem
          key={comment.id}
          comment={comment}
          onReply={handleReply}
          onDelete={handleDelete}
        />
      ))}

      <div className="mt-4 flex items-start gap-3 border-t border-border pt-4">
        <Avatar className="size-8 shrink-0">
          <AvatarFallback className="bg-primary/15 text-primary text-xs font-bold">Y</AvatarFallback>
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
            placeholder={replyTo ? "Write a reply..." : "Share your thoughts..."}
            value={body}
            onChange={(e) => setBody(e.target.value)}
            className="min-h-[80px] rounded-xl border border-border bg-muted/35 p-3 text-sm focus-visible:ring-0 resize-none"
          />
          <div className="flex justify-end">
            <Button
              size="sm"
              className="rounded-xl gap-1.5"
              disabled={!body.trim() || createComment.isPending}
              onClick={handleSubmit}
            >
              <CornerUpRight size={14} />
              {createComment.isPending ? "Posting..." : replyTo ? "Reply" : "Post"}
            </Button>
          </div>
        </div>
      </div>
    </div>
  )
}

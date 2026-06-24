"use client"

import { useState, useRef, useCallback, useEffect } from "react"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { Button } from "@/components/ui/button"
import {
  Sheet, SheetContent,
} from "@/components/ui/sheet"
import { StreamPlayerWrapper } from "@/components/shorts/stream-player"
import { CommentsSection } from "@/components/shorts/comments-section"
import { useShorts, useToggleShortLike } from "@/hooks/use-shorts"
import {
  Heart, MessageSquare, CornerUpRight, MusicNote,
} from "nasicon-react/outline"
import { Heart as HeartSolid } from "nasicon-react/solid"
import type { Short } from "@/types"

function formatCount(n: number) {
  if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(1)}M`
  if (n >= 1000) return `${(n / 1000).toFixed(1)}k`
  return String(n)
}

function getInitials(name: string) {
  return name
    .split(" ")
    .map((n) => n[0])
    .join("")
    .toUpperCase()
    .slice(0, 2)
}

function ShortItem({
  short,
  active,
  onCommentOpen,
}: {
  short: Short
  active: boolean
  onCommentOpen: (id: string) => void
}) {
  const [liked, setLiked] = useState(short.isLiked ?? false)
  const [likes, setLikes] = useState(short._count.likes)
  const toggleLike = useToggleShortLike()

  function handleLike() {
    const wasLiked = liked
    setLiked(!wasLiked)
    setLikes((c) => (wasLiked ? c - 1 : c + 1))
    toggleLike.mutate({ id: short.id, liked: wasLiked })
  }

  return (
    <div className="relative h-full w-full snap-start overflow-hidden bg-black lg:flex">
      {/* Video area */}
      <div className="relative h-full w-full lg:flex-1">
        <StreamPlayerWrapper short={short} playing={active} />

        {/* Gradient overlays */}
        <div className="pointer-events-none absolute inset-x-0 top-0 h-32 bg-gradient-to-b from-black/60 to-transparent" />
        <div className="pointer-events-none absolute inset-x-0 bottom-0 h-48 bg-gradient-to-t from-black/70 to-transparent" />

        {/* Top bar */}
        <div className="absolute inset-x-0 top-0 z-10 flex items-center justify-center px-4 py-4">
          <h1 className="text-base font-bold tracking-wide text-white">Shorts</h1>
        </div>

        {/* Mobile: Right action buttons */}
        <div className="absolute bottom-24 right-3 z-10 flex flex-col items-center gap-5 lg:hidden">
          <button onClick={handleLike} className="flex flex-col items-center gap-1">
            {liked
              ? <HeartSolid size={28} className="text-red-500" />
              : <Heart size={28} className="text-white" />}
            <span className="text-xs font-semibold text-white">{formatCount(likes)}</span>
          </button>

          <button onClick={() => onCommentOpen(short.id)} className="flex flex-col items-center gap-1">
            <MessageSquare size={28} className="text-white" />
            <span className="text-xs font-semibold text-white">{formatCount(short._count.comments)}</span>
          </button>

          <button className="flex flex-col items-center gap-1">
            <CornerUpRight size={28} className="text-white" />
            <span className="text-xs font-semibold text-white">Share</span>
          </button>

          <Avatar className="mt-1 ring-2 ring-white">
            <AvatarFallback className="bg-primary text-xs font-bold text-white">
              {getInitials(short.church.name)}
            </AvatarFallback>
          </Avatar>
        </div>

        {/* Mobile: Bottom info */}
        <div className="absolute inset-x-0 bottom-4 z-10 px-4 pr-20 lg:hidden">
          <div className="flex items-end gap-3">
            <Avatar className="shrink-0 ring-2 ring-white">
              <AvatarFallback className="bg-primary text-xs font-bold text-white">
                {getInitials(short.church.name)}
              </AvatarFallback>
            </Avatar>
            <div className="min-w-0 flex-1 space-y-1">
              <div className="flex items-center gap-2">
                <p className="truncate text-sm font-bold text-white">{short.church.name}</p>
                <Button
                  size="xs"
                  variant="outline"
                  className="shrink-0 rounded-full border-white bg-transparent text-[11px] text-white hover:bg-white/20"
                >
                  Follow
                </Button>
              </div>
              <p className="line-clamp-2 text-xs text-white/80">{short.description}</p>
              {short.novaFile?.streamCode && (
                <div className="flex items-center gap-1.5">
                  <MusicNote size={12} className="shrink-0 text-white" />
                  <p className="truncate text-[11px] text-white/60">Original Audio</p>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Desktop: Right panel */}
      <div className="hidden w-[420px] shrink-0 border-l border-white/10 bg-background lg:flex lg:flex-col">
        {/* Creator info */}
        <div className="border-b border-border px-4 py-4">
          <div className="flex items-center gap-3">
            <Avatar className="ring-2 ring-primary/30">
              <AvatarFallback className="bg-primary text-xs font-bold text-primary-foreground">
                {getInitials(short.church.name)}
              </AvatarFallback>
            </Avatar>
            <div className="min-w-0 flex-1">
              <p className="text-sm font-bold">{short.church.name}</p>
              <p className="text-xs text-muted-foreground">{short.viewCount} views &middot; {short.timeAgo}</p>
            </div>
            <Button size="xs" className="shrink-0 rounded-full">
              Follow
            </Button>
          </div>
          <p className="mt-2 text-sm text-foreground">{short.description}</p>
          {short.novaFile?.streamCode && (
            <div className="mt-1.5 flex items-center gap-1.5">
              <MusicNote size={12} className="text-muted-foreground" />
              <p className="text-xs text-muted-foreground">Original Audio</p>
            </div>
          )}
        </div>

        {/* Desktop action bar */}
        <div className="flex items-center gap-4 border-b border-border px-4 py-2.5">
          <button onClick={handleLike} className="flex items-center gap-1.5 text-sm font-semibold text-muted-foreground hover:text-red-500 transition-colors">
            {liked
              ? <HeartSolid size={18} className="text-red-500" />
              : <Heart size={18} />}
            <span>{formatCount(likes)}</span>
          </button>
          <button className="flex items-center gap-1.5 text-sm font-semibold text-muted-foreground">
            <MessageSquare size={18} />
            <span>{formatCount(short._count.comments)}</span>
          </button>
          <button className="flex items-center gap-1.5 text-sm font-semibold text-muted-foreground">
            <CornerUpRight size={18} />
            <span>Share</span>
          </button>
        </div>

        {/* Desktop comments */}
        <div className="flex-1 overflow-hidden">
          <CommentsSection shortId={short.id} />
        </div>
      </div>
    </div>
  )
}

export default function ShortsPage() {
  const { data, isLoading, isError, refetch } = useShorts()
  const shorts = data?.data ?? []
  const [activeIndex, setActiveIndex] = useState(0)
  const [commentShortId, setCommentShortId] = useState<string | null>(null)
  const containerRef = useRef<HTMLDivElement>(null)
  const shortRefs = useRef<(HTMLDivElement | null)[]>([])

  const handleScroll = useCallback(() => {
    const container = containerRef.current
    if (!container) return
    const index = Math.round(container.scrollTop / container.clientHeight)
    if (index !== activeIndex) {
      setActiveIndex(index)
    }
  }, [activeIndex])

  useEffect(() => {
    const container = containerRef.current
    if (!container) return
    container.addEventListener("scroll", handleScroll, { passive: true })
    return () => container.removeEventListener("scroll", handleScroll)
  }, [handleScroll])

  function handleCommentOpen(id: string) {
    setCommentShortId(id)
  }

  if (isLoading) {
    return (
      <div className="flex h-full items-center justify-center bg-black">
        <div className="flex flex-col items-center gap-3">
          <div className="size-8 animate-spin rounded-full border-2 border-white/30 border-t-white" />
          <p className="text-sm text-white/60">Loading shorts...</p>
        </div>
      </div>
    )
  }

  if (isError) {
    return (
      <div className="flex h-full items-center justify-center bg-black">
        <div className="flex flex-col items-center gap-3 px-4 text-center">
          <p className="text-sm text-white/80">Failed to load shorts</p>
          <Button variant="outline" size="sm" onClick={() => refetch()} className="border-white/30 text-white">
            Try again
          </Button>
        </div>
      </div>
    )
  }

  if (shorts.length === 0) {
    return (
      <div className="flex h-full items-center justify-center bg-black">
        <p className="text-sm text-white/60">No shorts yet</p>
      </div>
    )
  }

  return (
    <>
      <div
        ref={containerRef}
        className="h-full w-full snap-y snap-mandatory overflow-y-scroll bg-black"
      >
        {shorts.map((short, index) => (
          <div
            key={short.id}
            ref={(el) => { shortRefs.current[index] = el }}
            className="h-full w-full snap-start"
          >
            <ShortItem
              short={short}
              active={index === activeIndex}
              onCommentOpen={handleCommentOpen}
            />
          </div>
        ))}
      </div>

      {/* Mobile Comments Sheet */}
      <Sheet open={!!commentShortId} onOpenChange={(open) => { if (!open) setCommentShortId(null) }}>
        <SheetContent
          side="bottom"
          showCloseButton={false}
          className="flex max-h-[85%] flex-col rounded-t-3xl px-0 pb-0"
        >
          {commentShortId && (
            <CommentsSection shortId={commentShortId} onClose={() => setCommentShortId(null)} />
          )}
        </SheetContent>
      </Sheet>
    </>
  )
}
